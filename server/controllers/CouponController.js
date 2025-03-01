const Coupon = require('../models/Coupon');
const UserCoupon = require('../models/UserCoupon');
const Category = require('../models/Category');

class CouponController {
    // USER: Lấy danh sách mã giảm giá có thể sử dụng
    async getAvailableCoupons(req, res) {
        try {
            const userID = req.user.userID;
            const { orderValue, page = 1, limit = 10 } = req.query;
    
            // Calculate the number of documents to skip
            const skip = (page - 1) * limit;
    
            // Lấy tất cả mã giảm giá đang hoạt động với phân trang
            const coupons = await Coupon.find({
                isActive: true,
                startDate: { $lte: new Date() },
                endDate: { $gt: new Date() },
                minOrderValue: { $lte: orderValue || 0 }
            })
            .skip(skip)
            .limit(limit);
    
            // Kiểm tra điều kiện sử dụng cho từng mã
            const availableCoupons = await Promise.all(coupons.map(async (coupon) => {
                // Kiểm tra số lần sử dụng tổng
                const totalUsage = await UserCoupon.countDocuments({ couponID: coupon.couponID });
                if (totalUsage >= coupon.maxUsageCount) {
                    console.log('error: hết lượng sử dụng tổng');
                    return null;
                }
    
                // Kiểm tra số lần sử dụng của user
                const userUsage = await UserCoupon.countDocuments({
                    couponID: coupon.couponID,
                    userID
                });
                if (userUsage >= coupon.maxUsagePerUser) {
                    console.log('error: hết lượng sử dụng của user');
                    return null;
                }
    
                return {
                    ...coupon.toJSON(),
                    usageLeft: coupon.maxUsagePerUser - userUsage
                };
            }));
    
            // Lọc bỏ các mã không thể sử dụng
            const validCoupons = availableCoupons.filter(coupon => coupon !== null);
    
            // Đếm tổng số mã giảm giá hợp lệ
            const totalCoupons = await Coupon.countDocuments({
                isActive: true,
                startDate: { $lte: new Date() },
                endDate: { $gt: new Date() },
                minOrderValue: { $lte: orderValue || 0 }
            });
    
            // Tính tổng số trang
            const totalPages = Math.ceil(totalCoupons / limit);
    
            res.json({
                coupons: validCoupons,
                totalCoupons,
                totalPages,
                currentPage: parseInt(page)
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi lấy danh sách mã giảm giá',
                error: error.message
            });
        }
    }

    // USER: Áp dụng mã giảm giá
    async applyCoupon(req, res) {
        try {
            const userID = req.user.userID;
            const { code, orderValue } = req.body;

            // Tìm mã giảm giá
            const coupon = await Coupon.findOne({
                code: code.toUpperCase(),
                isActive: true,
                startDate: { $lte: new Date() },
                endDate: { $gt: new Date() }
            });

            if (!coupon) {
                return res.status(404).json({ message: 'Mã giảm giá không tồn tại hoặc đã hết hạn' });
            }

            // Kiểm tra giá trị đơn hàng tối thiểu
            if (orderValue < coupon.minOrderValue) {
                return res.status(400).json({
                    message: `Đơn hàng phải từ ${coupon.minOrderValue}đ trở lên để sử dụng mã giảm giá này`
                });
            }

            // Kiểm tra số lần sử dụng tổng
            const totalUsage = await UserCoupon.countDocuments({ couponID: coupon.couponID });
            if (totalUsage >= coupon.maxUsageCount) {
                return res.status(400).json({ message: 'Mã giảm giá đã hết lượt sử dụng' });
            }

            // Kiểm tra và cập nhật UserCoupon
            let userCoupon = await UserCoupon.findOne({
                couponID: coupon.couponID,
                userID
            });

            if (userCoupon) {
                // Nếu đã có bản ghi, kiểm tra số lượt còn lại
                if (userCoupon.usageLeft <= 0) {
                    return res.status(400).json({ message: 'Bạn đã sử dụng hết lượt của mã giảm giá này' });
                }
                // Cập nhật số lượt còn lại
                userCoupon.usageLeft -= 1;
                await userCoupon.save();
            } else {
                // Tạo UserCoupon mới nếu chưa có
                const lastUserCoupon = await UserCoupon.findOne().sort({ userCouponsID: -1 });
                const userCouponsID = lastUserCoupon ? lastUserCoupon.userCouponsID + 1 : 1;

                userCoupon = new UserCoupon({
                    userCouponsID,
                    couponID: coupon.couponID,
                    userID,
                    usageLeft: coupon.maxUsagePerUser - 1, // Trừ đi 1 vì đang sử dụng
                    expiryDate: coupon.endDate
                });
                await userCoupon.save();
            }

            // Tính số tiền giảm
            let discountAmount;
            if (coupon.discountType === 'percentage') {
                discountAmount = Math.min(
                    orderValue * (coupon.discountValue / 100),
                    coupon.maxDiscountAmount
                );
            } else {
                discountAmount = Math.min(
                    coupon.discountValue,
                    coupon.maxDiscountAmount
                );
            }

            res.json({
                message: 'Áp dụng mã giảm giá thành công',
                coupon,
                discountAmount,
                userCouponsID: userCoupon.userCouponsID
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi áp dụng mã giảm giá',
                error: error.message
            });
        }
    }

