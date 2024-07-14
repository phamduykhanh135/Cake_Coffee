import 'package:cloud_firestore/cloud_firestore.dart';

class Customers {
  String id;
  String name;
  int point;
  String phone;
  String password;
  DateTime? created_at;

  Customers({
    required this.id,
    required this.name,
    required this.phone,
    required this.point,
    required this.password,
    required this.created_at,
  });
  factory Customers.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Customers(
      id: doc.id,
      point: data['point'] ?? 0,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      password: data['password'] ?? '',
      created_at: (data['created_at'] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'point': point,
      'name': name,
      'phone': phone,
      'password': password,
      'created_at': created_at,
    };
  }
}

Future<List<Customers>> fetchUsersFromFirestore() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('customers').get();
    return querySnapshot.docs
        .map((doc) => Customers.fromFirestore(doc))
        .toList();
  } catch (e) {
    print('Error fetching products: $e');
    return [];
  }
}
