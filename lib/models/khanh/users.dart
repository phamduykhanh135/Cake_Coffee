import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String id;
  String name;
  String role;
  String account;
  String password;
  DateTime? created_at;

  Users({
    required this.id,
    required this.name,
    required this.account,
    required this.role,
    required this.password,
    required this.created_at,
  });
  factory Users.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Users(
      id: doc.id,
      role: data['role'] ?? '',
      name: data['name'] ?? '',
      account: data['account'] ?? '',
      password: data['password'] ?? '',
      created_at: (data['created_at'] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'name': name,
      'account': account,
      'password': password,
      'created_at': created_at,
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
