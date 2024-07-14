import 'package:cached_network_image/cached_network_image.dart';
import 'package:cake_coffee/presents/khanh/add_products.dart';
import 'package:cake_coffee/models/khanh/category_product.dart';
import 'package:cake_coffee/presents/khanh/edit_category_product.dart';
import 'package:cake_coffee/presents/khanh/edit_products.dart';
import 'package:cake_coffee/models/khanh/products.dart';
import 'package:cake_coffee/presents/khanh/add_category_product.dart';
import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Management_Product extends StatefulWidget {
  const Management_Product({super.key});

  @override
  _Management_ProductState createState() => _Management_ProductState();
}

class _Management_ProductState extends State<Management_Product>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchProductController =
      TextEditingController();
  final TextEditingController _searchCategoryController =
      TextEditingController();
  String _searchProductQuery = '';
  String _searchCategoryQuery = '';
  // String _searchQuery = '';
  String _selectedCategoryId = '';
  late TabController _tabController;
  List<Category> categories = [];
  List<Product> products = [];

  void _onAddProduct(Product newProduct) {
    setState(() {
      products.add(newProduct);
    });
  }

  void _onAddCategory(Category newCategory) {
    setState(() {
      categories.add(newCategory);
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

  void _deleteCategoryFromList(String categoryId) {
    setState(() {
      categories.removeWhere((category) => category.id == categoryId);
    });
  }

  void _updateCategoryInList(Category updatedCategory) {
    setState(() {
      int index = categories
          .indexWhere((category) => category.id == updatedCategory.id);
      if (index != -1) {
        categories[index] = updatedCategory;
      }
    });
  }

  List<Category> _filteredCategories() {
    List<Category> filtered = categories;

    if (_searchCategoryQuery.isNotEmpty) {
      filtered = filtered
          .where((category) => category.name
              .toLowerCase()
              .contains(_searchCategoryQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  List<Product> _filteredProducts() {
    List<Product> filtered = products;

    if (_searchProductQuery.isNotEmpty) {
      filtered = filtered
          .where((product) => product.name
              .toLowerCase()
              .contains(_searchProductQuery.toLowerCase()))
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

  @override
  void initState() {
    //Cập nhật trạng thái của _searchQuery khi người dùng nhập liệu:

    super.initState();
    _searchProductController.addListener(() {
      setState(() {
        _searchProductQuery = _searchProductController.text;
      });
    });

    _searchCategoryController.addListener(() {
      setState(() {
        _searchCategoryQuery = _searchCategoryController.text;
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
            //  width: MediaQuery.of(context).size.width * 0.3,
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
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
                    AddProductPage.openAddProductDialog(context, _onAddProduct);
                  },
                  text: "Thêm",
                  backgroundColor: Colors.green.shade400,
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
                  value: _selectedCategoryId.isEmpty ? '' : _selectedCategoryId,
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
                  controller: _searchProductController,
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
                  _searchProductController.clear();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: _buildProductTable(),
          ),
        )
      ],
    );
  }

  Widget _buildCategoryTab() {
    return SizedBox(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Đảm bảo căn lề bắt đầu từ đầu dòng
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.all(8),
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
                      Add_Category_Product.openAdd_Category_ProductDialog(
                          context, _onAddCategory);
                    },
                    text: "Thêm",
                    backgroundColor: Colors.green.shade400,
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
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: TextFormField(
                    controller: _searchCategoryController,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      labelText: 'Tìm kiếm danh mục',
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
                    _searchCategoryController.clear();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildCategoryTable(), // Đặt _buildCategoryTable() ở đây
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTable() {
    List<Category> filteredCategories = _filteredCategories();
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        children: [
          // Header row
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 3,
            child: Container(
              color: const Color.fromARGB(255, 207, 205, 205),
              child: const Row(
                children: [
                  Expanded(
                    flex: 1,
                    // width: 100,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                      child: Text('STT'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                      child: Text('Tên danh mục'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scrollable rows
          Expanded(
            child: filteredCategories.isEmpty
                ? const Center(
                    child:
                        Text('Không có danh mục sản phẩm nào được tìm thấy!'),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: filteredCategories.asMap().entries.map((entry) {
                        int index = entry.key;
                        Category category = entry.value;
                        return Column(
                          children: [
                            Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                elevation: 3,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => _openEditCategoryDialog(
                                      context, category),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('${index + 1}'),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(category.name),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTable() {
    List<Product> filteredProducts = _filteredProducts();
    return Column(
      children: [
        // Header row
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 3,
          child: Container(
            color: const Color.fromARGB(255, 207, 205, 205),
            margin: const EdgeInsets.all(0),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('STT'),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Tên sản phẩm'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Danh mục'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Đơn vị tính'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Giá'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Hình ảnh'),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Scrollable rows
        Expanded(
          child: filteredProducts.isEmpty
              ? const Center(
                  child: Text('Không có sản phẩm nào được tìm thấy!'),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: filteredProducts.asMap().entries.map((entry) {
                      int index = entry.key;
                      Product product = entry.value;
                      return Column(
                        children: [
                          Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              elevation: 3,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () =>
                                    _openEditProductDialog(context, product),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('${index + 1}'),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(product.name),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_getCategoryNameById(
                                            product.id_category_product)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(product.id_unit_product),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            FormartPrice(price: product.price)),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: product.image.isNotEmpty
                                                  ? CachedNetworkImage(
                                                      imageUrl: product.image,
                                                      placeholder: (context,
                                                              url) =>
                                                          const CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                      width: 30,
                                                      height: 30,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : const Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Icon(Icons.error),
                                                    ),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  String FormartPrice({required double price}) {
    String formattedAmount =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
    return formattedAmount;
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

  void _openEditCategoryDialog(BuildContext context, Category caterory) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCategory(
          category: caterory,
          onUpdateCategory: _updateCategoryInList,
          onDeleteCategory: _deleteCategoryFromList, // Pass the callback
        );
      },
    );
  }
}
