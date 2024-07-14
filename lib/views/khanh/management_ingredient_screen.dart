import 'package:cake_coffee/models/khanh/category_ingredient.dart';
import 'package:cake_coffee/models/khanh/ingredient.dart';
import 'package:cake_coffee/presents/khanh/add_category_ingredient.dart';
import 'package:cake_coffee/presents/khanh/add_ingredient.dart';
import 'package:cake_coffee/presents/khanh/edit_category_ingredient.dart';
import 'package:cake_coffee/presents/khanh/edit_ingredient.dart';
import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Management_Ingredient_Screen extends StatefulWidget {
  const Management_Ingredient_Screen({super.key});

  @override
  _Management_Ingredient_ScreenState createState() =>
      _Management_Ingredient_ScreenState();
}

class _Management_Ingredient_ScreenState
    extends State<Management_Ingredient_Screen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchIngredientController =
      TextEditingController();
  final TextEditingController _searchCategoryController =
      TextEditingController();
  String _searchIngredientQuery = '';
  String _searchCategoryQuery = '';
  String _selectedCategoryId = '';
  late TabController _tabController;
  List<Category_Ingredient> category_ingredidents = [];
  List<Ingredient> ingredients = [];

  void _onAddIngredient(Ingredient newIngredient) {
    setState(() {
      ingredients.add(newIngredient);
    });
  }

  void _onAddCategory(Category_Ingredient newCategory) {
    setState(() {
      category_ingredidents.add(newCategory);
    });
  }

  void _deleteIngredientFromList(String ingredientId) {
    setState(() {
      ingredients.removeWhere((ingredient) => ingredient.id == ingredientId);
    });
  }

  void _updateIngredientInList(Ingredient updatedIngredient) {
    setState(() {
      int index = ingredients
          .indexWhere((ingredient) => ingredient.id == updatedIngredient.id);
      if (index != -1) {
        ingredients[index] = updatedIngredient;
      }
    });
  }

  void _deleteCategory_IngredientFromList(String categoryId) {
    setState(() {
      category_ingredidents
          .removeWhere((category) => category.id == categoryId);
    });
  }

  void _updateCategory_IngredientInList(Category_Ingredient updatedCategory) {
    setState(() {
      int index = category_ingredidents
          .indexWhere((category) => category.id == updatedCategory.id);
      if (index != -1) {
        category_ingredidents[index] = updatedCategory;
      }
    });
  }

  List<Category_Ingredient> _filteredCategories() {
    List<Category_Ingredient> filtered = category_ingredidents;

    if (_searchCategoryQuery.isNotEmpty) {
      filtered = filtered
          .where((category) => category.name
              .toLowerCase()
              .contains(_searchCategoryQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  List<Ingredient> _filteredIngredients() {
    List<Ingredient> filtered = ingredients;

    if (_searchIngredientQuery.isNotEmpty) {
      filtered = filtered
          .where((ingredient) => ingredient.name
              .toLowerCase()
              .contains(_searchIngredientQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategoryId.isNotEmpty) {
      filtered = filtered
          .where((ingredient) =>
              ingredient.id_category_ingredient == _selectedCategoryId)
          .toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchIngredientController.addListener(() {
      setState(() {
        _searchIngredientQuery = _searchIngredientController.text;
      });
    });

    _searchCategoryController.addListener(() {
      setState(() {
        _searchCategoryQuery = _searchCategoryController.text;
      });
    });
    _tabController = TabController(length: 2, vsync: this);
    loadCategories();
    loadIngredients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void loadCategories() async {
    List<Category_Ingredient> fetchedCategories =
        await fetchloadCategory_IngredientsFromFirestore();
    setState(() {
      category_ingredidents = fetchedCategories;
    });
  }

  void loadIngredients() async {
    List<Ingredient> fetchedIngredients = await fetchIngredientsFromFirestore();
    setState(() {
      ingredients = fetchedIngredients;
    });
  }

  String _getCategoryNameById(String categoryId) {
    final category = category_ingredidents.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => Category_Ingredient(
        id: 'unknown',
        name: 'Unknown',
        create_time: DateTime.now(),
        update_time: DateTime.now(),
        delete_time: DateTime.now(),
      ),
    );
    return category.name;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
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
                Tab(text: 'Nguyên liệu'),
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
                _buildIngredientTab(),
                _buildCategory_IngredientTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông tin nguyên liệu',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Container(
                child: roundedElevatedButton(
                  onPressed: () {
                    AddIngredientPage.openAddIngredientDialog(
                        context, _onAddIngredient);
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
                    ...category_ingredidents.map((category) {
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
                  controller: _searchIngredientController,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'Tìm kiếm nguyên liệu',
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
                  _searchIngredientController.clear();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: _buildIngredientTable(),
          ),
        )
      ],
    );
  }

  Widget _buildCategory_IngredientTab() {
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
                      Add_Category_Ingredient.openAdd_Category_IngredientDialog(
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
                child:
                    _buildCategory_IngredientTable(), // Đặt _buildCategoryTable() ở đây
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildIngredientTable() {
  //   List<Ingredient> filteredIngredients = _filteredIngredients();

  //   return Column(
  //     children: [
  //       // Header row
  //       Card(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  //         elevation: 3,
  //         child: Container(
  //           color: const Color.fromARGB(255, 207, 205, 205),
  //           margin: const EdgeInsets.all(0),
  //           child: const Row(
  //             children: [
  //               Expanded(
  //                 flex: 1,
  //                 child: Padding(
  //                   padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
  //                   child: Text('STT'),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 2,
  //                 child: Padding(
  //                   padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
  //                   child: Text('Ngày tạo'),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 3,
  //                 child: Padding(
  //                   padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
  //                   child: Text('Tên nguyên liệu'),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 2,
  //                 child: Padding(
  //                   padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
  //                   child: Text('Danh mục'),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 2,
  //                 child: Padding(
  //                   padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
  //                   child: Text('Đơn vị tính'),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 2,
  //                 child: Padding(
  //                   padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
  //                   child: Text('Giá'),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 2,
  //                 child: Padding(
  //                   padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
  //                   child: Text('Số lượng'),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 2,
  //                 child: Padding(
  //                   padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
  //                   child: Text('Tổng giá'),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 2,
  //                 child: Padding(
  //                   padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
  //                   child: Text('Hạn sử dụng'),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       // Scrollable rows
  //       Expanded(
  //         child: filteredIngredients.isEmpty
  //             ? const Center(
  //                 child: Text('Không có nguyên liệu nào được tìm thấy!'),
  //               )
  //             : SingleChildScrollView(
  //                 child: Column(
  //                   children: filteredIngredients.asMap().entries.map((entry) {
  //                     int index = entry.key;
  //                     Ingredient ingredient = entry.value;
  //                     return Column(
  //                       children: [
  //                         Card(
  //                             shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(5)),
  //                             elevation: 3,
  //                             child: InkWell(
  //                               borderRadius: BorderRadius.circular(8),
  //                               onTap: () => _openEditIngredientDialog(
  //                                   context, ingredient),
  //                               child: Row(
  //                                 children: [
  //                                   Expanded(
  //                                     flex: 1,
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.all(8.0),
  //                                       child: Text('${index + 1}'),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     flex: 2,
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.all(8.0),
  //                                       child: Text(
  //                                         _formatDate(ingredient.create_time),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     flex: 3,
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.all(8.0),
  //                                       child: Text(ingredient.name),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     flex: 2,
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.all(8.0),
  //                                       child: Text(_getCategoryNameById(
  //                                           ingredient.id_category_ingredient)),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     flex: 2,
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.all(8.0),
  //                                       child:
  //                                           Text(ingredient.id_unit_ingredient),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     flex: 2,
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.all(8.0),
  //                                       child: Text(FormartPrice(
  //                                           price: ingredient.price)),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     flex: 2,
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.all(8.0),
  //                                       child: Text(
  //                                           '${ingredient.quantity.toInt()}'),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     flex: 2,
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.all(8.0),
  //                                       child: Text(FormartPrice(
  //                                           price: ingredient.total)),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     flex: 2,
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.all(8.0),
  //                                       child: Text(
  //                                         _formatDate(ingredient.delete_time),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             )),
  //                       ],
  //                     );
  //                   }).toList(),
  //                 ),
  //               ),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildIngredientTable() {
    List<Ingredient> filteredIngredients = _filteredIngredients();

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
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Ngày tạo'),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Tên nguyên liệu'),
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
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Số lượng'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Tổng giá'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Hạn sử dụng'),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Scrollable rows
        Expanded(
          child: filteredIngredients.isEmpty
              ? const Center(
                  child: Text('Không có nguyên liệu nào được tìm thấy!'),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: filteredIngredients.asMap().entries.map((entry) {
                      int index = entry.key;
                      Ingredient ingredient = entry.value;

                      // Check expiration status

                      Color? cardColor;
                      if (ingredient.delete_time == null) {
                        cardColor = null; // Handle null case
                      } else {
                        // Lấy ngày hiện tại
                        DateTime today = DateTime.now();

                        // Chỉ lấy ngày (bỏ qua thời gian)
                        DateTime currentDate =
                            DateTime(today.year, today.month, today.day);
                        DateTime deleteDate = DateTime(
                          ingredient.delete_time!.year,
                          ingredient.delete_time!.month,
                          ingredient.delete_time!.day,
                        );

                        // So sánh ngày
                        if (deleteDate.isBefore(currentDate)) {
                          cardColor = Colors.grey.shade300; // Expired
                        } else if (deleteDate.isAfter(currentDate)) {
                          cardColor = null; // Not expired, no specific color
                        } else {
                          cardColor =
                              Colors.red.shade300; // Exact expiration date
                        }
                      }

                      return Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 3,
                            // Set the background color based on expiration
                            color: cardColor,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => _openEditIngredientDialog(
                                  context, ingredient),
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
                                      child: Text(
                                        _formatDate(ingredient.create_time),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(ingredient.name),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(_getCategoryNameById(
                                          ingredient.id_category_ingredient)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                          Text(ingredient.id_unit_ingredient),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(FormartPrice(
                                          price: ingredient.price)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          '${ingredient.quantity.toInt()}'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        FormartPrice(price: ingredient.total),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        _formatDate(ingredient.delete_time),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCategory_IngredientTable() {
    List<Category_Ingredient> filteredCategories = _filteredCategories();
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
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                      child: Text('Ngày tạo'),
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
                    child: Text(
                        'Không có danh mục nguyên liệu nào được tìm thấy!'),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: filteredCategories.asMap().entries.map((entry) {
                        int index = entry.key;
                        Category_Ingredient categoryIngredient = entry.value;
                        return Column(
                          children: [
                            Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                elevation: 3,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () =>
                                      _openEditCategory_IngredientDialog(
                                          context, categoryIngredient),
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
                                          child: Text(categoryIngredient.name),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(_formatDate(
                                              categoryIngredient.create_time)),
                                        ),
                                      ),
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
      ),
    );
  }

  void _openEditIngredientDialog(
      BuildContext context, Ingredient ingredient) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditIngredientPage(
          ingredient: ingredient,
          onUpdateIngredient: _updateIngredientInList,
          onDeleteIngredient: _deleteIngredientFromList, // Pass the callback
        );
      },
    );
  }

  void _openEditCategory_IngredientDialog(
      BuildContext context, Category_Ingredient cateroryIngredient) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCategory_Ingredient(
          category_ingredient: cateroryIngredient,
          onUpdateCategory_Ingredient: _updateCategory_IngredientInList,
          onDeleteCategory_Ingredient:
              _deleteCategory_IngredientFromList, // Pass the callback
        );
      },
    );
  }

  String FormartPrice({required double price}) {
    String formattedAmount =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
    return formattedAmount;
  }
}
