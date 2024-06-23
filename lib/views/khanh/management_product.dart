import 'dart:convert';
import 'dart:typed_data';
import 'package:cake_coffee/models/khanh/add_products.dart';
import 'package:cake_coffee/models/khanh/category_product.dart';
import 'package:cake_coffee/models/khanh/edit_products.dart';
import 'package:cake_coffee/models/khanh/products.dart';
import 'package:cake_coffee/presents/khanh/add_category_product.dart';
import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Management_Product extends StatefulWidget {
  const Management_Product({super.key});

  @override
  _Management_ProductState createState() => _Management_ProductState();
}

class _Management_ProductState extends State<Management_Product>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _imageController = TextEditingController();

  List<Category> categories = [];
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadCategories();
    loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void loadCategories() async {
    List<Category> fetchedCategories = await fetchCategoriesFromFirestore();
    setState(() {
      categories = fetchedCategories;
    });
  }

  void loadProducts() async {
    List<Product> fetchedProducts = await fetchProductsFromFirestore();
    setState(() {
      products = fetchedProducts;
    });
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
  // Future<List<Product>> fetchProductsFromFirestore() async {
  //   try {
  //     QuerySnapshot querySnapshot =
  //         await FirebaseFirestore.instance.collection('products').get();
  //     return querySnapshot.docs.map((doc) {
  //       return Product(
  //         id: doc['id'],
  //         idCategoryProducts: doc['idCategoryProducts'],
  //         name: doc['name'],
  //         price: doc['price'],
  //         idUnitProducts: doc['idUnitProducts'] ??
  //             '', // Ensure to handle null case if necessary
  //         image: doc['image'],
  //         createTime: doc['createTime'] != null
  //             ? (doc['createTime'] as Timestamp).toDate()
  //             : DateTime.now(),
  //         updateTime: doc['updateTime'] != null
  //             ? (doc['updateTime'] as Timestamp).toDate()
  //             : DateTime.now(),
  //         deleteTime: doc['deleteTime'] != null
  //             ? (doc['deleteTime'] as Timestamp).toDate()
  //             : DateTime.now(),
  //       );
  //     }).toList();
  //   } catch (e) {
  //     print('Error fetching products: $e');
  //     return [];
  //   }
  // }

  // Future<List<Product>> fetchProductsFromFirestore() async {
  //   try {
  //     QuerySnapshot querySnapshot =
  //         await FirebaseFirestore.instance.collection('products').get();
  //     return querySnapshot.docs
  //         .map((doc) => Product.fromFirestore(doc))
  //         .toList();
  //   } catch (e) {
  //     print('Error fetching products: $e');
  //     return [];
  //   }
  // }

  String _getCategoryNameById(String categoryId) {
    final category = categories.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => Category(
        id: 'unknown',
        name: 'Unknown',
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
        deleteTime: DateTime.now(),
      ),
    );
    return category.name;
  }

  // void _showOptionsDialog(Map<String, dynamic> data) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Tùy chọn'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: <Widget>[
  //               TextFormField(
  //                 initialValue: data['id'].toString(),
  //                 onChanged: (newValue) {
  //                   setState(() {
  //                     data['id'] = newValue;
  //                   });
  //                 },
  //                 decoration: const InputDecoration(
  //                   border: OutlineInputBorder(),
  //                   labelText: 'ID',
  //                   contentPadding:
  //                       EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               TextFormField(
  //                 initialValue: data['name'].toString(),
  //                 onChanged: (newValue) {
  //                   setState(() {
  //                     data['name'] = newValue;
  //                   });
  //                 },
  //                 decoration: const InputDecoration(
  //                   border: OutlineInputBorder(),
  //                   labelText: 'Name',
  //                   contentPadding:
  //                       EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               TextFormField(
  //                 initialValue: data['description'].toString(),
  //                 onChanged: (newValue) {
  //                   setState(() {
  //                     data['description'] = newValue;
  //                   });
  //                 },
  //                 decoration: const InputDecoration(
  //                   border: OutlineInputBorder(),
  //                   labelText: 'Mô tả',
  //                   contentPadding:
  //                       EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               if (data.containsKey('categoryId'))
  //                 Text('Danh mục: ${_getCategoryNameById(data['categoryId'])}'),
  //               const SizedBox(height: 10),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                       _editItem(data);
  //                     },
  //                     child: const Text('Sửa'),
  //                   ),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                       _deleteItem(data);
  //                     },
  //                     style:
  //                         ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //                     child: const Text('Xóa'),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _deleteItem(Map<String, dynamic> data) {
    // Handle delete action
    print('Delete item: $data');
  }

  void _updateProductInList(Product updatedProduct) {
    setState(() {
      // Find the index of the updated product in the list and replace it
      int index =
          products.indexWhere((product) => product.id == updatedProduct.id);
      if (index != -1) {
        products[index] = updatedProduct;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey[200],
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Sản phẩm'),
                Tab(text: 'Danh mục'),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductTab(),
                _buildCategoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông tin sản phẩm',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Container(
                  child: roundedElevatedButton(
                      onPressed: () {
                        AddProductPage.openAddProductDialog(context);
                      },
                      text: "Thêm",
                      backgroundColor: Colors.green),
                )
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: _buildProductTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông tin danh mục',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add category logic
                  },
                  child: const Text('Thêm danh mục'),
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: _buildCategoryTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Mã danh mục')),
        DataColumn(label: Text('Tên danh mục')),
        //  DataColumn(label: Text('Mô tả')),
        DataColumn(label: Text('Thao tác')),
      ],
      rows: categories.map((category) {
        return DataRow(
          cells: [
            DataCell(Text(category.id)),
            DataCell(Text(category.name)),
            // DataCell(Text(category.description)), // Ensure Category class has description property
            const DataCell(
              Row(
                children: [
                  // IconButton(
                  //   icon: const Icon(Icons.edit),
                  //   onPressed: () => _showOptionsDialog(category.toMap()),
                  // ),
                  // IconButton(
                  //   icon: const Icon(Icons.delete),
                  //   onPressed: () => _deleteItem(category.toMap()),
                  // ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildProductTable() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 3,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Tên sản phẩm')),
          DataColumn(label: Text('Danh mục')),
          DataColumn(label: Text('Đơn vị tính')),
          DataColumn(label: Text('Giá')),
          DataColumn(label: Text('Hình ảnh')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: products.map((product) {
          return DataRow(
            cells: [
              DataCell(Text(product.name)),
              DataCell(Text(_getCategoryNameById(product.id_category_product))),
              DataCell(Text(product.id_unit_product)),
              // DataCell(Text(product
              //     .id_unit_product)), // Ensure Product class has unit property
              DataCell(Text(
                  '${product.price}.000đ')), // Ensure Product class has price property
              //  DataCell(Text(_getCategoryNameById(product.id_catehory_product))),
              DataCell(builImageProduct(decodeBase64Image(product.image))),

              // Ensure Product class has categoryId property
              // DataCell(product.image != null
              //     ? Image.memory(decodeBase64Image(product.image)!)
              //     : Container()),
              // DataCell(
              //   Row(
              //     children: [
              //       IconButton(
              //         icon: const Icon(Icons.edit),
              //         onPressed: () {
              //           showDialog(
              //             context: context,
              //             builder: (BuildContext context) {
              //               return EditProductsPage(
              //                   product:
              //                       product); // Pass the product you want to edit
              //             },
              //           );
              //         },
              //       ),
              //     ],
              //   ),
              // ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _openEditProductDialog(context, product);
                  },
                ),
              )

              // DataCell(
              //   Row(
              //     children: [
              //       IconButton(
              //           icon: const Icon(Icons.edit),
              //           onPressed: () =>
              //               EditProducts // _showOptionsDialog(product.toMap()),
              //           ),
              //       IconButton(
              //         icon: const Icon(Icons.delete),
              //         onPressed: () => _deleteItem(product.toMap()),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _openEditProductDialog(BuildContext context, Product product) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditProductsPage(
          product: product,
          onUpdateProduct: _updateProductInList, // Pass the callback
        );
      },
    );
  }
}

Widget builImageProduct(Uint8List? image) {
  if (image != null) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.transparent,
      backgroundImage: MemoryImage(image),
    );
  } else {
    return const CircleAvatar(
      radius: 50,
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage('assets/png.png'),
    );
  }
}

Uint8List? decodeBase64Image(String? base64String) {
  if (base64String == null || base64String.isEmpty) return null;
  return Uint8List.fromList(base64.decode(base64String));
}