    // USER: Lấy lịch sử sử dụng mã giảm giá
    async getCouponHistory(req, res) {
        try {
            const userID = req.user.userID;
            const { page = 1, limit = 10 } = req.query;

            // Lấy lịch sử sử dụng mã giảm giá với phân trang
            const userCoupons = await UserCoupon.find({ userID })
                .sort('-createdAt')
                .skip((page - 1) * limit)
                .limit(limit)
                .populate({
                    path: 'couponInfo',
                    select: 'code description discountType discountValue'
                })
                .populate({
                    path: 'usageHistory.orderInfo',
                    select: 'orderID totalAmount status'
                });

            // Đếm tổng số mã đã sử dụng
            const total = await UserCoupon.countDocuments({ userID });

            res.json({
                userCoupons,
                total,
                totalPages: Math.ceil(total / limit),
                currentPage: page
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi lấy lịch sử sử dụng mã giảm giá',
                error: error.message
            });
        }
    }

    //!ADMIN
    // ADMIN: Lấy danh sách mã giảm giá
    // "coupon" + "stats : tổng mã giảm giá , mã giảm giá đang hoạt động , mã giảm giá hết hạn, tổng lượt sử dụng"
    async getCouponsChoADMIN(req, res) {
        try {
            // Lấy tất cả mã giảm giá
            const coupons = await Coupon.find()
                .select('couponID code description discountType discountValue minOrderValue maxDiscountAmount startDate endDate usageLimit totalUsageLimit usedCount isActive couponType minimumQuantity appliedCategories createdAt updatedAt');

            // Lấy tất cả categories để map với appliedCategories
            const categories = await Category.find().select('categoryID name');
            const categoryMap = categories.reduce((acc, cat) => {
                acc[cat.categoryID] = cat.name;
                return acc;
            }, {});

            // Transform coupons để thêm tên category
            const transformedCoupons = coupons.map(coupon => {
                const couponObj = coupon.toObject();
                if (couponObj.appliedCategories && couponObj.appliedCategories.length > 0) {
                    const categoryNames = {};
                    couponObj.appliedCategories.forEach(catID => {
                        if (categoryMap[catID]) {
                            categoryNames[catID] = categoryMap[catID];
                        }
                    });
                    couponObj.appliedCategories = categoryNames;
                }
                return couponObj;
            });

            const currentDate = new Date();

            // Tính toán thống kê
            const stats = {
                totalCoupons: transformedCoupons.length,
                totalActiveCoupons: transformedCoupons.filter(coupon => 
                    coupon.isActive && 
                    new Date(coupon.endDate) >= currentDate && 
                    coupon.usedCount < coupon.totalUsageLimit
                ).length,
                totalExpiredCoupons: transformedCoupons.filter(coupon => 
                    !coupon.isActive || 
                    new Date(coupon.endDate) < currentDate ||
                    coupon.usedCount >= coupon.totalUsageLimit
                ).length,
                totalUsedCount: transformedCoupons.reduce((sum, coupon) => sum + coupon.usedCount, 0)
            };

            res.json({
                coupons: transformedCoupons,
                stats
            });
        } catch (error) {
            console.log(error);
            res.status(500).json({
                message: 'Có lỗi xảy ra khi lấy danh sách mã giảm giá',
                error: error.message
            });
        }
    }

