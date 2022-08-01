import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jaipi/src/helpers/helpers.dart';
import 'package:jaipi/src/models/models.dart';
import 'package:jaipi/src/providers/providers.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';

class OrderController extends ControllerMVC {
  bool isLoading = true;
  Map<String, dynamic> businessSchedules = {};
  Map<String, dynamic> business = {};
  Map<String, String> errors = {};

  OrderItemModel orderItem;
  ItemModel item;
  // For make a orderItem
  List<ItemOptionModel> _itemOptions = [];
  List<SingleItemOption> _allOptions = []; // All sub options of any type

  // GETTERS
  List<ItemOptionModel> get itemOptions => _itemOptions;

  double get unitPrice {
    double price = getRealPrice(
        item.price, item.withDiscount, item.discount, item.discountType);
    double subtotal = 0.0;
    if (orderItem.options != null && orderItem.options.length > 0) {
      orderItem.options.forEach((option) {
        if (option['main'] == true) {
          price = option['total'];
        } else {
          subtotal += option['total'];
        }
      });
    }
    return subtotal + price;
  }

  double get totalPrice => orderItem.quantity * unitPrice;

  // Constructor
  OrderController(ItemModel itemData) {
    asyncData(itemData.id);
    // businessSchedules = itemData['schedules'];
    business = itemData.business;
  }

  // Get data from firebase
  void asyncData(itemId) async {
    // Document reference
    DocumentReference itemRef =
        FirebaseFirestore.instance.collection('items').doc(itemId);

    // Get item data
    DocumentSnapshot itemDoc = await itemRef.get();
    item = new ItemModel.fromJSON(itemDoc.data());

    orderItem = new OrderItemModel(
        id: getUID(6), // Generate order item ID
        item: item);

    // Get item options for orderItem
    QuerySnapshot querySnapshot =
        await itemRef.collection('options').orderBy('index').get();

    querySnapshot.docs.forEach((doc) {
      ItemOptionModel option =
          ItemOptionModel.fromJSON({...doc.data(), "id": doc.id});

      // Save all options
      option.options.forEach((element) {
        setState(() {
          _allOptions.add(element);
        });
      });

      setState(() {
        _itemOptions.add(option);
      });
    });

    // All is loaded
    setState(() {
      isLoading = false;
    });
  }

  void incrementQuantity() {
    if (orderItem.quantity <= 50) {
      setState(() {
        ++orderItem.quantity;
      });
    }
  }

  void decrementQuantity() {
    if (orderItem.quantity > 1) {
      setState(() {
        --orderItem.quantity;
      });
    }
  }

  void onChangeOption(ItemOptionModel option, dynamic selectedOptions) {
    //
    var orderItemOptions = orderItem.options != null ? orderItem.options : [];
    orderItemOptions.removeWhere((element) => element['optionId'] == option.id);

    selectedOptions.forEach((id, quantity) {
      var result = _allOptions.where((element) => element.id == id).toList();
      if (result.length > 0 && quantity > 0) {
        var itemOption = result[0];
        orderItemOptions.add({
          "optionId": option.id,
          "optionName": option.name,
          "main": option.main, // For calculate
          "type": option.type,
          // Single item data
          "name": itemOption.name,
          "price": itemOption.price,
          "quantity": quantity,
          "total": itemOption.price * quantity
        });
      }
    });

    orderItem.options = orderItemOptions;
    validateOption(option);
  }

  void validateOption(ItemOptionModel option) {
    // Search on selected items
    int minRequired =
        option.min == null ? (option.required == true ? 1 : 0) : option.min;
    var selectedOptions =
        orderItem.options.where((element) => element['optionId'] == option.id);
    int count = selectedOptions.length;

    if (option.type == 'addon') {
      count = 0;
      selectedOptions.forEach((option) {
        count += option['quantity'];
      });
    }

    if (count < minRequired) {
      errors[option.id] = "Elige $minRequired opciones";
    } else {
      errors[option.id] = null;
    }

    // Update state if not main price
    if (option.main == false) {
      setState(() {});
    }
  }

  bool addToCart(BuildContext context) {
    if (isBusinessClosed(business)) {
      Fluttertoast.showToast(msg: "Espera a que el negocio abra nuevamente.");
      return false;
    }

    if (itemOptions.length > 0) {
      itemOptions.forEach((option) {
        validateOption(option);
      });
    }

    // Remove NULL errors
    errors.removeWhere((key, value) => value == null);

    if (errors.length == 0) {
      // Set data
      orderItem.price = unitPrice;
      orderItem.total = totalPrice;
      // Add to cart
      Provider.of<CartProvider>(context, listen: false).addItem(orderItem);
    } else {
      Fluttertoast.showToast(msg: "Te falta confgiurar este producto");
    }

    return errors.length == 0;
  }
}
