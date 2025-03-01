const express = require('express');
const router = express.Router();
const UserController = require('../controllers/UserController');
const { authenticateToken, isAdmin } = require('../middlewares/auth.middleware');
const multer = require('multer');
const path = require('path');

// Configure multer for avatar uploads
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, path.join(__dirname, '../public/uploads/uploadPendingImages'));
    },
    filename: function (req, file, cb) {
      cb(null, Date.now() + '-' + file.originalname);
    }
});
  
const upload = multer({ storage: storage });

// Routes cho người dùng (khôi dùng hết)
router.get('/profile', authenticateToken, UserController.getProfile); // Lấy thông tin cá nhân
router.put('/profile', authenticateToken, UserController.updateProfile); // Cập nhật thông tin cá nhân
router.put('/change-password', authenticateToken, UserController.changePassword); // Đổi mật khẩu
router.post('/upload-avatar', authenticateToken, upload.single('avatar'), UserController.uploadAvatar);

//!ADMIN
router.get('/admin/users', authenticateToken, isAdmin, UserController.getUsersChoADMIN); // Lấy danh sách người dùng cho admin
router.put('/admin/users/:id', authenticateToken, isAdmin, UserController.updateUser); // Cập nhật thông tin người dùng
router.patch('/admin/users/toggle/:id', authenticateToken, isAdmin, UserController.toggleUserStatus); // Vô hiệu hóa/Kích hoạt tài khoản

module.exports = router;
