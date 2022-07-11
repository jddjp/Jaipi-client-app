import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:jaipi/src/components/business_item.dart';
import 'package:jaipi/src/components/highlight_text.dart';
import 'package:jaipi/src/components/item_widget.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/models/item_model.dart';
import 'package:jaipi/src/services/algolia_service.dart';
import 'package:loading_overlay/loading_overlay.dart';

class CustomSearchDelegate extends SearchDelegate {
  final _algoliaApp = AlgoliaService.algolia;
  final Map<String, dynamic> business;

  @override
  String get searchFieldLabel =>
      business != null ? "Buscar en ${business['name']}..." : "Buscar...";

  TextStyle get searchFieldStyle => TextStyle(fontSize: textSizeMedium);

  // Constructor
  CustomSearchDelegate({this.business});

  Future<List<AlgoliaObjectSnapshot>> searchOperation(
      String index, String value) async {
    AlgoliaQuery query = _algoliaApp.instance.index(index).search(value);
    // Search on especified business
    if (business != null && index != "keywords") {
      query = query.setFacetFilter("business:${business['id']}");
    }
    AlgoliaQuerySnapshot querySnapshot = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnapshot.hits;

    return results;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Show empty
    if (query.isEmpty) {
      _emptySuggestions(context);
    }

    return StreamBuilder(
      stream: Stream.fromFuture(
          searchOperation(business != null ? "items" : "businesses", query)),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingOverlay(isLoading: true, child: Container());
        }

        List<AlgoliaObjectSnapshot> result = snapshot.data;
        if (result.length == 0) {
          return _emptyResults();
        }

        return Container(
          padding: EdgeInsets.only(top: spacing_standard_new),
          child: ListView.builder(
            primary: false,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: result.length,
            itemBuilder: (BuildContext context, int index) {
              return business != null
                  ? ItemWidget(item: new ItemModel.fromJSON({
                      ...result[index].data,
                      "id": result[index].objectID
                    }))
                  : BusinessItem(business: {
                      ...result[index].data,
                      "id": result[index].objectID,
                    });
            }),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _emptySuggestions(context);
    }

    return StreamBuilder(
      stream: Stream.fromFuture(searchOperation("keywords", query)),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingOverlay(isLoading: true, child: Container());
        }

        List<AlgoliaObjectSnapshot> queries = snapshot.data;

        return ListView.builder(
            itemCount: queries.length + 1,
            itemBuilder: (context, index) {
              bool isLast = index >= queries.length;
              final _query = isLast == false
                  ? queries[index].data
                  : {"name": query.toLowerCase()};

              return ListTile(
                leading: isLast
                    ? null
                    : Icon(Icons.search, color: textSecondaryColor),
                title: HighlightText(
                  text: _query['name'],
                  highlight: query.toLowerCase(),
                  isLast: isLast,
                ),
                trailing:
                    Icon(Icons.keyboard_arrow_right, color: textSecondaryColor),
                onTap: () {
                  query = isLast ? query : _query['name'];
                  showResults(context);
                },
              );
            });
      },
    );
  }

  Widget _emptySuggestions(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Icon(Icons.search, size: 100.0, color: Colors.grey[300]),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 17.0),
            child: text(
                "Encuentra tus ${business != null ? 'productos' : 'negocios'} favoritos"),
          )
        ],
      ),
    );
  }

  Widget _emptyResults() {
    return Container(
      padding: EdgeInsets.all(spacing_standard_new),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.search_sharp, size: 100.0, color: Colors.grey[300]),
          SizedBox(
            height: spacing_xlarge,
          ),
          text("No se encontraron resultados para $query",
              maxLine: null, isCentered: true)
        ],
      ),
    );
  }
}
