class User {
  int? userId;
  String? userName;
  String? userEmail;
  String? userPassword;

  User({
    this.userId,
    this.userName,
    this.userEmail,
    this.userPassword,
  });

  // Updated fromJson method to handle proper type conversion
  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json['user_id']!= null ? int.tryParse(json['user_id'].toString()) : null,  // Safely parse user_id to int
    userName: json['user_name'],
    userEmail: json['user_email'],
    userPassword: json['user_password'],
  );

  // Updated toJson method to ensure userId is saved as an integer
  Map<String, dynamic> toJson() => {
    'user_id': userId.toString(),  // Save userId as integer (no need to convert to string)
    'user_name': userName,
    'user_email': userEmail,
    'user_password': userPassword,
  };
}