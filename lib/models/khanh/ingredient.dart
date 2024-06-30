import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  String id;
  String id_category_ingredient;
  String name;
  double price;
  int number;
  String id_unit_ingredient;
  DateTime? create_time;
  DateTime? update_time;
  DateTime? delete_time;
  //9

  Ingredient({
    required this.id,
    required this.id_category_ingredient,
    required this.name,
    required this.price,
    required this.number,
    required this.id_unit_ingredient,
    required this.create_time,
    required this.update_time,
    required this.delete_time,
  });

  factory Ingredient.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Ingredient(
      id: doc.id,
      id_category_ingredient: data['id_category_ingredient'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] as num).toDouble(),
      id_unit_ingredient: data['id_unit_ingredient'] ?? '',
      number: data['number'] ?? 0,
      create_time: (data['create_time'] as Timestamp).toDate(),
      update_time: data['update_time'] != null
          ? (data['update_time'] as Timestamp).toDate()
          : null,
      delete_time: data['delete_time'] != null
          ? (data['delete_time'] as Timestamp).toDate()
          : null,
    );
  }

  // Method to convert Product instance to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id_category_ingredient': id_category_ingredient,
      'name': name,
      'price': price,
      'id_unit_ingredient': id_unit_ingredient,
      'number': number,
      'create_time': create_time,
      'update_time': update_time,
      'delete_time': delete_time,
    };
  }
}

Future<List<Ingredient>> fetchIngredientsFromFirestore() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('ingredients').get();
    return querySnapshot.docs
        .map((doc) => Ingredient.fromFirestore(doc))
        .toList();
  } catch (e) {
    print('Error fetching products: $e');
    return [];
  }
}
