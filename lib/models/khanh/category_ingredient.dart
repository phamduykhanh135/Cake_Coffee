import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Category_Ingredient {
  String id;
  String name;
  DateTime? create_time;
  DateTime? update_time;
  DateTime? delete_time;

  Category_Ingredient({
    required this.id,
    required this.name,
    required this.create_time,
    required this.update_time,
    required this.delete_time,
  });

  factory Category_Ingredient.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category_Ingredient(
      id: doc.id,
      name: data['name'] ?? '',
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
      'name': name,
      'create_time': create_time, //Timestamp.fromDate(createTime),
      'update_time': update_time, // Timestamp.fromDate(updateTime),
      'delete_time': delete_time // Timestamp.fromDate(deleteTime),
    };
  }
}

Future<List<Category_Ingredient>>
    fetchloadCategory_IngredientsFromFirestore() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('category_ingredients')
        .get();
    return querySnapshot.docs
        .map((doc) => Category_Ingredient.fromFirestore(doc))
        .toList();
  } catch (e) {
    print('Error fetching categories: $e');
    return [];
  }
}
