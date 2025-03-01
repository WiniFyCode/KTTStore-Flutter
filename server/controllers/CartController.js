const Cart = require('../models/Cart');
const ProductSizeStock = require('../models/ProductSizeStock');
const Product = require('../models/Product');
const ProductColor = require('../models/ProductColor');
const Promotion = require('../models/Promotion');
const { getImageLink } = require('../middlewares/ImagesCloudinary_Controller');

class CartController {
    // Lấy giỏ hàng của user
    // Lấy giỏ hàng của user
    // Lấy giỏ hàng của user
    async getCart(req, res) {
        try {
            const userID = req.user.userID;
            const cartItems = await Cart.find({ userID });
            const currentDate = new Date();

            const items = await Promise.all(cartItems.map(async (item) => {
                try {
                    const sizeStock = await ProductSizeStock.findOne({ SKU: item.SKU });
                    if (!sizeStock) {
                        console.warn(`Không tìm thấy thông tin size cho SKU: ${item.SKU}`);
                        return null;
                    }

                    // Parse productID và colorID từ SKU (format: productID_colorID_size_version)
                    const [productID, colorID] = sizeStock.SKU.split('_');

                    // Lấy thông tin sản phẩm và populate categoryInfo
                    const product = await Product.findOne(
                        { productID: parseInt(productID), isActivated: true },
                        'productID name price thumbnail categoryID'
                    ).populate('categoryInfo');

                    if (!product) {
                        console.warn(`Không tìm thấy thông tin sản phẩm cho productID: ${productID}`);
                        return null;
                    }

                    // Tìm promotion đang active
                    const promotion = await Promotion.findOne({
                        $or: [
                            { products: product._id },
                            { categories: product.categoryInfo?.name }
                        ],
                        status: 'active',
                        startDate: { $lte: currentDate },
                        endDate: { $gte: currentDate }
                    }).sort({ discountPercent: -1 });

                    // Lấy thông tin màu sắc
                    let color = await ProductColor.findOne({
                        colorID: parseInt(colorID),
                        productID: parseInt(productID)
                    });

                    if (!color) {
                        console.warn(`Không tìm thấy thông tin màu sắc cho colorID: ${colorID}, productID: ${productID}`);
                        color = {
                            colorName: 'Mặc định',
                            images: []
                        };
                    }

                    // Tính giá gốc và giá sau khuyến mãi
                    const priceNumber = parseInt(product.price.replace(/\./g, ''));
                    const discountPrice = promotion 
                        ? Math.round(priceNumber * (1 - promotion.discountPercent / 100))
                        : priceNumber;
                    const subtotal = item.quantity * discountPrice;

                    return {
                        cartID: item.cartID,
                        SKU: item.SKU,
                        product: {
                            productID: product.productID,
                            name: product.name,
                            categoryID: product.categoryID,
                            price: priceNumber,
                            discountPrice: discountPrice,
                            thumbnail: await getImageLink(color.images[0] || product.thumbnail)
                        },
                        size: sizeStock.size,
                        colorName: color.colorName,
                        quantity: item.quantity,
                        subtotal,
                        stock: sizeStock.stock
                    };
                } catch (error) {
                    console.error(`Lỗi khi xử lý item ${item.cartID}:`, error);
                    return null;
                }
            }));

            const validItems = items.filter(item => item !== null);

            res.json({
                message: 'Lấy giỏ hàng thành công',
                items: validItems,
                totalAmount: validItems.reduce((sum, item) => sum + item.subtotal, 0),
                itemCount: validItems.length
            });
        } catch (error) {
            console.error('Error in getCart:', error);
            res.status(500).json({
                message: 'Có lỗi xảy ra khi lấy giỏ hàng',
                error: error.message
            });
        }
    }

    // Thêm sản phẩm vào giỏ hàng
    async addToCart(req, res) {
        try {
            const userID = req.user.userID;
            const { SKU, quantity = 1 } = req.body;

            console.log(`SKU: ${SKU}, quantity: ${quantity}`);

            // Kiểm tra sản phẩm tồn tại và còn hàng
            const stockItem = await ProductSizeStock.findOne({ SKU });
            if (!stockItem) {
                return res.status(404).json({ message: 'Sản phẩm không tồn tại' });
            }
            console.log(`stock: ${stockItem.stock}`);

            if (stockItem.stock < quantity) {
                return res.status(400).json({ message: 'Số lượng sản phẩm trong kho không đủ' });
            }

            // Kiểm tra sản phẩm đã có trong giỏ hàng chưa
            let cartItem = await Cart.findOne({ userID, SKU });

            if (cartItem) {
                // Nếu đã có, cập nhật số lượng
                const newQuantity = cartItem.quantity + quantity;
                console.log(`new quantity: ${newQuantity}`);
                if (newQuantity > stockItem.stock) {
                    return res.status(400).json({ message: `Số lượng sản phẩm trong kho không đủ, đã tồn tại ${cartItem.quantity} sản phẩm này trong giỏ hàng`, maxQuantity: stockItem.stock });
                }

                cartItem.quantity = newQuantity;
                await cartItem.save();
            } else {
                // Nếu chưa có, tạo mới
                const lastCart = await Cart.findOne().sort({ cartID: -1 });
                const cartID = lastCart ? lastCart.cartID + 1 : 1;

                cartItem = new Cart({
                    cartID,
                    userID,
                    SKU,
                    quantity
                });
                await cartItem.save();
            }

            res.status(201).json({
                message: 'Thêm vào giỏ hàng thành công',
                cartItem
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi thêm vào giỏ hàng',
                error: error.message
            });
        }
    }

    // Cập nhật số lượng sản phẩm trong giỏ
    async updateCartItem(req, res) {
        try {
            const userID = req.user.userID;
            const { id } = req.params;
            const { quantity } = req.body;

            // Kiểm tra item tồn tại trong giỏ
            const cartItem = await Cart.findOne({ cartID: id, userID });
            if (!cartItem) {
                return res.status(404).json({ message: 'Không tìm thấy sản phẩm trong giỏ hàng' });
            }

            // Kiểm tra số lượng tồn kho
            const stockItem = await ProductSizeStock.findOne({ SKU: cartItem.SKU });
            if (stockItem.stock < quantity) {
                return res.status(400).json({ message: 'Số lượng sản phẩm trong kho không đủ', maxQuantity: stockItem.stock });
            }

            // Cập nhật số lượng
            cartItem.quantity = quantity;
            await cartItem.save();

            res.json({
                message: 'Cập nhật số lượng thành công',
                // cartItem
            });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi cập nhật số lượng',
                error: error.message
            });
        }
    }

    // Xóa sản phẩm khỏi giỏ hàng
    async removeFromCart(req, res) {
        try {
            const userID = req.user.userID;
            const { id } = req.params;

            const cartItem = await Cart.findOne({ cartID: id, userID });
            if (!cartItem) {
                return res.status(404).json({ message: 'Không tìm thấy sản phẩm trong giỏ hàng' });
            }

            await cartItem.deleteOne();

            res.json({ message: 'Xóa sản phẩm khỏi giỏ hàng thành công' });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi xóa sản phẩm khỏi giỏ hàng',
                error: error.message
            });
        }
    }

    // Xóa toàn bộ giỏ hàng
    async clearCart(req, res) {
        try {
            const userID = req.user.userID;

            await Cart.deleteMany({ userID });

            res.json({ message: 'Xóa giỏ hàng thành công' });
        } catch (error) {
            res.status(500).json({
                message: 'Có lỗi xảy ra khi xóa giỏ hàng',
                error: error.message
            });
        }
    }
}

module.exports = new CartController();
