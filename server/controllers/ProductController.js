const Product = require('../models/Product');
const Category = require('../models/Category');
const Target = require('../models/Target');
const ProductColor = require('../models/ProductColor');
const ProductSizeStock = require('../models/ProductSizeStock');
const Promotion = require('../models/Promotion'); // Thêm dòng này
const { getImageLink } = require('../middlewares/ImagesCloudinary_Controller');
const { MongoClient } = require('mongodb');

class ProductController {

    // lấy thông tin sản phẩm theo ID _ khôi đang dùng
    async getProductByID_Flutter(req, res) {
        try {
            const { productID } = req.params;
    
            // Find the product by productID and ensure it is activated
            const product = await Product.findOne({ productID: parseInt(productID), isActivated: true })
                .populate('targetInfo', 'name')
                .populate('categoryInfo', 'name');
    
            if (!product) {
                return res.status(404).json({ message: 'Product not found or not activated' });
            }
    
            // Get colors associated with the product
            const colors = await ProductColor.find({ productID: product.productID });
    
            // Process thumbnail with Cloudinary
            const thumbnail = await getImageLink(product.thumbnail);
    
            // Process colors to include image links and sizes
            const colorsWithDetails = await Promise.all(colors.map(async (color) => {
                const images = await Promise.all(color.images.map(getImageLink));
                const sizes = await ProductSizeStock.find({ colorID: color.colorID }).select('size stock SKU');
                return {
                    ...color.toObject(),
                    images,
                    sizes
                };
            }));
    
            // Calculate total stock
            const totalStock = colorsWithDetails.reduce((total, color) => {
                return total + color.sizes.reduce((sum, size) => sum + size.stock, 0);
            }, 0);
    
            // Check for active promotions
            const currentDate = new Date();
            const activePromotion = await Promotion.findOne({
                $or: [
                    { products: product._id },
                    { categories: product.categoryInfo?.name }
                ],
                startDate: { $lte: currentDate },
                endDate: { $gte: currentDate },
                status: 'active'
            }).sort({ discountPercent: -1 });
    
            const priceNumber = parseInt(product.price.replace(/\./g, ''));
            let promotionDetails = null;
            if (activePromotion) {
                const discountedValue = Math.round(priceNumber * (1 - activePromotion.discountPercent / 100));
                promotionDetails = {
                    name: activePromotion.name,
                    discountPercent: activePromotion.discountPercent,
                    discountedPrice: discountedValue,
                    endDate: activePromotion.endDate
                };
            }
    
            // Construct product details
            const productDetails = {
                _id: product._id,
                productID: product.productID,
                name: product.name,
                targetID: product.targetID,
                description: product.description,
                price: priceNumber,
                categoryID: product.categoryID,
                createdAt: product.createdAt,
                updatedAt: product.updatedAt,
                thumbnail,
                isActivated: product.isActivated,
                colors: colorsWithDetails,
                category: product.categoryInfo.name,
                target: product.targetInfo.name,
                totalStock,
                inStock: totalStock > 0,
                promotion: promotionDetails
            };
    
            res.json(productDetails);
        } catch (error) {
            res.status(500).json({ message: 'Error retrieving product', error: error.message });
        }
    }


