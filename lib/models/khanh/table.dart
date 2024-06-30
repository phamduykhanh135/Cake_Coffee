// import 'package:cloud_firestore/cloud_firestore.dart';

// class Tables {
//   String id;
//   String id_area;
//   String name;
//   DateTime? create_time;
//   DateTime? update_time;
//   DateTime? delete_time;

//   Tables(
//       {required this.id,
//       required this.id_area,
//       required this.name,
//       required this.create_time,
//       required this.update_time,
//       required this.delete_time});

//   factory Tables.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data() as Map<String, dynamic>;
//     return Tables(
//       id: doc.id,
//       id_area: data['id_area'] ?? '',
//       name: data['name'] ?? '',
//       create_time: data['create_time'] != null
//           ? (data['create_time'] as Timestamp).toDate()
//           : null,
//       update_time: data['update_time'] != null
//           ? (data['update_time'] as Timestamp).toDate()
//           : null,
//       delete_time: data['delete_time'] != null
//           ? (data['delete_time'] as Timestamp).toDate()
//           : null,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id_are': id_area,
//       'name': name,
//       'create_time': create_time,
//       'update_time': update_time,
//       'delate_time': delete_time
//     };
//   }
// }

// Future<List<Tables>> fetchTablesFromFirestore() async {
//   try {
//     QuerySnapshot querySnapshot =
//         await FirebaseFirestore.instance.collection('tables').get();
//     return querySnapshot.docs.map((doc) => Tables.fromFirestore(doc)).toList();
//   } catch (e) {
//     print("Error ferching products:$e");
//     return [];
//   }
// }
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
      status: data['status'] ?? 'empty',
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
