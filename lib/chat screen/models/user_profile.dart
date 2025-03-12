// class UserProfile {
//   String uid;
//   String name;

//   UserProfile({
//     required this.uid,
//     required this.name,
//   });

//   UserProfile.fromJson(Map<String, dynamic> json)
//       : uid = json['uid'] as String,
//         name = json['name'] as String;

//   Map<String, dynamic> toJson() {
//     return {
//       'uid': uid,
//       'name': name,
//     };
//   }
// }


class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String profilePic;

  UserProfile({required this.uid, required this.name, required this.email, required this.profilePic});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      profilePic: json['profilePic'] ?? '', // Handle null profile pictures
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
    };
  }


}
