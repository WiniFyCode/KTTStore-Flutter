const cloudinary = require('cloudinary').v2;
const fs = require('fs');
const path = require('path');

// Cấu hình Cloudinary
cloudinary.config({
  cloud_name: 'djh8j3ofk',
  api_key: '747932665488779',
  api_secret: '7elw2YlkaF6T0VemR-DBfQdhkfA'
});

// Hàm tải lên file lên Cloudinary
async function uploadFile(file) {
  try {
    const fileName = path.parse(file).name; // Lấy tên file mà không có phần mở rộng
    const options = {
      public_id: fileName
    };

    const uploadResult = await cloudinary.uploader.upload(file, options);
    console.log(`Đã tải lên thành công: ${uploadResult.public_id}`);

    // Di chuyển file từ thư mục uploadPendingImages sang thư mục 'products'
    const destinationPath = './public/uploads/products/' + fileName;
    fs.renameSync(file, destinationPath);
    console.log(`Đã dời file thành công đến thư mục 'products'`);

    return uploadResult.public_id;
  } catch (error) {
    console.error('Lỗi khi tải lên:', error);
    throw error;
  }
}

// Thư mục chứa các tập tin cần tải lên
const directoryPath = './public/uploads/uploadPendingImages';

// Đọc danh sách tập tin trong thư mục
async function uploadImagesInUploadPendingImages() {
  fs.readdir(directoryPath, async (err, files) => {
    if (err) {
      console.error('Lỗi khi đọc thư mục:', err);
      return;
    }

    // Duyệt qua từng tập tin và tải lên Cloudinary
    for (const file of files) {
      const filePath = path.join(directoryPath, file);
      const publicId = await uploadFile(filePath);
      console.log(`Đã tải lên ${file}: ${publicId}`);
    }
  });
}

async function getImageLink(publicId) {
  try {
    const imageUrl = await cloudinary.url(publicId);
    //console.log(`Đường link cho ảnh đã upload là: ${imageUrl}`);
    return imageUrl;
  } catch (error) {
    console.error('Đã xảy ra lỗi khi lấy đường link ảnh:', error);
    throw error;
  }
}


// Hàm tải lên avatar người dùng
// Hàm tải lên avatar người dùng
async function uploadUserAvatar(filePath, userID, oldAvatar) {
  try {
    const publicId = `${userID}_${Date.now()}`; // Đặt publicId là userID_Date.now()

    // Kiểm tra và xóa ảnh avatar cũ nếu tồn tại
    if (oldAvatar) {
      try {
        await cloudinary.uploader.destroy(oldAvatar);
        console.log(`Đã xóa ảnh cũ: ${oldAvatar}`);
      } catch (error) {
        console.error('Lỗi khi xóa ảnh cũ:', error);
      }
    }

    // Tải ảnh mới lên Cloudinary
    const uploadResult = await cloudinary.uploader.upload(filePath, { public_id: publicId });
    console.log(`Tải lên thành công: ${uploadResult.public_id}`);

    // Xóa ảnh ở local
    fs.unlink(filePath, (err) => {
      if (err) {
        console.error('Lỗi khi xóa file:', err);
      } else {
        console.log(`Đã xóa file local: ${filePath}`);
      }
    });

    return publicId;
  } catch (error) {
    console.error('Lỗi khi tải lên avatar:', error);
    return null;
  }
}

module.exports = {
  uploadImagesInUploadPendingImages,
  getImageLink,
  uploadFile,
  uploadUserAvatar
}