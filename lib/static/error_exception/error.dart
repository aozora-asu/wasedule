import "./status_code.dart";

/// サーバーに関するエラーコード
enum ServerCommonErrorCode implements StatusCode {
  systemError(
    'ER001',
    'システムエラー',
    'エラーが発生しました。しばらくしてもう一度お試しください。\n\n何度か試しても改善しない場合はアプリを再起動してください。',
  ),
  // 400エラー
  badRequestError(
    'ER002',
    'リクエストエラー',
    'リクエストが不正です。',
  ),
  // 403エラー
  forbiddenError(
    'ER003',
    'アクセス権限エラー',
    'アクセス権限がありません。',
  ),
  // 500エラー
  internalServerError(
    'ER004',
    'システムエラー',
    'エラーが発生しました。しばらくしてもう一度お試しください。\n\n何度か試しても改善しない場合はアプリを再起動してください。',
  ),
  ;

  const ServerCommonErrorCode(
    this._errorCode,
    this._errorTitle,
    this._errorMessage,
  );

  final String _errorCode;
  final String _errorTitle;
  final String _errorMessage;

  @override
  String get statusCode => _errorCode;
  @override
  String get statusTitle => _errorTitle;
  @override
  String get statusMessage => _errorMessage;
  static ServerCommonErrorCode? fromCode(String errorCode) =>
      values.firstWhere((element) => element.statusCode == errorCode);
}

class ServerCommonError extends CustomException {
  const ServerCommonError(
    ServerCommonErrorCode super.errorCode, {
    super.info,
  });

  // factoryでエラーから生成する
  factory ServerCommonError.fromCode(String errorCode) {
    final errorInfo = ServerCommonErrorCode.fromCode(errorCode);
    // 取得に失敗した場合、一律システムエラーとする
    if (errorInfo == null) {
      throw const ServerCommonError(ServerCommonErrorCode.systemError);
    }
    return ServerCommonError(errorInfo);
  }
}
