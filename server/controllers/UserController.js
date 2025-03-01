const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { getImageLink, uploadUserAvatar } = require('../middlewares/ImagesCloudinary_Controller');
const multer = require('multer');
const path = require('path');


class UserController {
    // USER: Lấy thông tin cá nhân
    async getProfile(req, res) {
        try {
            const userID = req.user.userID;

            const user = await User.findOne({ userID })
                .select('-password -resetPasswordToken -resetPasswordExpires')
                .populate('addresses');

            if (!user) {
                return res.status(404).json({ message: 'Không tìm thấy người dùng' });
            }
            user.avatar = await getImageLink(user.avatar);

            res.json(user);
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi lấy thông tin cá nhân',
                error: error.message
            });
        }
    }

    // USER: Cập nhật thông tin cá nhân
    async updateProfile(req, res) {
        try {
            // Lấy userID từ token đăng nhập
            const userID = req.user.userID;
            // Lấy thông tin cần update từ body request
            const { fullname, gender, phone } = req.body;

            // Tìm user trong database
            const user = await User.findOne({ userID });
            if (!user) {
                return res.status(404).json({ message: 'Không tìm thấy người dùng' });
            }

            // Kiểm tra nếu số điện thoại mới khác số cũ
            if (phone && phone !== user.phone) {
                // Kiểm tra xem số điện thoại mới có trùng với user khác không
                const existingUser = await User.findOne({
                    phone,
                    userID: { $ne: userID } // Loại trừ user hiện tại
                });
                if (existingUser) {
                    return res.status(400).json({
                        message: 'Số điện thoại đã được sử dụng'
                    });
                }
            }

            // Cập nhật thông tin mới (chỉ cập nhật nếu có gửi lên)
            if (fullname) user.fullname = fullname;
            if (gender) user.gender = gender;
            if (phone) user.phone = phone;

            // Lưu vào database
            await user.save();

            // Loại bỏ thông tin nhạy cảm trước khi trả về
            const userResponse = user.toJSON();
            delete userResponse.password;
            delete userResponse.resetPasswordToken;
            delete userResponse.resetPasswordExpires;

            res.json({
                message: 'Cập nhật thông tin thành công',
                user: userResponse
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi cập nhật thông tin',
                error: error.message
            });
        }
    }

    // USER: Đổi mật khẩu
    async changePassword(req, res) {
        try {
            // Lấy userID từ token đăng nhập
            const userID = req.user.userID;
            // Lấy thông tin mật khẩu mới từ request body
            const { currentPassword, newPassword } = req.body;

            // Tìm user trong database bằng userID
            const user = await User.findOne({ userID });
            if (!user) {
                return res.status(404).json({ message: 'Không tìm thấy người dùng' });
            }

            // Kiểm tra mật khẩu hiện tại
            const isMatch = await user.comparePassword(currentPassword);
            if (!isMatch) {
                return res.status(400).json({ message: 'Mật khẩu hiện tại không đúng' });
            }

            // Hash mật khẩu mới
            const salt = await bcrypt.genSalt(10);
            user.password = await bcrypt.hash(newPassword, salt);

            await user.save();

            res.json({ message: 'Đổi mật khẩu thành công' });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi đổi mật khẩu',
                error: error.message
            });
        }
    }

    async uploadAvatar(req, res) {
        try {
            const userID = req.user.userID;

            const user = await User.findOne({ userID });
            if (!user) {
                return res.status(404).json({ message: 'Không tìm thấy người dùng' });
            }

            // Kiểm tra xem file có được tải lên không
            if (!req.file) {
                return res.status(400).json({ message: 'Không có file nào được tải lên' });
            }

            // kiểm tra định dạng file
            const extension = path.extname(req.file.originalname).toLowerCase();
            const allowedExtensions = ['.jpeg', '.jpg', '.png', '.webp'];
            if (!allowedExtensions.includes(extension)) {
                return res.status(400).json({ message: 'Định dạng file không hợp lệ' });
            }

            // Tải ảnh lên Cloudinary
            const publicId = await uploadUserAvatar(req.file.path, userID, user.avatar);
            if (!publicId) {
                return res.status(500).json({ message: 'Tải ảnh lên Cloudinary thất bại' });
            }
            else {
                const imageLink = await getImageLink(publicId);
                console.log('Đường link ảnh:', imageLink);

                // Lưu thông tin ảnh vào MongoDB    
                user.avatar = publicId;
                await user.save();

                res.json({
                    message: 'Avatar được tải lên thành công',
                    avatar: imageLink
                });
            }


        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi tải lên avatar',
                error: error.message
            });
            console.log(`Có lỗi xảy ra khi tải lên avatar ${error.message}`);
        }
    }

    //!ADMIN
    // Lấy danh sách người dùng cho ADMIN bao gồm
    // "user" + "stats : tổng người dùng , người dùng đang hoạt động , người dùng bị khóa"
    async getUsersChoADMIN(req, res) {
        try {
            // Lấy tất cả người dùng
            const users = await User.find()
                .select('_id userID email fullname gender phone address role isDisabled ');

            // Tính toán thống kê
            const stats = {
                totalUser: users.length,
                totalActiveUser: users.filter(user => !user.isDisabled).length,
                totalDeactivatedUser: users.filter(user => user.isDisabled).length
            };

            res.json({
                users,
                stats
            });
        } catch (error) {
            console.log(error);
            res.status(500).json({
                message: 'Có lỗi xảy ra khi lấy danh sách người dùng',
                error: error.message
            });
        }
    }

    //!ADMIN
    // ADMIN: Cập nhật thông tin người dùng
    async updateUser(req, res) {
        try {
            // Lấy userID từ params thay vì token
            const { id } = req.params;
            // Lấy thông tin cần update từ body request
            const { fullname, gender, phone } = req.body;

            // Tìm user trong database bằng id từ params
            const user = await User.findOne({ userID: id });
            if (!user) {
                return res.status(404).json({ message: 'Không tìm thấy người dùng' });
            }

            // Kiểm tra nếu user là admin thì không được phép chỉnh sửa
            if (user.role === 'admin') {
                return res.status(403).json({
                    message: 'Không được phép chỉnh sửa thông tin của admin'
                });
            }

            // Kiểm tra nếu số điện thoại mới khác số cũ
            if (phone && phone !== user.phone) {
                // Kiểm tra xem số điện thoại mới có trùng với user khác không
                const existingUser = await User.findOne({
                    phone,
                    userID: { $ne: id } // Sử dụng id từ params
                });
                if (existingUser) {
                    return res.status(400).json({
                        message: 'Số điện thoại đã được sử dụng'
                    });
                }
            }

            // Cập nhật thông tin mới (chỉ cập nhật nếu có gửi lên)
            if (fullname) user.fullname = fullname;
            if (gender) user.gender = gender;
            if (phone) user.phone = phone;

            // Lưu vào database
            await user.save();

            // Loại bỏ thông tin nhạy cảm trước khi trả về
            const userResponse = user.toJSON();
            delete userResponse.password;
            delete userResponse.resetPasswordToken;
            delete userResponse.resetPasswordExpires;

            res.json({
                message: 'Cập nhật thông tin thành công',
                user: userResponse
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi cập nhật thông tin',
                error: error.message
            });
        }
    }

    //!ADMIN
    // ADMIN: Vô hiệu hóa/Kích hoạt tài khoản
    async toggleUserStatus(req, res) {
        try {
            const { id } = req.params;
            const { isDisabled } = req.body;

            const user = await User.findOne({ userID: id });
            if (!user) {
                return res.status(404).json({ message: 'Không tìm thấy người dùng' });
            }

            // Không cho phép vô hiệu hóa tài khoản admin
            if (user.role === 'admin' && isDisabled) {
                return res.status(400).json({
                    message: 'Không thể vô hiệu hóa tài khoản admin'
                });
            }

            user.isDisabled = isDisabled;
            await user.save();

            res.json({
                message: isDisabled ? 'Đã vô hiệu hóa tài khoản' : 'Đã kích hoạt tài khoản',
                user: {
                    userID: user.userID,
                    isDisabled: user.isDisabled
                }
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi thay đổi trạng thái tài khoản',
                error: error.message
            });
        }
    }
}

module.exports = new UserController();
