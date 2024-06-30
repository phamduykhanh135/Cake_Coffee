import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Roles {
  String id;
  String name;
  DateTime? create_time;
  DateTime? update_time;
  DateTime? delete_time;

  Roles(
      {required this.id,
      required this.name,
      required this.create_time,
      required this.update_time,
      required this.delete_time});

  factory Roles.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Roles(
      id: doc.id,
      name: data['name'] ?? '',
      create_time: data['create_time'] != null
          ? (data['create_time'] as Timestamp).toDate()
          : null,
      update_time: data['create_time'] != null
          ? (data['create_time'] as Timestamp).toDate()
          : null,
      delete_time: data['create_time'] != null
          ? (data['create_time'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'create_tiem': create_time,
      'update_time': update_time,
      'delete_time': delete_time,
    };
  }
}

Future<List<Roles>> fetchRolesFromFirestore() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('roles').get();
    return querySnapshot.docs.map((doc) => Roles.fromFirestore(doc)).toList();
  } catch (e) {
    print('Error fetching area:$e');
    return [];
  }
}
  // Future<List<Roles>> fetchRolesFromFirestore() async {
  //   QuerySnapshot querySnapshot =
  //       await FirebaseFirestore.instance.collection('roles').get();
  //   return querySnapshot.docs.map((doc) {
  //     return Roles(
  //       id: doc.id,
  //       name: doc['name'],
  //       create_time: (doc['create_time'] as Timestamp).toDate(),
  //       update_time: doc['update_time'] != null
  //           ? (doc['update_time'] as Timestamp).toDate()
  //           : null,
  //       delete_time: doc['delete_time'] != null
  //           ? (doc['delete_time'] as Timestamp).toDate()
  //           : null,
  //     );
  //   }).toList();
  // }