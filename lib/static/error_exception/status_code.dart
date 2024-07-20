abstract class StatusCode {
  const StatusCode();
  String get statusCode;
  String get statusTitle;
  String get statusMessage;
}

abstract class CustomException implements Exception {
  const CustomException(
    this.statusCode, {
    this.info,
  });

  final StatusCode statusCode;
  final dynamic info;

  @override
  String toString() {
    return 'CustomException{statusCode: ${statusCode.statusCode}, title: ${statusCode.statusTitle}, message: ${statusCode.statusMessage}, info: $info}';
  }
}
