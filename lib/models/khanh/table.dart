import 'package:cloud_firestore/cloud_firestore.dart';

class Tables {
  String id;
  String id_area;
  String name;
  String status;

  Tables({
    required this.id,
    required this.id_area,
    required this.name,
    required this.status,
  });

  factory Tables.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Tables(
      id: doc.id,
      id_area: data['id_area'] ?? '',
      name: data['name'] ?? '',
      status: data['status'] ?? 'Trống',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_are': id_area,
      'name': name,
      'status': status,
    };
  }
}

Future<List<Tables>> fetchTablesFromFirestore() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('tables').get();
    return querySnapshot.docs.map((doc) => Tables.fromFirestore(doc)).toList();
  } catch (e) {
    print("Error ferching products:$e");
    return [];
  }
}
