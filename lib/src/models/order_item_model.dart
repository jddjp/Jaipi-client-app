import 'package:jaipi/src/models/models.dart';

class OrderItemModel {
  String id;
  ItemModel item;
  int quantity;
  double price;
  String comment;
  double total;
  List options = [];

  OrderItemModel({
    this.id,
    this.item,
    this.quantity = 1,
    this.price,
    this.comment,
    this.total,
    //this.options = []
  });
}
