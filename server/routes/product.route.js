const express = require('express');
const router = express.Router();
const multer = require('multer');
const ProductController = require('../controllers/ProductController');
const { authenticateToken, isAdmin } = require('../middlewares/auth.middleware');
const { uploadFile, getImageLink } = require('../middlewares/ImagesCloudinary_Controller');


//!ADMIN ( DASHBOARD )
router.get('/all-by-categories', ProductController.getAllProductsByCategories);

//!CUSTOMER
// Routes cho người dùng (khôi dùng hết)

router.get('/', ProductController.getProducts); // Lấy danh sách sản phẩm (có phân trang và lọc)
router.get('/basic', ProductController.getAllProductsBasicInfo); // Lấy thông tin cơ bản của tất cả sản phẩm (không phân trang)
router.get('/gender', ProductController.getProductsByGender); // Lấy sản phẩm theo giới tính
router.get('/:id', ProductController.getProductById); // Lấy chi tiết sản phẩm
router.get('/flutter/:productID', ProductController.getProductByID_Flutter); // Lấy chi tiết sản phẩm theo ID _ khôi đang dùng
router.get('/stock/:SKU', ProductController.getProductBySKU); // Lấy chi tiết sản phẩm theo SKU



//!ADMIN
router.get('/admin/products', authenticateToken, isAdmin, ProductController.getProductsChoADMIN); // Lấy danh sách sản phẩm cho admin
router.get('/admin/products/:id', authenticateToken, isAdmin, ProductController.getProductByIdChoADMIN); // Lấy chi tiết sản phẩm theo ID cho admin
router.put('/admin/products/update/:id', authenticateToken, isAdmin, ProductController.updateProduct); // Cập nhật THÔNG TIN CƠ BẢN sản phẩm
//!ADMIN CALL THÊM /api/product-size-stock ĐỂ CHỈNH TỒN KHO
router.post('/admin/products/create', authenticateToken, isAdmin, ProductController.createProduct); // Tạo sản phẩm mới
router.delete('/admin/products/delete/:id', authenticateToken, isAdmin, ProductController.deleteProduct); // Xóa sản phẩm ( xoá hoàn toàn)
router.patch('/admin/products/toggle/:id', authenticateToken, isAdmin, ProductController.toggleProductStatus); // Khôi phục sản phẩm 

// Cấu hình multer để lưu file tạm thời
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, './public/uploads/uploadPendingImages/');
    },
    filename: function (req, file, cb) {
        // Tạo chuỗi ngẫu nhiên 5 ký tự
        const randomString = Math.random().toString(36).substring(2, 7);
        cb(null, randomString);
    }
});

const upload = multer({ storage: storage });
// Route xử lý upload ảnh (thêm mới)
router.post('/admin/products/upload-images', 
    authenticateToken, 
    isAdmin, 
    upload.array('images'), 
    async (req, res) => {
        try {
            const files = req.files;
            const imageUrls = [];
            
            // Upload từng file lên Cloudinary
            for (const file of files) {
                const publicId = await uploadFile(file.path);
                const imageUrl = await getImageLink(publicId);
                imageUrls.push(imageUrl);
            }

            res.json({
                success: true,
                imageUrls
            });
        } catch (error) {
            console.error('Error uploading images:', error);
            res.status(500).json({
                success: false,
                message: 'Lỗi khi upload ảnh'
            });
        }
    }
);

module.exports = router;
