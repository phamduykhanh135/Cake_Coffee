import 'dart:math';

import 'package:cake_coffee/models/khanh/customers.dart';
import 'package:cake_coffee/presents/khanh/add_customers.dart';
import 'package:cake_coffee/presents/khanh/edit_customer.dart';
import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final TextEditingController _phoneController = TextEditingController();
  List<DocumentSnapshot> _customers = [];
  bool _loading = true;
  List<Customers> customers = [];

  final List<Color> _cardColors = [
    const Color.fromARGB(255, 48, 81, 107),
    const Color.fromARGB(255, 58, 94, 59),
    const Color.fromARGB(255, 108, 84, 47),
    const Color.fromARGB(255, 115, 47, 127),
    const Color.fromARGB(255, 136, 73, 72),
    const Color.fromARGB(255, 42, 95, 90),
    const Color.fromARGB(255, 86, 52, 40),
    const Color.fromARGB(255, 131, 82, 82),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _phoneController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onSearchChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onAddCustomer(Customers newCustomer) {
    // Thêm khách hàng mới vào Firestore
    FirebaseFirestore.instance
        .collection('customers')
        .add(newCustomer.toMap())
        .then((value) {
      // Sau khi thêm thành công, làm mới danh sách khách hàng
      _fetchCustomers();
    }).catchError((error) {
      print('Error adding customer: $error');
    });
  }

  Future<void> _fetchCustomers() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('customers').get();

      setState(() {
        _customers = querySnapshot.docs;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching customers: $e');
    }
  }

  void _filterCustomers(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      _fetchCustomers();
    } else {
      setState(() {
        _loading = true;
      });

      FirebaseFirestore.instance
          .collection('customers')
          .where('phone', isEqualTo: phoneNumber)
          .get()
          .then((QuerySnapshot querySnapshot) {
        setState(() {
          _customers = querySnapshot.docs;
          _loading = false;
        });
      }).catchError((error) {
        print('Error filtering customers: $error');
      });
    }
  }

  void _onSearchChanged() {
    if (_phoneController.text.isEmpty) {
      _fetchCustomers();
    }
  }

  void loadCustomers() async {
    List<Customers> fetchedUsers = await fetchUsersFromFirestore();
    setState(() {
      customers = fetchedUsers;
    });
  }

  Color _getRandomColor() {
    Random random = Random();
    return _cardColors[random.nextInt(_cardColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Khách Hàng'),
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
            child: roundedElevatedButton(
                onPressed: () {
                  AddCustomers.openAddCustomerDialog(context, _onAddCustomer);
                },
                text: "Thêm",
                backgroundColor: Colors.green),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Tìm kiếm theo số điện thoại',
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  _filterCustomers(
                                      _phoneController.text.trim());
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: _customers.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot customer = _customers[index];
                      Color cardColor = _getRandomColor();

                      return AspectRatio(
                        aspectRatio: 1.0,
                        child: Stack(
                          children: [
                            Card(
                              color: cardColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        customer['name'] ?? 'Không có tên',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        customer['phone'] ??
                                            'Không có số điện thoại',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Điểm: ${customer['point'] ?? 0}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  _openEditCustomerDialog(context, customer);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }

  void _deleteCustomerFromList(String customerId) {
    setState(() {
      _fetchCustomers();
      customers.removeWhere((customer) => customer.id == customerId);
    });
  }

  void _updateCustomerInList(Customers updatedCustomers) {
    setState(() {
      int index =
          customers.indexWhere((user) => user.id == updatedCustomers.id);
      if (index != -1) {
        customers[index] = updatedCustomers;
      }
      _fetchCustomers();
    });
  }

  void _openEditCustomerDialog(
      BuildContext context, DocumentSnapshot customerSnapshot) async {
    Customers customer = Customers(
      id: customerSnapshot.id,
      name: customerSnapshot['name'],
      phone: customerSnapshot['phone'],
      point: customerSnapshot['point'] ?? 0,
      password: '', // Provide default value or handle as necessary
      created_at: null, // Provide default value or handle as necessary
    );

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCustomerPage(
          customers: customer,
          onUpdateCustomer: _updateCustomerInList,
          onDeleteCustomer: _deleteCustomerFromList,
        );
      },
    );
  }
}
