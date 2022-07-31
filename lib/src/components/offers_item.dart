import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jaipi/src/config/config.dart';
import 'package:jaipi/src/helpers/helpers.dart';
import 'package:jaipi/src/views/views.dart';
import 'package:url_launcher/url_launcher.dart';

class OffersItem extends StatelessWidget {
  final Map<String, dynamic> offers;
  const OffersItem({Key key, this.offers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onOfferTap(offers, context),
      child: Container(
        decoration: boxDecoration(
          showShadow: true,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(spacing_middle)),
          child: CachedNetworkImage(
              imageUrl: offers['image']['url'], fit: BoxFit.cover),
        ),
      ),
    );
  }

  void _onOfferTap(offers, context) {
    switch (offers['behavior']) {
      case 'link':
        if (offers['target'] != null) {
          launch(offers['target']);
        }
        break;
      case 'business':
        if (offers['target'] != null) {
          launchScreen(context, BusinessView.routeName,
              arguments: offers['target']);
          //Navigator.of(context).pushNamed('business', arguments: offer.business);
        }
        break;
      case 'default':
        //launch(offers.content);
        break;
    }
  }
}
