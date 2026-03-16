import 'dart:io';

class PresignedUrlRequestPayload {
  const PresignedUrlRequestPayload({
    required this.filename,
    required this.contentType,
    required this.type,
  });

  final String filename;
  final String contentType;
  final String type;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'filename': filename,
      'contentType': contentType,
      'type': type,
    };
  }
}

class UploadFilePayload {
  const UploadFilePayload({
    required this.file,
    required this.contentType,
    required this.type,
  });

  final File file;
  final String contentType;
  final String type;
}

class UploadResultPayload {
  const UploadResultPayload({required this.uploadUrl, required this.fileUrl});

  final String uploadUrl;
  final String fileUrl;
}
