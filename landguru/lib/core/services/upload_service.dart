import 'dart:io';

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

    final uploadUrl = _readFirstString(presignData, [
      'uploadUrl',
      'presignedUrl',
      'signedUrl',
      'url',
      'putUrl',
    ]);
    if (uploadUrl == null || uploadUrl.isEmpty) {
      throw Exception('Missing upload URL');
    }

    final fileUrl =
        _readFirstString(presignData, [
          'fileUrl',
          'publicUrl',
          'location',
          'key',
          'url',
        ]) ??
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
    final uploadClient = dio.Dio();

    await uploadClient.put(
      presign.uploadUrl,
      data: file.openRead(),
      options: dio.Options(
        headers: {
          'Content-Type': payload.contentType,
          'Content-Length': fileLength,
        },
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

  String? _readFirstString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
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
