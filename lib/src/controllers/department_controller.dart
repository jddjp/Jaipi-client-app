
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class DepartmentController extends ControllerMVC {

  bool isLoading = true;
  Map<String,dynamic> department;
  List<QueryDocumentSnapshot> categories;
  List<QueryDocumentSnapshot> businesses;

  DepartmentController(String docId) {
    print("============================");
    asyncData(docId);
  }

  void asyncData(String docId) async {
    DocumentReference departmentRef = FirebaseFirestore.instance.collection('departments').doc(docId);
    DocumentSnapshot departmentDoc = await departmentRef.get();

    // Categories
    QuerySnapshot categoriesSnapshot = await FirebaseFirestore.instance.collection('categories').where('department', isEqualTo: departmentRef)
    .orderBy('index')
    .get();
    
    // Businesses
    QuerySnapshot businessesSnapshot = await FirebaseFirestore.instance.collection('businesses')
    .where('department', isEqualTo: departmentRef).where('active', isEqualTo: true)
    .orderBy('created_at', descending: true)
    .get();

    // update
    setState(() {
      department = departmentDoc.data();
      categories = categoriesSnapshot.docs;
      businesses = businessesSnapshot.docs;
      isLoading = false;
    });
  }
}