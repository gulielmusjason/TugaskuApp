import 'package:cloudinary/cloudinary.dart';
import 'package:file_picker/file_picker.dart';

class CloudinaryService {
  final cloudinary = Cloudinary.signedConfig(
    apiKey: '897871819684185',
    apiSecret: 'O_vdy8Hf2TpwcY7VPs2uv-65npg',
    cloudName: 'dbv6a5mrg',
  );

  Future<String?> uploadFile({
    required PlatformFile file,
    required String folder,
  }) async {
    try {
      final response = await cloudinary.upload(
        file: file.path!,
        resourceType: CloudinaryResourceType.auto,
        folder: folder,
        fileName: '${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      );

      if (response.isSuccessful) {
        return response.secureUrl;
      } else {
        throw Exception('Upload gagal: ${response.error}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
