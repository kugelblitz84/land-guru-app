import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

import '../models/models.dart';
import 'api_client.dart';

class UploadService extends GetxService {
  UploadService(this._apiClient);

  final ApiClient _apiClient;

  Future<UploadResultPayload> getPresignedUrl({
    required PresignedUrlRequestPayload payload,
  }) async {
    final response = await _apiClient.post(
      '/s3/presign-put',
      data: payload.toJson(),
    );

    final presignData = _unwrapData(response.data);
    if (presignData == null) {
      throw Exception('Invalid presign response');
    }

    final uploadUrl =
        _readFirstString(presignData, 'uploadUrl') ??
        _readFirstString(presignData, 'presignedUrl') ??
        _readFirstString(presignData, 'signedUrl') ??
        _readFirstString(presignData, 'url') ??
        _readFirstString(presignData, 'putUrl');
    if (uploadUrl == null || uploadUrl.isEmpty) {
      throw Exception('Missing upload URL');
    }

    final fileUrl =
        _readFirstString(presignData, 'fileUrl') ??
        _readFirstString(presignData, 'publicUrl') ??
        _readFirstString(presignData, 'location') ??
        _readFirstString(presignData, 'key') ??
        _readFirstString(presignData, 'url') ??
        _stripQuery(uploadUrl);

    return UploadResultPayload(uploadUrl: uploadUrl, fileUrl: fileUrl);
  }

  Future<String> uploadFile({required UploadFilePayload payload}) async {
    final file = payload.file;
    final filename = file.uri.pathSegments.isEmpty
        ? 'upload'
        : file.uri.pathSegments.last;
    final presign = await getPresignedUrl(
      payload: PresignedUrlRequestPayload(
        filename: filename,
        contentType: payload.contentType,
        type: payload.type,
      ),
    );

    final fileLength = await file.length();
    await _apiClient.put(
      presign.uploadUrl,
      data: file.openRead(),
      options: dio.Options(
        headers: {
          'Content-Type': payload.contentType,
          'Content-Length': fileLength,
        },
        extra: {'skipAuth': true},
      ),
    );

    return presign.fileUrl;
  }

  Map<String, dynamic>? _unwrapData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      return data;
    }
    return null;
  }

  String? _readFirstString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
    return null;
  }

  String _stripQuery(String url) {
    final questionIndex = url.indexOf('?');
    if (questionIndex == -1) {
      return url;
    }
    return url.substring(0, questionIndex);
  }
}
