import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jaipi/src/config/colors.dart';
import 'package:jaipi/src/config/constants.dart';
import 'package:jaipi/src/helpers/extension_helper.dart';
import 'package:jaipi/src/helpers/widget_helper.dart';
import 'package:jaipi/src/providers/cart_provider.dart';
import 'package:jaipi/src/providers/location_provider.dart';
import 'package:jaipi/src/services/address_search_delegate.dart';
import 'package:jaipi/src/services/google_places_service.dart';
import 'package:jaipi/src/views/address_confirmation_view.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddressesView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'addresses';

  AddressesView({Key key}) : super(key: key);

  @override
  _AddressesViewState createState() => _AddressesViewState();
}

class _AddressesViewState extends State<AddressesView> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Place currentPlace =
        Provider.of<LocationProvider>(context, listen: false).getAddress();
    return Scaffold(
      body: LoadingOverlay(
          isLoading: _isLoading,
          child: SafeArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  back(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: food_textColorPrimary,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            left: spacing_standard_new,
                            right: spacing_standard_new),
                        child: text("Agrega o escoge una dirección",
                            fontSize: textSizeLarge,
                            fontWeight: fontSemibold,
                            maxLine: 2),
                      ),
                      SizedBox(
                        height: spacing_standard_new,
                      ),
                      Container(
                        decoration:
                            boxDecoration(radius: 10, color: food_view_color),
                        margin: EdgeInsets.symmetric(
                            horizontal: spacing_standard_new),
                        child: GestureDetector(
                          onTap: () async {
                            // generate a new token here
                            final sessionToken = Uuid().v4();
                            final Suggestion result = await showSearch(
                              context: context,
                              delegate: AddressSearchDelegate(sessionToken),
                            );
                            setState(() {
                              _isLoading = true;
                            });
                            // This will change the text displayed in the TextField
                            if (result != null) {
                              final selectedAddress = await PlaceApiProvider()
                                  .getPlaceDetailFromId(result.placeId);
                              launchScreen(
                                  context, AddressConfirmationView.routeName,
                                  arguments: selectedAddress);
                            }

                            setState(() {
                              _isLoading = false;
                            });
                          },
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Icon(
                                    Icons.search,
                                    color: food_textColorSecondary,
                                  )),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.only(
                                    right: 26.0,
                                    top: 12.0,
                                    bottom: 12.0,
                                    left: 50.0),
                                child: text("Buscar dirección"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          setState(() {
                            _isLoading = true;
                          });

                          final location = await Provider.of<LocationProvider>(
                                  context,
                                  listen: false)
                              .getLocation();

                          final selectedAddress = await PlaceApiProvider()
                              .getAddressFromLatLng(location);
                          launchScreen(
                              context, AddressConfirmationView.routeName,
                              arguments: selectedAddress);

                          setState(() {
                            _isLoading = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(spacing_standard_new),
                          child: Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Icon(Icons.my_location,
                                      color: food_colorPrimary, size: 18)),
                              text("Usar ubicación actual",
                                  textColor: food_colorPrimary)
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                      StreamBuilder<QuerySnapshot>(
                          stream: Provider.of<LocationProvider>(context)
                              .getUserAddresses(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Something went wrong');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            return ListView.separated(
                              primary: false,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                DocumentSnapshot doc =
                                    snapshot.data.docs[index];
                                Place place = Place.fromJson(doc.data());
                                return ListTile(
                                  onTap: () async {
                                    await Provider.of<LocationProvider>(context,
                                            listen: false)
                                        .setPlace(place);
                                    await Provider.of<CartProvider>(context,
                                            listen: false)
                                        .setAddress(place);
                                    back(context);
                                  },
                                  title: text(place.street,
                                      fontWeight: fontSemibold),
                                  subtitle: place.alias != null
                                      ? text(place.alias)
                                      : null,
                                  trailing: currentPlace.street == place.street
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.check_circle,
                                            color: appColorAccent,
                                          ),
                                          onPressed: null)
                                      : IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            deleteAddress(context, doc.id);
                                          },
                                        ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider();
                              },
                            );
                          })
                    ],
                  ),
                ),
              )
            ],
          ))),
    );
  }

  void deleteAddress(BuildContext context, String addressId) {
    Widget cancelButton = FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("No"));

    Widget okButton = FlatButton(
        onPressed: () {
          Provider.of<LocationProvider>(context, listen: false)
              .deleteAddress(addressId);
          Navigator.of(context).pop();
        },
        child: Text("Eliminar"));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("¿Eliminar dirección?"),
            content: Text("Esta acción no se puede revertir."),
            actions: [cancelButton, okButton],
          );
        });
  }
}
