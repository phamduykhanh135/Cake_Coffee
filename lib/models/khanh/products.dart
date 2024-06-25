import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id;
  String id_category_product;
  String name;
  double price;
  String id_unit_product;
  String image;
  DateTime? createTime;
  DateTime? updateTime;
  DateTime? deleteTime;
  //9

  Product({
    required this.id,
    required this.id_category_product,
    required this.name,
    required this.price,
    required this.id_unit_product,
    required this.image,
    required this.createTime,
    required this.updateTime,
    required this.deleteTime,
  });

  //Factory constructor to create a Product instance from a Firestore document
  // factory Product.fromFirestore(DocumentSnapshot doc) {
  //   Map data = doc.data() as Map;
  //   return Product(
  //     id: doc.id,
  //     id_catehory_product: data['id_category_product'] ?? '',
  //     name: data['name'] ?? '',
  //     price: (data['price'] ?? 0.0).toDouble(),
  //     id_unit_product: data['id_unit_product'] ?? '',
  //     image: data['image'] ?? '',
  //     createTime: (data['createTime'] ?? DateTime.now())?.toDate(),
  //     updateTime: (data['updateTime'] ?? DateTime.now())?.toDate(),
  //     deleteTime: (data['deleteTime'] ?? DateTime.now())?.toDate(),
  //   );
  // }
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      id_category_product: data['id_category_product'] ?? '',
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      id_unit_product: data['id_unit_product'] ?? '',
      image: data['image'] ?? '',
      createTime: (data['createTime'] as Timestamp).toDate(),
      updateTime: data['updateTime'] != null
          ? (data['updateTime'] as Timestamp).toDate()
          : null,
      deleteTime: data['deleteTime'] != null
          ? (data['deleteTime'] as Timestamp).toDate()
          : null,
    );
  }

  // Method to convert Product instance to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id_category_product': id_category_product,
      'name': name,
      'price': price,
      'id_unit_product': id_unit_product,
      'image': image,
      'createTime': createTime,
      'updateTime': updateTime,
      'deleteTime': deleteTime,
    };
  }
}

Future<List<Product>> fetchProductsFromFirestore() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('products').get();
    return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  } catch (e) {
    print('Error fetching products: $e');
    return [];
  }
}
