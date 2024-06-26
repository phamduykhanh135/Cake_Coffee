import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cake_coffee/models/khanh/add_products.dart';
import 'package:cake_coffee/models/khanh/category_product.dart';
import 'package:cake_coffee/models/khanh/edit_products.dart';
import 'package:cake_coffee/models/khanh/products.dart';
import 'package:cake_coffee/presents/khanh/add_category_product.dart';
import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:flutter/material.dart';

class Management_Product extends StatefulWidget {
  const Management_Product({super.key});

  @override
  _Management_ProductState createState() => _Management_ProductState();
}

class _Management_ProductState extends State<Management_Product>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategoryId = '';
  late TabController _tabController;
  List<Category> categories = [];
  List<Product> products = [];

  void _onAddProduct(Product newProduct) {
    setState(() {
      products.add(newProduct);
    });
  }

  void _deleteProductFromList(String productId) {
    setState(() {
      products.removeWhere((product) => product.id == productId);
    });
  }

  void _updateProductInList(Product updatedProduct) {
    setState(() {
      int index =
          products.indexWhere((product) => product.id == updatedProduct.id);
      if (index != -1) {
        products[index] = updatedProduct;
      }
    });
  }

  List<Product> _filteredProducts() {
    List<Product> filtered = products;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategoryId.isNotEmpty) {
      filtered = filtered
          .where(
              (product) => product.id_category_product == _selectedCategoryId)
          .toList();
    }

    return filtered;
  }

  // List<Product> _filteredProducts() {
  //   if (_selectedCategoryId.isNotEmpty) {
  //     return products;
  //   }

  //   return products.where((product)=>product.id_category_product==_selectedCategoryId).toList();
  // }

  @override
  void initState() {
    //Cập nhật trạng thái của _searchQuery khi người dùng nhập liệu:

    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _tabController = TabController(length: 2, vsync: this);
    loadCategories();
    loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                      AddProductPage.openAddProductDialog(
                          context, _onAddProduct);
                    },
                    text: "Thêm",
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: DropdownButtonFormField<String>(
                    value:
                        _selectedCategoryId.isEmpty ? '' : _selectedCategoryId,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategoryId = newValue ?? '';
                      });
                    },
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Tất cả'),
                      ),
                      ...categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Danh mục',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: TextFormField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      labelText: 'Tìm kiếm sản phẩm',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
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
                Container(
                  child: roundedElevatedButton(
                      onPressed: () {
                        Add_Category_Product.openAddProductDialog(context);
                      },
                      text: "Thêm",
                      backgroundColor: Colors.green),
                )
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
                children: [],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildProductTable() {
    List<Product> filteredProducts = _filteredProducts();
    return SingleChildScrollView(
      child: Card(
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
          rows: filteredProducts.map((product) {
            return DataRow(
              cells: [
                DataCell(Text(product.name)),
                DataCell(
                    Text(_getCategoryNameById(product.id_category_product))),
                DataCell(Text(product.id_unit_product)),
                DataCell(Text('${product.price}.000đ')),
                DataCell(
                  product.image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.image,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.error),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _openEditProductDialog(context, product);
                    },
                  ),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _openEditProductDialog(BuildContext context, Product product) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditProductsPage(
          product: product,
          onUpdateProduct: _updateProductInList,
          onDeleteProduct: _deleteProductFromList, // Pass the callback
        );
      },
    );
  }
}


// Widget builImageProduct(Uint8List? image) {
//   if (image != null) {
//     return CircleAvatar(
//       radius: 50,
//       backgroundColor: Colors.transparent,
//       backgroundImage: MemoryImage(image),
//     );
//   } else {
//     return const CircleAvatar(
//       radius: 50,
//       backgroundColor: Colors.transparent,
//       backgroundImage: AssetImage('assets/png.png'),
//     );
//   }
// }

// Uint8List? decodeBase64Image(String? base64String) {
//   if (base64String == null || base64String.isEmpty) return null;
//   return Uint8List.fromList(base64.decode(base64String));
// }
