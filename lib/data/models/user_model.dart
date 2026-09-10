class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String? photoUrl;
  final double walletBalance;
  final double rating;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    this.photoUrl,
    this.walletBalance = 850.0,
    this.rating = 4.95,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    double? walletBalance,
    double? rating,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      walletBalance: walletBalance ?? this.walletBalance,
      rating: rating ?? this.rating,
    );
  }
}
