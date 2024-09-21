import "./status_code.dart";

/// サーバーに関するエラーコード
enum CommonExceptionCode implements StatusCode {
  systemException(
    'EX001',
    'システムエラー',
    'エラーが発生しました。しばらくしてもう一度お試しください。\n\n何度か試しても改善しない場合はアプリを再起動してください。',
  ),
  indexException(
    'EX002',
    'インデックスエラー',
    '予期しないインデックスアクセスです',
  ),
  ;

  const CommonExceptionCode(
    this._exceptionCode,
    this._exceptionTitle,
    this._exceptionMessage,
  );

  final String _exceptionCode;
  final String _exceptionTitle;
  final String _exceptionMessage;

  @override
  String get statusCode => _exceptionCode;
  @override
  String get statusTitle => _exceptionTitle;
  @override
  String get statusMessage => _exceptionMessage;
  static CommonExceptionCode? fromCode(String exceptionCode) =>
      values.firstWhere((element) => element.statusCode == exceptionCode);
}

class CommonException extends CustomException {
  const CommonException(
    CommonExceptionCode super.exceptionCode, {
    super.info,
  });

  // factoryでエラーから生成する
  factory CommonException.fromCode(String exceptionCode) {
    final exceptionInfo = CommonExceptionCode.fromCode(exceptionCode);
    // 取得に失敗した場合、一律システムエラーとする
    if (exceptionInfo == null) {
      throw const CommonException(CommonExceptionCode.systemException);
    }
    return CommonException(exceptionInfo);
  }
}