    // get product trả về toàn bộ dữ liệu, ko dùng schema
    // Lấy danh sách sản phẩm với phân trang và lọc
    async getProducts(req, res) {
        try {
            // Bước 1: Lấy các tham số từ request (giữ nguyên như cũ)
            const {
                page = 1,
                limit = 12,
                sort = '-createdAt',
                category,
                target,
                minPrice,
                maxPrice,
                search,
                isActivated,
                isAdmin = false,
                inStock,
                colorName,
                size,
            } = req.query;
    
            // Bước 2: Xây dựng match stage cho aggregate
            const matchStage = {};
    
            // Xử lý trạng thái active
            if (typeof isActivated !== 'undefined') {
                matchStage.isActivated = isActivated === 'true';
            } else if (!isAdmin) {
                matchStage.isActivated = true;
            }
    
            // Xử lý target (Nam/Nữ)
            if (target) matchStage.targetID = parseInt(target);
    
            // Xử lý category
            if (category && category !== 'Tất cả') {
                if (isNaN(category)) {
                    const categoryDoc = await Category.findOne({ name: category });
                    if (categoryDoc) matchStage.categoryID = categoryDoc.categoryID;
                } else {
                    matchStage.categoryID = parseInt(category);
                }
            }
    
            // Xử lý khoảng giá
            if (minPrice || maxPrice) {
                matchStage.price = {};
                if (minPrice) matchStage.price.$gte = parseInt(minPrice);
                if (maxPrice) matchStage.price.$lte = parseInt(maxPrice);
            }
    
            // Xử lý tìm kiếm
            if (search) {
                matchStage.name = new RegExp(search, 'i');
            }
    
            // Bước 3: Xây dựng sort stage createAt-desc createAt-asc
            const sortStage = {};
            switch (sort) {
                case 'price-asc': sortStage.price = 1; break;
                case 'price-desc': sortStage.price = -1; break;
                case 'name-asc': sortStage.name = 1; break;
                case 'name-desc': sortStage.name = -1; break;
                case 'stock-asc': sortStage.totalStock = 1; break;
                case 'stock-desc': sortStage.totalStock = -1; break;
                case 'createAt-asc': sortStage.createdAt = 1; break;
                case 'createAt-desc': sortStage.createdAt = -1; break;
                default: sortStage.createdAt = -1;
            }
    
            // Bước 4: Xây dựng pipeline
            const pipeline = [
                // Match stage đầu tiên (giữ nguyên)
                { $match: matchStage },

                // Join với Target (đơn giản hóa)
                {
                    $lookup: {
                        from: 'targets',
                        localField: 'targetID',
                        foreignField: 'targetID',
                        pipeline: [{ $project: { name: 1, _id: 0 } }],
                        as: 'targetInfo'
                    }
                },
                { $unwind: '$targetInfo' },

                // Join với Category (đơn giản hóa)
                {
                    $lookup: {
                        from: 'categories',
                        localField: 'categoryID',
                        foreignField: 'categoryID',
                        pipeline: [{ $project: { name: 1, _id: 0 } }],
                        as: 'categoryInfo'
                    }
                },
                { $unwind: '$categoryInfo' },

                // Join với ProductColor (đơn giản hóa)
                {
                    $lookup: {
                        from: 'product_colors',
                        let: { productID: '$productID' },
                        pipeline: [
                            {
                                $match: {
                                    $expr: { $eq: ['$productID', '$$productID'] }
                                }
                            },
                            {
                                $lookup: {
                                    from: 'product_sizes_stocks',
                                    let: { colorID: '$colorID' },
                                    pipeline: [
                                        {
                                            $match: {
                                                $expr: { $eq: ['$colorID', '$$colorID'] }
                                            }
                                        },
                                        {
                                            $project: {
                                                _id: 0,
                                                size: 1,
                                                stock: 1,
                                                SKU: 1
                                            }
                                        }
                                    ],
                                    as: 'sizes'
                                }
                            },
                            {
                                $project: {
                                    _id: 1,
                                    colorID: 1,
                                    productID: 1,
                                    colorName: 1,
                                    images: 1,
                                    sizes: 1
                                }
                            }
                        ],
                        as: 'colors'
                    }
                },

                // Tính totalStock (giữ nguyên)
                {
                    $addFields: {
                        totalStock: {
                            $reduce: {
                                input: '$colors',
                                initialValue: 0,
                                in: {
                                    $add: [
                                        '$$value',
                                        {
                                            $reduce: {
                                                input: '$$this.sizes',
                                                initialValue: 0,
                                                in: { $add: ['$$value', '$$this.stock'] }
                                            }
                                        }
                                    ]
                                }
                            }
                        }
                    }
                },

                // Join với Promotion (đơn giản hóa)
                {
                    $lookup: {
                        from: 'promotions',
                        let: { productId: '$_id', categoryName: '$categoryInfo.name' },
                        pipeline: [
                            {
                                $match: {
                                    $expr: {
                                        $and: [
                                            {
                                                $or: [
                                                    { $in: ['$$productId', '$products'] },
                                                    { $in: ['$$categoryName', '$categories'] }
                                                ]
                                            },
                                            { $eq: ['$status', 'active'] },
                                            { $lte: ['$startDate', new Date()] },
                                            { $gte: ['$endDate', new Date()] }
                                        ]
                                    }
                                }
                            },
                            {
                                $project: {
                                    name: 1,
                                    discountPercent: 1,
                                    endDate: 1
                                }
                            },
                            { $sort: { discountPercent: -1 } },
                            { $limit: 1 }
                        ],
                        as: 'promotion'
                    }
                },
                { $unwind: { path: '$promotion', preserveNullAndEmptyArrays: true } },

                // Tính discountedPrice
                {
                    $addFields: {
                        'promotion.discountedPrice': {
                            $round: [
                                {
                                    $multiply: [
                                        { $toInt: '$price' },
                                        { $subtract: [1, { $divide: ['$promotion.discountPercent', 100] }] }
                                    ]
                                }
                            ]
                        }
                    }
                },

                // Sort và phân trang (giữ nguyên)
                { $sort: sortStage },
                { $skip: (parseInt(page) - 1) * parseInt(limit) },
                { $limit: parseInt(limit) },

                // Project kết quả cuối cùng (đơn giản hóa)
                {
                    $project: {
                        _id: 1,
                        productID: 1,
                        name: 1,
                        targetID: 1,
                        description: 1,
                        price: 1,
                        categoryID: 1,
                        createdAt: 1,
                        updatedAt: 1,
                        thumbnail: 1,
                        isActivated: 1,
                        colors: 1,
                        category: '$categoryInfo.name',
                        target: '$targetInfo.name',
                        totalStock: 1,
                        inStock: { $gt: ['$totalStock', 0] },
                        promotion: {
                            $cond: {
                                if: '$promotion',
                                then: {
                                    name: '$promotion.name',
                                    discountPercent: '$promotion.discountPercent',
                                    discountedPrice: '$promotion.discountedPrice',
                                    endDate: '$promotion.endDate'
                                },
                                else: null
                            }
                        }
                    }
                }
            ];
    
            // Thực hiện aggregate
            let products = await Product.aggregate(pipeline);
    
            // Xử lý cloudinary links
            products = await Promise.all(
                products.map(async (product) => {
                    // Xử lý thumbnail
                    product.thumbnail = await getImageLink(product.thumbnail);
    
                    // Xử lý images của từng màu
                    product.colors = await Promise.all(
                        product.colors.map(async (color) => {
                            color.images = await Promise.all(
                                color.images.map((img) => getImageLink(img))
                            );
                            return color;
                        })
                    );
    
                    return product;
                })
            );
    
            // Áp dụng các bộ lọc bổ sung
            if (inStock === 'true' || inStock === 'false') {
                const stockFilter = inStock === 'true';
                products = products.filter((product) =>
                    stockFilter ? product.totalStock > 0 : product.totalStock === 0
                );
            }
    
            if (colorName) {
                const colors = colorName.split(',');
                products = products.filter((product) =>
                    product.colors.some((color) => colors.includes(color.colorName))
                );
            }
    
            if (size) {
                const sizes = size.split(',');
                products = products.filter((product) =>
                    product.colors.some((color) =>
                        color.sizes.some((s) => sizes.includes(s.size))
                    )
                );
            }
    
            // Đếm tổng số sản phẩm để phân trang
            const total = await Product.countDocuments(matchStage);
    
            res.json({
                products,
                total,
                totalPages: Math.ceil(total / limit),
                currentPage: parseInt(page)
            });
    
        } catch (error) {
            console.error('Error in getProducts:', error);
            res.status(500).json({
                message: 'Có lỗi xảy ra khi lấy danh sách sản phẩm',
                error: error.message
            });
        }
    }
    