    //!ADMIN
    // ADMIN: Tạo mã giảm giá mới
    async createCoupon(req, res) {
        try {
            const {
                code,
                description,
                discountType,
                discountValue,
                minOrderValue,
                maxDiscountAmount,
                startDate,
                endDate,
                usageLimit,
                totalUsageLimit,
                isActive = true,
                couponType,
                minimumQuantity,
                appliedCategories
            } = req.body;

            // Kiểm tra mã đã tồn tại chưa
            const existingCoupon = await Coupon.findOne({ code: code.toUpperCase() });
            if (existingCoupon) {
                return res.status(400).json({ message: 'Mã giảm giá đã tồn tại' });
            }

            // Tạo ID mới cho coupon
            const lastCoupon = await Coupon.findOne().sort({ couponID: -1 });
            const couponID = lastCoupon ? lastCoupon.couponID + 1 : 1;

            const coupon = new Coupon({
                couponID,
                code: code.toUpperCase(),
                description,
                discountType,
                discountValue,
                minOrderValue,
                maxDiscountAmount,
                startDate,
                endDate,
                usageLimit,
                totalUsageLimit,
                usedCount: 0,
                isActive,
                couponType,
                minimumQuantity,
                appliedCategories
            });

            await coupon.save();

            res.status(201).json({
                message: 'Tạo mã giảm giá thành công',
                coupon
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi tạo mã giảm giá',
                error: error.message
            });
        }
    }

    //!ADMIN
    // ADMIN: Cập nhật mã giảm giá
    async updateCoupon(req, res) {
        try {
            const { id } = req.params;
            const updateData = req.body;

            // Kiểm tra mã giảm giá tồn tại
            const coupon = await Coupon.findOne({ couponID: id });
            if (!coupon) {
                return res.status(404).json({ message: 'Không tìm thấy mã giảm giá' });
            }

            // Nếu cập nhật code, kiểm tra code mới đã tồn tại chưa
            if (updateData.code && updateData.code !== coupon.code) {
                const existingCoupon = await Coupon.findOne({ 
                    code: updateData.code.toUpperCase(),
                    couponID: { $ne: id }
                });
                if (existingCoupon) {
                    return res.status(400).json({ message: 'Mã giảm giá đã tồn tại' });
                }
            }

            // Cập nhật thông tin
            Object.assign(coupon, updateData);
            await coupon.save();

            res.json({
                message: 'Cập nhật mã giảm giá thành công',
                coupon
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi cập nhật mã giảm giá',
                error: error.message
            });
        }
    }

    //!ADMIN
    // ADMIN: Xóa mã giảm giá
    async deleteCoupon(req, res) {
        try {
            const { id } = req.params;

            // Kiểm tra mã giảm giá tồn tại
            const coupon = await Coupon.findOne({ couponID: id });
            if (!coupon) {
                return res.status(404).json({ message: 'Không tìm thấy mã giảm giá' });
            }

            // Kiểm tra có user nào đang sử dụng mã không
            // const usersUsingCoupon = await UserCoupon.countDocuments({ couponID: id });
            // if (usersUsingCoupon > 0) {
            //     return res.status(400).json({
            //         message: 'Không thể xóa mã giảm giá này vì đang có người dùng sử dụng'
            //     });
            // }

            await coupon.deleteOne();

            res.json({ message: 'Xóa mã giảm giá thành công' });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi xóa mã giảm giá',
                error: error.message
            });
        }
    }

    //!ADMIN
    // ADMIN: Bật/tắt trạng thái mã giảm giá
    async toggleCouponStatus(req, res) {
        try {
            const { id } = req.params;
            const { isActive } = req.body;

            const coupon = await Coupon.findOne({ couponID: id });
            if (!coupon) {
                return res.status(404).json({ message: 'Không tìm thấy mã giảm giá' });
            }

            coupon.isActive = isActive;
            await coupon.save();

            res.json({
                message: isActive ? 'Đã kích hoạt mã giảm giá' : 'Đã vô hiệu hóa mã giảm giá',
                coupon: {
                    couponID: coupon.couponID,
                    code: coupon.code,
                    isActive: coupon.isActive
                }
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi thay đổi trạng thái mã giảm giá',
                error: error.message
            });
        }
    }
}

module.exports = new CouponController();
