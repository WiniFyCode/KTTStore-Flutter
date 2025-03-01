const Favorite = require('../models/Favorite');
const ProductSizeStock = require('../models/ProductSizeStock');
const Product = require('../models/Product');
const ProductColor = require('../models/ProductColor');
const { getImageLink } = require('../middlewares/ImagesCloudinary_Controller');
const Promotion = require('../models/Promotion');

class FavoriteController {

    async addToFavorites(req, res) {
        try {
            const userID = req.user.userID;
            const { SKU, note = '' } = req.body;

            // Kiểm tra sản phẩm tồn tại
            const stockItem = await ProductSizeStock.findOne({ SKU });
            if (!stockItem) {
                return res.status(404).json({ message: 'Sản phẩm không tồn tại' });
            }

            // Kiểm tra sản phẩm đã có trong danh sách yêu thích chưa
            const existingFavorite = await Favorite.findOne({ userID, SKU });
            if (existingFavorite) {
                return res.status(400).json({ message: 'Sản phẩm đã có trong danh sách yêu thích' });
            }

            // Tạo ID mới cho favorite
            const lastFavorite = await Favorite.findOne().sort({ favoriteID: -1 });
            const favoriteID = lastFavorite ? lastFavorite.favoriteID + 1 : 1;

            // Thêm vào danh sách yêu thích
            const favorite = new Favorite({
                favoriteID,
                userID,
                SKU,
                note
            });

            await favorite.save();

            res.status(201).json({
                message: 'Thêm vào danh sách yêu thích thành công',
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi thêm vào danh sách yêu thích',
                error: error.message
            });
        }
    }

    // Cập nhật ghi chú cho sản phẩm yêu thích
    async updateFavorite(req, res) {
        try {
            const userID = req.user.userID;
            const { id } = req.params;
            const { note } = req.body;

            const favorite = await Favorite.findOne({ favoriteID: id, userID });
            if (!favorite) {
                return res.status(404).json({ message: 'Không tìm thấy sản phẩm trong danh sách yêu thích' });
            }

            favorite.note = note;
            await favorite.save();

            res.json({
                message: 'Cập nhật ghi chú thành công',
                favorite
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi cập nhật ghi chú',
                error: error.message
            });
        }
    }

    // Xóa sản phẩm khỏi danh sách yêu thích
    // async removeFromFavorites(req, res) {
    //     try {
    //         const userID = req.user.userID;
    //         const { id } = req.params;

    //         const favorite = await Favorite.findOne({ favoriteID: id, userID });
    //         if (!favorite) {
    //             return res.status(404).json({ message: 'Không tìm thấy sản phẩm trong danh sách yêu thích' });
    //         }

    //         await favorite.deleteOne();

    //         res.json({ message: 'Xóa khỏi danh sách yêu thích thành công' });
    //     } catch (error) {
    //         res.status(500).json({
    //             message: 'Có lỗi xảy ra khi xóa khỏi danh sách yêu thích',
    //             error: error.message
    //         });
    //     }
    // }
    async removeFromFavorites(req, res) {
        try {
            const userID = req.user.userID;
            const { SKU } = req.params;

            const favorite = await Favorite.findOne({ SKU, userID });
            if (!favorite) {
                return res.status(404).json({ message: 'Không tìm thấy sản phẩm trong danh sách yêu thích' });
            }

            await favorite.deleteOne();

            res.json({ message: 'Xóa khỏi danh sách yêu thích thành công' });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi xóa khỏi danh sách yêu thích',
                error: error.message
            });
        }
    }

    // Kiểm tra sản phẩm có trong danh sách yêu thích không
    async checkFavorite(req, res) {
        try {
            const userID = req.user.userID;
            const { SKU } = req.params;

            const favorite = await Favorite.findOne({ userID, SKU });

            res.json({
                isFavorite: !!favorite,
                favorite
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi kiểm tra trạng thái yêu thích',
                error: error.message
            });
        }
    }

    async getFavoriteList(req, res) {
        try {
            const userID = req.user.userID;
            const { page = 1, limit = 10 } = req.query;

            const favorites = await Favorite.find({ userID })
                .skip((page - 1) * limit)
                .limit(limit);

            const favoriteList = await Promise.all(favorites.map(async (fav) => {
                const sizeStock = await ProductSizeStock.findOne({ SKU: fav.SKU });

                if (!sizeStock) {
                    return null;
                }

                const [productID, colorID, size] = sizeStock.SKU.split('_');
                const product = await Product.findOne({ productID: parseInt(productID), isActivated: true })
                    .populate('categoryInfo');

                if (!product || !product.categoryInfo) {
                    return null;
                }

                const color = await ProductColor.findOne({ colorID: parseInt(colorID) });

                // Lấy thông tin promotion
                const currentDate = new Date();
                const promotion = await Promotion.findOne({
                    $or: [
                        { products: product._id },
                        { categories: product.categoryInfo.name }
                    ],
                    status: 'active',
                    startDate: { $lte: currentDate },
                    endDate: { $gte: currentDate }
                }).sort({ discountPercent: -1 });

                console.log('Debug info:', {
                    productId: product._id,
                    categoryName: product.categoryInfo.name,
                    foundPromotion: promotion
                });

                let promotionInfo = null;
                if (promotion) {
                    const priceNumber = parseInt(product.price.replace(/\./g, ''));
                    const discountedPrice = Math.round(priceNumber * (1 - promotion.discountPercent / 100));
                    promotionInfo = {
                        name: promotion.name,
                        discountPercent: promotion.discountPercent,
                        discountedPrice: discountedPrice.toString(),
                        endDate: promotion.endDate
                    };
                }

                return {
                    favoriteID: fav.favoriteID,
                    SKU: fav.SKU,
                    productID: product.productID,
                    name: product.name,
                    price: parseInt(product.price.replace(/\./g, '')),
                    thumbnail: await getImageLink(product.thumbnail),
                    colorName: color ? color.colorName : null,
                    size: size,
                    promotion: promotionInfo
                };
            }));

            const totalItem = await Favorite.countDocuments({ userID });
            const totalPage = Math.ceil(totalItem / limit);

            res.json({
                products: favoriteList.filter(item => item !== null),
                totalItem,
                totalPage,
                currentPage: parseInt(page)
            });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }
    
}

module.exports = new FavoriteController();
