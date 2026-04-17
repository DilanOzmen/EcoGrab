class AuthResponse {
  final int userId;
  final String fullName;
  final String email;
  final String role;
  final String token;
  final String refreshToken;

  AuthResponse({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.token,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}