    // Lấy thông tin cơ bản của tất cả sản phẩm (không phân trang)
    async getAllProductsBasicInfo(req, res) {
        try {
            // Lấy tất cả sản phẩm đang hoạt động
            const products = await Product.find({ isActivated: true })
                .populate('targetInfo', 'name')
                .populate('categoryInfo', 'name');

            // Lấy thông tin về màu sắc và kích thước cho từng sản phẩm
            const productsWithDetails = await Promise.all(products.map(async (product) => {
                const colors = await ProductColor.find({ productID: product.productID });
                
                // Tính tổng số lượng tồn kho cho tất cả màu và size
                let totalStock = 0;
                for (const color of colors) {
                    const sizes = await ProductSizeStock.find({ colorID: color.colorID });
                    totalStock += sizes.reduce((sum, size) => sum + size.stock, 0);
                }

                return {
                    _id: product._id,
                    productID: product.productID,
                    name: product.name,
                    price: product.price,
                    category: product.categoryInfo?.name,
                    target: product.targetInfo?.name,
                    thumbnail: product.thumbnail ? await getImageLink(product.thumbnail) : null,
                    colorCount: colors.length,
                    totalStock,
                    inStock: totalStock > 0
                };
            }));

            res.json({
                success: true,
                products: productsWithDetails
            });
        } catch (error) {
            console.error('Error in getAllProductsBasicInfo:', error);
            res.status(500).json({
                message: 'Có lỗi xảy ra khi lấy thông tin sản phẩm',
                error: error.message
            });
        }
    }
    
