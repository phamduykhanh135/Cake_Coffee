import 'package:cloud_firestore/cloud_firestore.dart';

class Area {
  String id;
  String name;
  DateTime? create_time;
  DateTime? update_time;
  DateTime? delete_time;

  Area(
      {required this.id,
      required this.name,
      required this.create_time,
      required this.update_time,
      required this.delete_time});

  factory Area.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Area(
      id: doc.id,
      name: data['name'] ?? '',
      create_time: data['create_time'] != null
          ? (data['create_time'] as Timestamp).toDate()
          : null,
      update_time: data['create_time'] != null
          ? (data['create_time'] as Timestamp).toDate()
          : null,
      delete_time: data['create_time'] != null
          ? (data['create_time'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'create_tiem': create_time,
      'update_time': update_time,
      'delete_time': delete_time,
    };
  }
}

Future<List<Area>> fetchAreasFromFirestore() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('areas').get();
    return querySnapshot.docs.map((doc) => Area.fromFirestore(doc)).toList();
  } catch (e) {
    print('Error fetching area:$e');
    return [];
  }
}
