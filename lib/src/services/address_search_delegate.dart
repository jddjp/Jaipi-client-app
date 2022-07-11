import 'package:flutter/material.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/services/google_places_service.dart';
import 'package:jaipi/src/views/address_confirmation_view.dart';
import 'package:loading_overlay/loading_overlay.dart';

class AddressSearchDelegate extends SearchDelegate<Suggestion> {
  @override
  String get searchFieldLabel => "Buscar dirección...";
  TextStyle get searchFieldStyle => TextStyle(fontSize: textSizeMedium);

  AddressSearchDelegate(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken: sessionToken);
  }

  final sessionToken;
  PlaceApiProvider apiClient;

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
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _emptySuggestions(context);
    }

    return FutureBuilder(
      // We will put the api call here
      future: apiClient.fetchSuggestions(query),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingOverlay(isLoading: true, child: Container());
        }

        return ListView.separated(
          itemBuilder: (context, index) {
            bool isLast = index >= snapshot.data.length;
            final _address = isLast == false
                ? (snapshot.data[index] as Suggestion)
                : new Suggestion('_fake_', '¿No encuentras la dirección?',
                    'Fija la dirección en el mapa');

            return ListTile(
              leading: isLast == false
                  ? null
                  : Icon(Icons.location_searching, color: textSecondaryColor),
              title: text(_address.address, fontWeight: fontBold),
              subtitle: text(_address.description),
              onTap: () {
                if (isLast) {
                  launchScreen(context, AddressConfirmationView.routeName);
                } else {
                  close(context, _address);
                }
              },
            );
          },
          itemCount: snapshot.data.length + 1,
          separatorBuilder: (context, index) {
            return Divider();
          },
        );
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
            child: text("¿A dónde enviarémos tu pedido?"),
          )
        ],
      ),
    );
  }
}