    // Lấy chi tiết sản phẩm theo ID
    async getProductById(req, res) {
        try {
            const { id } = req.params;
    
            // Lấy thông tin cơ bản của sản phẩm, sử dụng productID thay vì _id
            const product = await Product.findOne({ productID: id })
                .populate('targetInfo', 'name')
                .populate('categoryInfo', 'name');
    
            if (!product) {
                return res.status(404).json({
                    message: 'Không tìm thấy sản phẩm'
                });
            }
    
            // Lấy tất cả màu của sản phẩm
            const colors = await ProductColor.find({ productID: product.productID });
    
            // Xử lý thumbnail bằng Cloudinary
            const thumbnail = product.thumbnail ? await getImageLink(product.thumbnail) : null;
    
            // Lấy thông tin size và tồn kho cho từng màu
            const colorsWithSizes = await Promise.all(colors.map(async (color) => {
                const sizes = await ProductSizeStock.find({ colorID: color.colorID })
                    .select('size stock');
    
                // Xử lý hình ảnh từng màu sắc bằng Cloudinary
                const imagesPromises = color.images.map(async img => await getImageLink(img));
                const images = await Promise.all(imagesPromises);
    
                return {
                    colorID: color.colorID,
                    colorName: color.colorName,
                    images: images || [], // Lưu ảnh đã xử lý từ Cloudinary
                    sizes: sizes.map(size => ({
                        size: size.size,
                        stock: size.stock
                    }))
                };
            }));
    
            // Lấy promotion đang active cho sản phẩm
            const currentDate = new Date();
            const activePromotion = await Promotion.findOne({
                $or: [
                    { products: product._id },
                    { categories: product.categoryInfo.name }
                ],
                startDate: { $lte: currentDate },
                endDate: { $gte: currentDate },
                status: 'active'
            }).sort({ discountPercent: -1 }); // Lấy promotion có giảm giá cao nhất
    
            // Tính giá sau khuyến mãi nếu có
            let discountedPrice = null;
            if (activePromotion) {
                const priceNumber = Number(product.price.toString().replace(/\./g, ''));
                const discountedNumber = Math.round(priceNumber * (1 - activePromotion.discountPercent / 100));
                discountedPrice = discountedNumber.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
            }
    
            // Tạo object chứa thông tin sản phẩm
            const formattedProduct = {
                _id: product._id,
                productID: product.productID,
                name: product.name,
                description: product.description,
                price: product.price,
                category: product.categoryInfo?.name,
                target: product.targetInfo?.name,
                thumbnail: thumbnail, // Ảnh từ Cloudinary
                colors: colorsWithSizes,
                promotion: activePromotion ? {
                    name: activePromotion.name,
                    description: activePromotion.description,
                    discountPercent: activePromotion.discountPercent,
                    discountedPrice: discountedPrice,
                    endDate: activePromotion.endDate
                } : null,
                // Tính tổng số lượng tồn kho
                totalStock: colorsWithSizes.reduce((total, color) =>
                    total + color.sizes.reduce((sum, size) => sum + size.stock, 0), 0),
                availableSizes: [...new Set(colorsWithSizes.flatMap(color =>
                    color.sizes.map(size => size.size)
                ))].sort(),
                availableColors: colorsWithSizes.map(color => color.colorName)
            };
    
            res.json({
                success: true,
                product: formattedProduct
            });
        } catch (error) {
            console.error('Error in getProductById:', error);
            res.status(500).json({
                message: 'Có lỗi xảy ra khi lấy chi tiết sản phẩm',
                error: error.message
            });
        }
    }

    async getProductBySKU(req, res) {
        try {
            const { SKU } = req.params; // Assuming SKU is passed as a route parameter
    
            // Find the product size stock by SKU
            const sizeStock = await ProductSizeStock.findOne({ SKU });
    
            if (!sizeStock) {
                return res.status(404).json({ message: 'Stock not found for the given SKU' });
            }
    
            // Return the stock information
            res.json({
                SKU: sizeStock.SKU,
                size: sizeStock.size,
                stock: sizeStock.stock
            });
        } catch (error) {
            res.status(500).json({ message: 'Error retrieving stock', error: error.message });
        }
    }

