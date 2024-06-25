import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final DateTime? createTime;
  final DateTime? updateTime;
  final DateTime? deleteTime;

  Category({
    required this.id,
    required this.name,
    required this.createTime,
    required this.updateTime,
    required this.deleteTime,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      createTime: (data['create_time'] as Timestamp?)?.toDate(),
      updateTime: (data['update_time'] as Timestamp?)?.toDate(),
      deleteTime: (data['delete_time'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'create_time': createTime, //Timestamp.fromDate(createTime),
      'update_time': updateTime, // Timestamp.fromDate(updateTime),
      'delete_time': deleteTime // Timestamp.fromDate(deleteTime),
    };
  }
}

Future<List<Category>> fetchCategoriesFromFirestore() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return querySnapshot.docs
        .map((doc) => Category.fromFirestore(doc))
        .toList();
  } catch (e) {
    print('Error fetching categories: $e');
    return [];
  }
}

// Future<List<Category>> fetchCategoriesFromFirestore() async {
//   try {
//     QuerySnapshot querySnapshot =
//         await FirebaseFirestore.instance.collection('categories').get();
//     return querySnapshot.docs
//         .map((doc) => Category.fromFirestore(doc))
//         .toList();
//   } catch (e) {
//     print('Error fetching categories: $e');
//     return [];
//   }
// }




// import 'package:cloud_firestore/cloud_firestore.dart';

// class Category {
//   final String id;
//   final String name;
//   final DateTime createTime;
//   final DateTime updateTime;
//   final DateTime deleteTime;

//   Category({
//     required this.id,
//     required this.name,
//     required this.createTime,
//     required this.updateTime,
//     required this.deleteTime,
//   });

//   factory Category.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return Category(
//       id: doc.id,
//       name: data['name'] ?? '',
//       createTime: (data['createTime'] as Timestamp).toDate(),
//       updateTime: (data['updateTime'] as Timestamp).toDate(),
//       deleteTime: (data['deleteTime'] as Timestamp).toDate(),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'createTime': createTime ?? DateTime.now(), // Default value example
//       'updateTime': updateTime ?? DateTime.now(), // Default value example
//       'deleteTime': deleteTime ?? DateTime.now(), // Default value example
//     };
//   }
// }
