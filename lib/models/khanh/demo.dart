// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Product {
//   final String id;
//   final String idCategoryProducts;
//   final String name;
//   final double price;
//   final String idUnitProducts;
//   final String image;
//   final DateTime createTime;
//   final DateTime updateTime;
//   final DateTime deleteTime;

//   Product({
//     required this.id,
//     required this.idCategoryProducts,
//     required this.name,
//     required this.price,
//     required this.idUnitProducts,
//     required this.image,
//     required this.createTime,
//     required this.updateTime,
//     required this.deleteTime,
//   });
// }

// class ProductDataTablePage extends StatefulWidget {
//   @override
//   _ProductDataTablePageState createState() => _ProductDataTablePageState();
// }

// class _ProductDataTablePageState extends State<ProductDataTablePage> {
//   List<Product> products = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchProducts();
//   }

//   void fetchProducts() async {
//     try {
//       QuerySnapshot querySnapshot =
//           await FirebaseFirestore.instance.collection('products').get();
//       List<Product> fetchedProducts = querySnapshot.docs.map((doc) {
//         var data = doc.data();
//         return Product(
//           id: doc.id,
//           idCategoryProducts: data['idCategoryProducts'],
//           name: data['name'],
//           price: (data['price'] ?? 0.0).toDouble(),
//           idUnitProducts: data['idUnitProducts'] ?? '',
//           image: data['image'],
//           createTime: data['createTime'] != null
//               ? (data['createTime'] as Timestamp).toDate()
//               : DateTime.now(),
//           updateTime: data['updateTime'] != null
//               ? (data['updateTime'] as Timestamp).toDate()
//               : DateTime.now(),
//           deleteTime: data['deleteTime'] != null
//               ? (data['deleteTime'] as Timestamp).toDate()
//               : DateTime.now(),
//         );
//       }).toList();

//       setState(() {
//         products = fetchedProducts;
//       });
//     } catch (e) {
//       print('Error fetching products: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Product Management'),
//       ),
//       body: SingleChildScrollView(
//         child: DataTable(
//           columns: const [
//             DataColumn(label: Text('ID')),
//             DataColumn(label: Text('Category ID')),
//             DataColumn(label: Text('Name')),
//             DataColumn(label: Text('Price')),
//             DataColumn(label: Text('Unit ID')),
//             DataColumn(label: Text('Image')),
//             DataColumn(label: Text('Create Time')),
//             DataColumn(label: Text('Update Time')),
//             DataColumn(label: Text('Delete Time')),
//           ],
//           rows: products.map((product) {
//             return DataRow(
//               cells: [
//                 DataCell(Text(product.id)),
//                 DataCell(Text(product.idCategoryProducts)),
//                 DataCell(Text(product.name)),
//                 DataCell(Text('${product.price}')),
//                 DataCell(Text(product.idUnitProducts)),
//                 DataCell(product.image != null
//                     ? Image.network(product.image)
//                     : Text('No image')),
//                 DataCell(Text(product.createTime.toString())),
//                 DataCell(Text(product.updateTime.toString())),
//                 DataCell(Text(product.deleteTime.toString())),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }
      
    


