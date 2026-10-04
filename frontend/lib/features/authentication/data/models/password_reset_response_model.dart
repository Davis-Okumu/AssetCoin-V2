class PasswordResetResponseModel {
  final String message;
  final String? resetToken;

  const PasswordResetResponseModel({
    required this.message,
    this.resetToken,
  });

  factory PasswordResetResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PasswordResetResponseModel(
      message: json['message'] as String? ?? '',
      resetToken: json['resetToken'] as String?,
    );
  }
}
