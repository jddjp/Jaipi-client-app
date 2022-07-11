
class ItemOptionModel {
  String id;
  String name;
  String type;
  bool required;
  bool multiple;
  bool main;
  bool active;
  int min;
  int max;
  int index;
  List<SingleItemOption> options = [];

  ItemOptionModel({
    this.id,
    this.name,
    this.type,
    this.required,
    this.multiple,
    this.main,
    this.min,
    this.max,
    this.index,
    this.options
  });

  ItemOptionModel.fromJSON(Map<String,dynamic> json) {
    try {
      id = json['id'];
      name = json['name'];
      type = json['type'];
      required = json['required'];
      multiple = json['multiple'];
      main = json['main'];
      min = json['min'];
      max = json['max'];
      index = json['index'];
      json['options']?.forEach((option) {
        options.add(SingleItemOption.fromJSON(option));
      });
    } catch (e) {
      print("ItemOptionModel: Error");
      print(e);
    }
  }
}

class SingleItemOption {
  String id;
  String name;
  double price;
  double discount;
  String discountType;
  bool withDiscount;
  bool active;

  SingleItemOption({
    this.id,
    this.name,
    this.price,
    this.discount,
    this.discountType,
    this.withDiscount,
    this.active
  });

  SingleItemOption.fromJSON(Map<String,dynamic> json) {
    try {
      id = json['id'];
      name = json['name'];
      price = json['price'] != null ? json['price'].toDouble() : 0.0;
      discount = json['discount'] != null ? json['discount'].toDouble() : 0.0;
      discountType = json['discount_type'];
      withDiscount = json['with_discount']??false;
      active = json['active']??true;
    } catch (e) {
      print("SingleItemOption: Error");
      print(e);
    }
  }

  Map<String, dynamic> toJSON () {
    return {
      'id': id,
      'name': name,
      'price': price,
      'discount': discount,
      'discount_type': discountType,
      'with_discount': withDiscount,
      'active': active
    };
  }
}