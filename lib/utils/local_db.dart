// import 'package:faceattendance/models/user.dart';
// import 'package:hive/hive.dart';
//
// class HiveBoxes {
//   static const userDetails = "user_details";
//
//   static Box userDetailsBox() => Hive.box(userDetails);
//
//   static initialize() async {
//     await Hive.openBox(userDetails);
//   }
//
//   static clearAllBox() async {
//     await HiveBoxes.userDetailsBox().clear();
//   }
// }
//
// class LocalDB {
//   static User getUser() => User.fromJson(HiveBoxes.userDetailsBox().toMap());
// // Returns a Map<String, Map> with all keys and entries
//
//
//   static  getAllUser() =>
//       HiveBoxes.userDetailsBox().toMap();
//
//
//   static String getUserName() =>
//       HiveBoxes.userDetailsBox().toMap()[User.nameKey];
//
//   static String getUserArray() =>
//       HiveBoxes.userDetailsBox().toMap()[User.arrayKey];
//
//   static setUserDetails(User user) =>
//       HiveBoxes.userDetailsBox().putAll(user.toJson());
// }
