import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaipi/src/models/models.dart';

class ItemModel {
  String id;
  bool active;
  Map<String, dynamic> business;
  String description;
  double discount;
  String discountType;
  bool featured;
  ImageModel image;
  int index;
  List<dynamic> keywords;
  bool multiplePrice;
  String name;
  double price = 0.0;
  // section
  bool withDiscount;

  ItemModel(
      {this.id,
      this.active,
      this.description,
      this.discount,
      this.discountType,
      this.featured,
      this.image,
      this.index,
      this.keywords,
      this.multiplePrice,
      this.name,
      this.price,
      this.withDiscount});

  ItemModel.fromJSON(Map<String, dynamic> json) {
    try {
      id = json['id'];
      business = json['business'] is DocumentReference
          ? {"id": json['business'].id}
          : (json['business'] is String
              ? {"id": json['business']}
              : json['business']);
      active = json['active'] ?? true;
      description = json['description'];
      discount = json['discount'] != null ? json['discount'].toDouble() : 0.0;
      discountType = json['discount_type'];
      featured = json['featured'] ?? false;
      image = json['image'] != null ? ImageModel.fromJSON(json['image']) : null;
      index = json['index'] != null ? json['index'].toInt() : 1;
      keywords = json['keywords'];
      multiplePrice = json['multiple_price'] ?? false;
      name = json['name'];
      price = json['price'] != null ? json['price'].toDouble() : 0.0;
      withDiscount = json['with_discount'] ?? false;
    } catch (e) {
      print("ItemModel: Error");
      print(e);
    }
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'business': business,
      'active': active,
      'description': description,
      'discount': discount,
      'discount_type': discountType,
      'featured': featured,
      'image': image,
      'index': index,
      'keywords': keywords,
      'multiple_price': multiplePrice,
      'name': name,
      'price': price,
      'with_discount': withDiscount
    };
  }
}
