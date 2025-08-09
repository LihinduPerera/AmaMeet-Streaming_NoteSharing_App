class UserModel {
  final String username;
  final String uid;
  final String profilePhoto;

  UserModel({
    required this.username,
    required this.uid,
    required this.profilePhoto
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      uid: map['uid'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'uid': uid,
      'profilePhoto': profilePhoto,
    };
  }
}