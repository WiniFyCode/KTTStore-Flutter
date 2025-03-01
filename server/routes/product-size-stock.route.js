const express = require('express');
const router = express.Router();
const ProductSizeStockController = require('../controllers/ProductSizeStockController');
const { authenticateToken, isAdmin } = require('../middlewares/auth.middleware');

// Routes cho người dùng (khôi dùng hết)
router.get('/sku/:SKU', ProductSizeStockController.getStockBySKU); // Lấy thông tin tồn kho theo SKU
router.get('/color/:colorID', ProductSizeStockController.getStockByColor); // Lấy tồn kho theo màu

//!ADMIN
router.put('/admin/product-size-stock/update/:SKU', authenticateToken, isAdmin, ProductSizeStockController.updateStock); // Cập nhật số lượng TỒN

module.exports = router;
