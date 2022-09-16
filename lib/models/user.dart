class User {
  int? id;
  String? name;
  String? email;
  String? profile;
  String? token;

  User({
    this.id,
    this.name,
    this.email,
    this.profile,
    this.token,
  });

  // function to convert json data to user model
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'],
      name: json['user']['name'],
      email: json['user']['email'],
      profile: json['user']['profile'],
      token: json['token'],
    );
  }
}
