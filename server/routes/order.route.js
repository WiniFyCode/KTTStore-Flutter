const express = require('express');
const router = express.Router();
const OrderController = require('../controllers/OrderController');
const { authenticateToken, isAdmin } = require('../middlewares/auth.middleware');

// Routes cho người dùng (yêu cầu đăng nhập, khôi đang dùng hết)
router.get('/my-orders', authenticateToken, OrderController.getOrders); // Lấy danh sách đơn hàng của user
router.get('/my-orders/:id', authenticateToken, OrderController.getOrderById); // Lấy chi tiết đơn hàng
router.post('/create', authenticateToken, OrderController.createOrder); // Tạo đơn hàng mới
router.post('/cancel/:id', authenticateToken, OrderController.cancelOrder); // Hủy đơn hàng

//!ADMIN
router.get('/admin/orders', authenticateToken, isAdmin, OrderController.getAllOrdersChoADMIN); // Lấy tất cả đơn hàng
//!Xem chi tiết đơn hàng trong OrderDetailController
router.patch('/admin/orders/update/:id', authenticateToken, isAdmin, OrderController.updateOrderStatus); // Cập nhật trạng thái đơn hàng
router.delete('/admin/orders/delete/:id', authenticateToken, isAdmin, OrderController.deleteOrder); // Xóa đơn hàng

module.exports = router;