    // Lấy sản phẩm theo giới tính (Nam/Nữ) với bộ lọc nâng cao
    async getProductsByGender(req, res) {
        try {
            const {
                targetID,
                page = 1,
                limit = 12,
                sort = '-createdAt',
                categories, // Nhận danh sách categories dạng string phân cách bằng dấu phẩy
                minPrice,
                maxPrice,
                search,
            } = req.query;

            // Xây dựng query cơ bản
            const baseQuery = { 
                isActivated: true,
                targetID: parseInt(targetID)
            };

            // Xử lý lọc theo nhiều danh mục
            if (categories && categories !== '') {
                const categoryNames = categories.split(',');
                const categoryDocs = await Category.find({ 
                    name: { $in: categoryNames } 
                });
                
                if (categoryDocs.length > 0) {
                    const categoryIDs = categoryDocs.map(cat => cat.categoryID);
                    baseQuery.categoryID = { $in: categoryIDs };
                }
            }

            // Xử lý lọc theo khoảng giá
            if (minPrice || maxPrice) {
                baseQuery.price = {};
                if (minPrice) baseQuery.price.$gte = parseInt(minPrice);
                if (maxPrice) baseQuery.price.$lte = parseInt(maxPrice);
            }

            // Xử lý tìm kiếm theo tên
            if (search) {
                baseQuery.$text = { $search: search };
            }

            // Thực hiện query với phân trang
            const products = await Product.find(baseQuery)
                .sort(sort)
                .skip((page - 1) * limit)
                .limit(parseInt(limit))
                .populate('categoryInfo')
                .populate('targetInfo');

            // Lấy ngày hiện tại để kiểm tra khuyến mãi
            const currentDate = new Date();

            // Xử lý thông tin chi tiết cho từng sản phẩm
            const enhancedProducts = await Promise.all(products.map(async (product) => {
                // Lấy thông tin màu sắc và kích thước
                const colors = await ProductColor.find({ productID: product.productID });
                const colorsWithSizes = await Promise.all(colors.map(async (color) => {
                    const sizes = await ProductSizeStock.find({ colorID: color.colorID });
                    
                    // Xử lý images cho từng màu sắc sử dụng cloudinary
                    const imagesPromises = color.images.map(async img => await getImageLink(img));
                    const images = await Promise.all(imagesPromises);

                    return {
                        ...color.toObject(),
                        images: images || [], // Thêm mảng images đã xử lý
                        sizes
                    };
                }));

                // Tính tổng tồn kho
                const totalStock = colorsWithSizes.reduce((total, color) => (
                    total + color.sizes.reduce((sum, size) => sum + size.stock, 0)
                ), 0);

                // Tìm khuyến mãi áp dụng
                const activePromotion = await Promotion.findOne({
                    $or: [
                        { products: product._id },
                        { categories: product.categoryInfo.name }
                    ],
                    startDate: { $lte: currentDate },
                    endDate: { $gte: currentDate },
                    status: 'active'
                }).sort({ discountPercent: -1 });

                // Tính toán giá khuyến mãi
                let promotionDetails = null;
                if (activePromotion) {
                    const priceNumber = parseInt(product.price.replace(/\./g, ''));
                    const discountedValue = Math.round(priceNumber * (1 - activePromotion.discountPercent / 100));
                    promotionDetails = {
                        name: activePromotion.name,
                        discountPercent: activePromotion.discountPercent,
                        discountedPrice: discountedValue.toLocaleString('vi-VN'),
                        endDate: activePromotion.endDate
                    };
                }

                return {
                    ...product.toObject(),
                    category: product.categoryInfo.name,
                    thumbnail: await getImageLink(product.thumbnail), // Xử lý thumbnail với cloudinary
                    colors: colorsWithSizes,
                    inStock: totalStock > 0,
                    promotion: promotionDetails
                };
            }));

            // Tính toán phân trang
            const total = await Product.countDocuments(baseQuery);
            const totalPages = Math.ceil(total / limit);

            res.json({
                success: true,
                data: {
                    products: enhancedProducts,
                    pagination: {
                        total,
                        totalPages,
                        currentPage: parseInt(page),
                        pageSize: parseInt(limit)
                    }
                }
            });

        } catch (error) {
            console.error('Error in getProductsByGender:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
                error: error.message
            });
        }
    }

    //!ADMIN
    // Thêm method để lấy tất cả sản phẩm được nhóm theo danh mục
    async getAllProductsByCategories(req, res) {
        try {
            // Lấy tất cả danh mục
            const categories = await Category.find().sort({ categoryID: 1 });

            // Lấy ngày hiện tại để kiểm tra khuyến mãi
            const currentDate = new Date();

            // Xử lý từng danh mục và sản phẩm của nó
            const categoriesWithProducts = await Promise.all(
                categories.map(async (category) => {
                // Lấy sản phẩm theo danh mục
                const products = await Product.find({
                    categoryID: category.categoryID,
                        isActivated: true,
                })
                        .populate("targetInfo", "name")
                    .sort({ createdAt: -1 }); // Sắp xếp theo thời gian tạo mới nhất

                // Xử lý chi tiết cho từng sản phẩm
                    const enhancedProducts = await Promise.all(
                        products.map(async (product) => {
                    // Lấy thông tin màu sắc và kích thước
                            const colors = await ProductColor.find({
                                productID: product.productID,
                            });
                            const colorsWithSizes = await Promise.all(
                                colors.map(async (color) => {
                                    const sizes = await ProductSizeStock.find({
                                        colorID: color.colorID,
                                    });
                        return {
                            colorID: color.colorID,
                            colorName: color.colorName,
                                        sizes: sizes.map((size) => ({
                                size: size.size,
                                            stock: size.stock,
                                        })),
                        };
                                })
                            );

                    // Tính tổng tồn kho
                            const totalStock = colorsWithSizes.reduce(
                                (total, color) =>
                                    total +
                                    color.sizes.reduce((sum, size) => sum + size.stock, 0),
                                0
                            );

                    // Tìm khuyến mãi đang áp dụng
                    const activePromotion = await Promotion.findOne({
                                $or: [{ products: product._id }, { categories: category.name }],
                        startDate: { $lte: currentDate },
                        endDate: { $gte: currentDate },
                                status: "active",
                    }).sort({ discountPercent: -1 });

                    // Tính giá sau khuyến mãi
                    let promotionDetails = null;
                    if (activePromotion) {
                                const priceNumber = parseInt(product.price.replace(/\./g, ""));
                                const discountedValue = Math.round(
                                    priceNumber * (1 - activePromotion.discountPercent / 100)
                                );
                        promotionDetails = {
                            name: activePromotion.name,
                            discountPercent: activePromotion.discountPercent,
                                    discountedPrice: discountedValue.toLocaleString("vi-VN"),
                                    endDate: activePromotion.endDate,
                        };
                    }

                    return {
                        productID: product.productID,
                        name: product.name,
                        price: product.price,
                        thumbnail: await getImageLink(product.thumbnail),
                        target: product.targetInfo.name,
                        totalStock,
                        inStock: totalStock > 0,
                                promotion: promotionDetails,
                    };
                        })
                    );

                // Thống kê cho danh mục
                const categoryStats = {
                    totalProducts: enhancedProducts.length,
                        inStockProducts: enhancedProducts.filter((p) => p.inStock).length,
                        outOfStockProducts: enhancedProducts.filter((p) => !p.inStock)
                            .length,
                        productsOnPromotion: enhancedProducts.filter((p) => p.promotion)
                            .length,
                };

                return {
                    categoryID: category.categoryID,
                    name: category.name,
                    description: category.description,
                    imageURL: await getImageLink(category.imageURL),
                    stats: categoryStats,
                        products: enhancedProducts,
                };
                })
            );

            res.json({
                success: true,
                categories: categoriesWithProducts,
            });
        } catch (error) {
            console.error("Error in getAllProductsByCategories:", error);
            res.status(500).json({
                success: false,
                message: "Có lỗi xảy ra khi lấy danh sách sản phẩm theo danh mục",
                error: error.message,
            });
        }
    }

    //!ADMIN
    // Lấy danh sách sản phẩm cho ADMIN bao gồm
    // "product" + "stats : tổng sp , sp nam , sp nữ"
    async getProductsChoADMIN(req, res) {
        try {
            // Sử dụng aggregation để lấy và chuyển đổi dữ liệu trực tiếp
            const products = await Product.aggregate([
                {
                    $lookup: {
                        from: "categories",
                        localField: "categoryID",
                        foreignField: "categoryID",
                        as: "category",
                    },
                },
                {
                    $lookup: {
                        from: "targets",
                        localField: "targetID",
                        foreignField: "targetID",
                        as: "target",
                    },
                },
                {
                    $project: {
                        _id: 1,
                        productID: 1,
                        name: 1,
                        price: 1,
                        createdAt: 1,
                        thumbnail: 1,
                        inStock: 1,
                        isActivated: 1,
                        category: { $arrayElemAt: ["$category.name", 0] },
                        target: { $arrayElemAt: ["$target.name", 0] },
                        description: 1,
                    },
                },
            ]);

            // Xử lý thumbnail với Cloudinary
            const productsWithCloudinary = await Promise.all(
                products.map(async (product) => ({
                ...product,
                    thumbnail: await getImageLink(product.thumbnail),
                }))
            );

            // Tính toán thống kê
            const stats = {
                totalMaleProducts: products.filter((p) => p.target === "Nam").length,
                totalFemaleProducts: products.filter((p) => p.target === "Nữ").length,
                totalDeactivatedProducts: products.filter((p) => !p.isActivated).length,
                total: products.length,
            };

            res.json({
                products: productsWithCloudinary,
                stats,
            });
        } catch (error) {
            console.log(error);
            res.status(500).json({
                message: "Có lỗi xảy ra khi lấy danh sách sản phẩm",
                error: error.message,
            });
        }
    }

    //!ADMIN
    // Lấy chi tiết sản phẩm theo ID có cloudinary
    async getProductByIdChoADMIN(req, res) {
        try {
            const { id } = req.params;

            // Lấy thông tin cơ bản của sản phẩm, sử dụng productID thay vì _id
            const product = await Product.findOne({ productID: id })
                .populate("targetInfo", "name")
                .populate("categoryInfo", "name");

            if (!product) {
                return res.status(404).json({
                    message: "Không tìm thấy sản phẩm",
                });
            }

            // Lấy tất cả màu của sản phẩm
            const colors = await ProductColor.find({ productID: product.productID });

            // Lấy thông tin size và tồn kho cho từng màu
            const colorsWithSizes = await Promise.all(
                colors.map(async (color) => {
                    const sizes = await ProductSizeStock.find({
                        colorID: color.colorID,
                    }).select("size stock SKU");

                    // Xử lý hình ảnh cho từng màu sắc
                    const imagesPromises = color.images.map(
                        async (img) => await getImageLink(img)
                    );
                    const images = await Promise.all(imagesPromises);

                    return {
                        colorID: color.colorID,
                        colorName: color.colorName,
                        images: images || [],
                        sizes: sizes.map((size) => ({
                            size: size.size,
                            stock: size.stock,
                            SKU: size.SKU
                        })),
                    };
                })
            );

            // Lấy promotion đang active cho sản phẩm
            const currentDate = new Date();
            const activePromotion = await Promotion.findOne({
                $or: [
                    { products: product._id },
                    { categories: product.categoryInfo.name },
                ],
                startDate: { $lte: currentDate },
                endDate: { $gte: currentDate },
                status: "active",
            }).sort({ discountPercent: -1 }); // Lấy promotion có giảm giá cao nhất

            // Tính giá sau khuyến mãi nếu có
            let discountedPrice = null;
            if (activePromotion) {
                // Chuyển đổi giá từ string sang number, loại bỏ dấu chấm
                const priceNumber = Number(product.price.replace(/\./g, ""));
                // Tính toán giá sau khuyến mãi
                const discountedNumber = Math.round(
                    priceNumber * (1 - activePromotion.discountPercent / 100)
                );
                // Chuyển đổi lại thành định dạng VN
                discountedPrice = discountedNumber
                    .toString()
                    .replace(/\B(?=(\d{3})+(?!\d))/g, ".");
            }

            // Format lại dữ liệu trước khi gửi về client
            const formattedProduct = {
                _id: product._id,
                productID: product.productID,
                name: product.name,
                description: product.description,
                price: product.price,
                category: product.categoryInfo?.name,
                target: product.targetInfo?.name,
                thumbnail: await getImageLink(product.thumbnail),
                colors: colorsWithSizes,
                promotion: activePromotion
                    ? {
                    name: activePromotion.name,
                    description: activePromotion.description,
                    discountPercent: activePromotion.discountPercent,
                    discountedPrice: discountedPrice,
                        endDate: activePromotion.endDate,
                    }
                    : null,
                // Tính toán các thông tin bổ sung
                totalStock: colorsWithSizes.reduce(
                    (total, color) =>
                        total + color.sizes.reduce((sum, size) => sum + size.stock, 0),
                    0
                ),
                availableSizes: [
                    ...new Set(
                        colorsWithSizes.flatMap((color) =>
                            color.sizes.map((size) => size.size)
                        )
                    ),
                ].sort(),
                availableColors: colorsWithSizes.map((color) => color.colorName),
            };

            res.json({
                success: true,
                product: formattedProduct,
            });
        } catch (error) {
            console.error("Error in getProductById:", error);
            res.status(500).json({
                message: "Có lỗi xảy ra khi lấy chi tiết sản phẩm",
                error: error.message,
            });
        }
    }

    //!ADMIN
    // Cập nhật sản phẩm
    async updateProduct(req, res) {
        try {
            const { id } = req.params;
            const updateData = req.body;
            const thumbnailFile = req.files?.thumbnail;

            // Kiểm tra sản phẩm tồn tại
            const product = await Product.findOne({ productID: id });
            if (!product) {
                return res.status(404).json({ message: "Không tìm thấy sản phẩm" });
            }

            // Nếu cập nhật target hoặc category, kiểm tra tồn tại
            if (updateData.targetID || updateData.categoryID) {
                const [target, category] = await Promise.all([
                    updateData.targetID
                        ? Target.findOne({ targetID: updateData.targetID })
                        : Promise.resolve(true),
                    updateData.categoryID
                        ? Category.findOne({ categoryID: updateData.categoryID })
                        : Promise.resolve(true),
                ]);

                if (!target || !category) {
                    return res.status(400).json({
                        message: "Target hoặc Category không tồn tại",
                    });
                }
            }

            // Xử lý upload thumbnail mới nếu có
            if (thumbnailFile) {
                const thumbnailResult = await uploadImage(thumbnailFile);
                if (!thumbnailResult.success) {
                    return res.status(400).json({
                        message: "Lỗi khi upload ảnh thumbnail",
                    });
                }
                updateData.thumbnail = thumbnailResult.publicId;
            }

            // Chỉ cập nhật các thông tin chung của sản phẩm
            const allowedUpdates = {
                name: updateData.name,
                description: updateData.description,
                price: updateData.price,
                targetID: updateData.targetID,
                categoryID: updateData.categoryID,
                isActivated: updateData.isActivated,
                thumbnail: updateData.thumbnail, // Thêm thumbnail vào danh sách cập nhật
            };

            // Lọc bỏ các giá trị undefined
            Object.keys(allowedUpdates).forEach(
                (key) => allowedUpdates[key] === undefined && delete allowedUpdates[key]
            );

            // Cập nhật thông tin sản phẩm
            Object.assign(product, allowedUpdates);
            await product.save();

            // Lấy sản phẩm đã cập nhật với đầy đủ thông tin
            const updatedProduct = await Product.findOne({ productID: id })
                .populate("targetInfo", "name")
                .populate("categoryInfo", "name");

            // Xử lý thumbnail URL trước khi trả về
            const productWithThumbnail = {
                ...updatedProduct.toObject(),
                thumbnail: await getImageLink(updatedProduct.thumbnail),
            };

            res.json({
                message: "Cập nhật sản phẩm thành công",
                product: productWithThumbnail,
            });
        } catch (error) {
            res.status(500).json({
                message: "Có lỗi xảy ra khi cập nhật sản phẩm",
                error: error.message,
            });
        }
    }

    //!ADMIN
    // Tạo sản phẩm mới
    async createProduct(req, res) {
        try {
            console.log("=== DEBUG CREATE PRODUCT ===");
            console.log("Request body:", req.body);

            const {
                name,
                price,
                description,
                thumbnail,
                categoryID,
                targetID,
                colors,
            } = req.body;

            // Kiểm tra dữ liệu đầu vào
            if (
                !name ||
                !price ||
                !description ||
                !thumbnail ||
                !categoryID ||
                !targetID
            ) {
                return res.status(400).json({
                    message: "Vui lòng điền đầy đủ thông tin sản phẩm",
                });
            }

            // Kiểm tra target và category tồn tại
            const [target, category] = await Promise.all([
                Target.findOne({ targetID: targetID }),
                Category.findOne({ categoryID: categoryID }),
            ]);

            if (!target || !category) {
                return res.status(400).json({
                    message: "Target hoặc Category không tồn tại",
                });
            }

            // Tạo productID mới
            const lastProduct = await Product.findOne().sort({ productID: -1 });
            const newProductID = lastProduct ? lastProduct.productID + 1 : 1;

            // Tạo sản phẩm mới
            const newProduct = new Product({
                productID: newProductID,
                name,
                price: Number(price),
                description,
                thumbnail,
                categoryID: category.categoryID,
                targetID: target.targetID,
                isActivated: true,
            });

            // Lưu sản phẩm
            const savedProduct = await newProduct.save();
            console.log("Saved product:", savedProduct);

            // Xử lý màu sắc và size nếu có
            if (colors && colors.length > 0) {
                // Tạo colorID mới
                const lastColor = await ProductColor.findOne().sort({ colorID: -1 });
                let nextColorID = lastColor ? lastColor.colorID + 1 : 1;

                // Tìm sizeStockID cuối cùng
                const lastSizeStock = await ProductSizeStock.findOne().sort({
                    sizeStockID: -1,
                });
                let nextSizeStockID = lastSizeStock ? lastSizeStock.sizeStockID + 1 : 1;

                for (const color of colors) {
                    // Tạo màu mới
                    const newColor = new ProductColor({
                        colorID: nextColorID,
                        productID: newProductID,
                        colorName: color.colorName,
                        images: color.images,
                    });
                    const savedColor = await newColor.save();

                    // Tạo size stocks cho màu này
                    if (color.sizes && color.sizes.length > 0) {
                        const sizeStocks = color.sizes.map((size) => {
                            const sizeStockID = nextSizeStockID++;
                            return {
                                sizeStockID,
                                SKU: `${newProductID}_${nextColorID}_${size.size}_${sizeStockID}`,
                                colorID: savedColor.colorID,
                                size: size.size,
                                stock: size.stock,
                            };
                        });

                        await ProductSizeStock.insertMany(sizeStocks);
                    }

                    nextColorID++;
                }
            }

            // Lấy sản phẩm đã tạo với đầy đủ thông tin
            const createdProduct = await Product.findOne({ productID: newProductID })
                .populate("targetInfo", "name")
                .populate("categoryInfo", "name");

            // Xử lý thumbnail URL trước khi trả về
            const productWithThumbnail = {
                ...createdProduct.toObject(),
                thumbnail: await getImageLink(createdProduct.thumbnail),
            };

            console.log("=== END DEBUG ===");

            res.status(201).json({
                message: "Thêm sản phẩm mới thành công",
                product: productWithThumbnail,
            });
        } catch (error) {
            console.error("Error in createProduct:", error);
            res.status(500).json({
                message: "Có lỗi xảy ra khi thêm sản phẩm mới",
                error: error.message,
            });
        }
    }

    //!Toàn thêm
    // Xóa sản phẩm
    async deleteProduct(req, res) {
        try {
            const { id } = req.params;

            // Tìm sản phẩm
            const product = await Product.findOne({ productID: id });
            if (!product) {
                return res.status(404).json({ message: "Không tìm thấy sản phẩm" });
            }

            // Tìm tất cả colorID của sản phẩm trước khi xóa
            const colors = await ProductColor.find({ productID: id });
            const colorIDs = colors.map((color) => color.colorID);

            // Xóa tất cả size-stock liên quan đến các màu
            await ProductSizeStock.deleteMany({ colorID: { $in: colorIDs } });

            // Xóa tất cả màu sắc liên quan
            await ProductColor.deleteMany({ productID: id });

            // Xóa sản phẩm chính
            await Product.deleteOne({ productID: id });

            res.json({
                message: "Đã xóa hoàn toàn sản phẩm và dữ liệu liên quan",
            });
        } catch (error) {
            console.error("Error in deleteProduct:", error);
            res.status(500).json({
                message: "Có lỗi xảy ra khi xóa sản phẩm",
                error: error.message,
            });
        }
    }

    //!ADMIN
    // Kích hoạt/Vô hiệu hóa sản phẩm
    async toggleProductStatus(req, res) {
        try {
            const { id } = req.params;

            // Tìm sản phẩm
            const product = await Product.findOne({ productID: id });
            if (!product) {
                return res.status(404).json({ message: "Không tìm thấy sản phẩm" });
            }

            // Đảo ngược trạng thái isActivated
            product.isActivated = !product.isActivated;
            await product.save();

            res.json({
                message: `Đã ${product.isActivated ? "kích hoạt" : "vô hiệu hóa"
                    } sản phẩm thành công`,
                isActivated: product.isActivated,
            });
        } catch (error) {
            console.error("Error in toggleProductStatus:", error);
            res.status(500).json({
                message: "Có lỗi xảy ra khi thay đổi trạng thái sản phẩm",
                error: error.message,
            });
        }
    }
}

module.exports = new ProductController();