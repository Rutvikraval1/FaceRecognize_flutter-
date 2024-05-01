
import 'dart:convert';

class User {
  static const String nameKey = "user";
  static const String arrayKey = "arrayKey";

  String name='';
  List? array;

  User({required this.name, required this.array});

  factory User.fromJson(Map<dynamic, dynamic> json) => User(
        name: json[nameKey],
        array:jsonDecode(json[arrayKey]),
      );

  Map<String, dynamic> toJson() => {
        nameKey: name,
        arrayKey:jsonEncode(array) ,
      };
}
