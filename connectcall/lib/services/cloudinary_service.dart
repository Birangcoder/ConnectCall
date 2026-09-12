import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/config/app_config.dart';

class CloudinaryService {
  CloudinaryService._();

  static final CloudinaryService instance = CloudinaryService._();

  Future<String> uploadProfileImage(XFile image) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/'
      '${AppConfig.cloudinaryCloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = AppConfig.cloudinaryUploadPreset;

    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    final data = jsonDecode(responseBody) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = data['error'];

      throw Exception(
        error is Map
            ? error['message']?.toString() ?? 'Cloudinary upload failed'
            : 'Cloudinary upload failed',
      );
    }

    final secureUrl = data['secure_url']?.toString();

    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary did not return an image URL.');
    }

    return secureUrl;
  }
}
