import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jaipi/src/components/components.dart';
import 'package:jaipi/src/config/config.dart';
import 'package:jaipi/src/helpers/helpers.dart';

class CategoryView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'category';
  final String categoryName;

  CategoryView({Key key, this.categoryName}) : super(key: key);

  @override
  _CategoryViewState createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  Future<QuerySnapshot> _businessSnapshot;

  void initState() {
    // Query all categories
    _businessSnapshot = FirebaseFirestore.instance
        .collection('businesses')
        .where('categories', arrayContains: widget.categoryName)
        .where('active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .get();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: text(widget.categoryName,
              fontWeight: fontSemibold, fontSize: textSizeNormal),
          backgroundColor: whiteColor,
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(children: [
          SearchInputWidget(),
          SizedBox(
            height: spacing_large,
          ),
          mHeading("Negocios"),
          SizedBox(
            height: spacing_large,
          ),
          FutureBuilder(
              future: _businessSnapshot,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data.docs.length == 0) {
                  return Center(
                    child: text("Esperalos muy pronto", textColor: blackColor),
                  );
                }
                return ListView.builder(
                    primary: false,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return BusinessItem(business: {
                        ...snapshot.data.docs[index].data(),
                        "id": snapshot.data.docs[index].id,
                      });
                    });
              }),
        ]))));
  }
}
