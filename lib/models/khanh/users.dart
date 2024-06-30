import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String id;
  String name;
  String id_role;
  String account;
  String password1;
  String password2;
  DateTime? create_time;
  DateTime? update_time;
  DateTime? delete_time;

  Users({
    required this.id,
    required this.name,
    required this.account,
    required this.id_role,
    required this.password1,
    required this.password2,
    required this.create_time,
    required this.update_time,
    required this.delete_time,
  });
  factory Users.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Users(
      id: doc.id,
      id_role: data['id_role'] ?? '',
      name: data['name'] ?? '',
      account: data['account'] ?? '',
      password1: data['password1'] ?? '',
      password2: data['password2'] ?? '',
      create_time: (data['create_time'] as Timestamp).toDate(),
      update_time: data['update_time'] != null
          ? (data['update_time'] as Timestamp).toDate()
          : null,
      delete_time: data['delete_time'] != null
          ? (data['delete_time'] as Timestamp).toDate()
          : null,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id_role': id_role,
      'name': name,
      'account': account,
      'password1': password1,
      'password2': password2,
      'create_time': create_time,
      'update_time': update_time,
      'delete_time': delete_time,
    };
  }
}

Future<List<Users>> fetchUsersFromFirestore() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs.map((doc) => Users.fromFirestore(doc)).toList();
  } catch (e) {
    print('Error fetching products: $e');
    return [];
  }
}
