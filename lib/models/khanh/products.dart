import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id;
  String id_category_product;
  String name;
  double price;
  String id_unit_product;
  String image;
  DateTime? create_time;
  DateTime? update_time;
  DateTime? delete_time;
  //9

  Product({
    required this.id,
    required this.id_category_product,
    required this.name,
    required this.price,
    required this.id_unit_product,
    required this.image,
    required this.create_time,
    required this.update_time,
    required this.delete_time,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      id_category_product: data['id_category_product'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] as num).toDouble(),
      id_unit_product: data['id_unit_product'] ?? '',
      image: data['image'] ?? '',
      create_time: (data['create_time'] as Timestamp).toDate(),
      update_time: data['update_time'] != null
          ? (data['update_time'] as Timestamp).toDate()
          : null,
      delete_time: data['delete_time'] != null
          ? (data['delete_time'] as Timestamp).toDate()
          : null,
    );
  }
  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      id_category_product: data['id_category_product'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] as num).toDouble(),
      id_unit_product: data['id_unit_product'] ?? '',
      image: data['image'] ?? '',
      create_time: data['create_time'] != null
          ? (data['create_time'] as Timestamp).toDate()
          : null,
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
      'id_category_product': id_category_product,
      'name': name,
      'price': price,
      'id_unit_product': id_unit_product,
      'image': image,
      'create_time': create_time,
      'update_time': update_time,
      'delete_time': delete_time,
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

Future<bool> checkProductNameUnique(String productId, String newName) async {
  try {
    // Lấy danh sách các tên sản phẩm từ Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('name', isEqualTo: newName)
        .get();

    // Kiểm tra tên sản phẩm duy nhất (nếu trùng tên, chỉ cho phép nếu đó là sản phẩm đang sửa)
    if (querySnapshot.docs.isEmpty) {
      return true; // Tên sản phẩm mới là duy nhất
    } else {
      // Nếu tìm thấy sản phẩm khác có cùng tên
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        if (doc.id != productId) {
          return false; // Tên sản phẩm đã tồn tại và không phải là sản phẩm đang sửa
        }
      }
      return true; // Nếu chỉ tìm thấy sản phẩm đang sửa thì tên sản phẩm mới là duy nhất
    }
  } catch (e) {
    print('Error checking product name uniqueness: $e');
    return false;
  }
}
