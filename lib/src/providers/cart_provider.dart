import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jaipi/src/config/config.dart';
import 'package:jaipi/src/helpers/helpers.dart';
import 'package:jaipi/src/models/models.dart';
import 'package:jaipi/src/providers/providers.dart';
import 'package:jaipi/src/services/services.dart';
import 'package:jaipi/src/views/views.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  SharedPreferences _prefs;
  OrderModel _order;
  String _orderInProgress;
  bool hasService = true; // We have service on client address?
  Map<String, dynamic> _coupon;
  Map<String, dynamic> _business;

  // Getter
  OrderModel get order => _order;
  List<OrderItemModel> get items => _order != null ? _order.items : [];
  String get orderInProgress => _orderInProgress;
  Map<String, dynamic> get coupon => _coupon;
  bool get hasCoupon => _coupon != null;

  // Constructor
  CartProvider() {
    // Initialize cart model
    initialize();
  }

  void initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _order = new OrderModel();

    // Checking order in progress
    checkOrderInProgress();

    // delete preview cartWithItems used by no loggedin user
    _prefs.setBool("cartWithItems", false);

    // Calulcate user distance
    calculateDeliveryData();

    notifyListeners();
  }

  bool hasItems() => items.length > 0;
  bool hasOrderInProgress() {
    return _orderInProgress != null && _orderInProgress != '';
  }

  void checkOrderInProgress() async {
    _prefs = await SharedPreferences.getInstance();
    // Check for a order in progress
    _orderInProgress = _prefs.getString('orderInProgress');
    if (hasOrderInProgress()) {
      // Get order info
      DocumentSnapshot orderRef = await FirebaseFirestore.instance
          .collection('orders')
          .doc(_orderInProgress)
          .get();
      Map<String, dynamic> currentOrder = orderRef.data();

      // Delete order in progress
      if (currentOrder == null ||
          currentOrder['status'] == ORDER_FINISHED ||
          currentOrder['status'] == ORDER_CANCELED) {
        clearOrderInProgress();
        notifyListeners();
      }
    }
  }

  void addItem(OrderItemModel orderItem) {
    if (_order.business != null &&
        orderItem.item.business['id'] != _order.business.id) {
      Fluttertoast.showToast(
          msg:
              "No puedes hacer un pedido de diferentes negocios al mismo tiempo.");
      return;
    }

    if (hasOrderInProgress()) {
      Fluttertoast.showToast(
          msg:
              "No puedes ordenar hasta que se complete tu pedido en progreso.");
      return;
    }

    _order.business = FirebaseFirestore.instance
        .collection('businesses')
        .doc(orderItem.item.business['id']);
    _order.items.add(orderItem);
    notifyListeners();
  }

  void removeItem(String id) {
    _order.items.removeWhere((element) => element.id == id);

    if (_order.items.length == 0) {
      _order.business = null;
    }

    notifyListeners();
  }

  /*
   * Check if cart is empty
   */
  bool isEmpty() {
    return _order == null || _order.items.length == 0;
  }

  void clearOrderInProgress() {
    _prefs.remove('orderInProgress');
    _orderInProgress = null;
    deleteCoupon();
    notifyListeners();
  }

  Future<void> setAddress(Place place) async {
    // Set new address
    _order.deliveryAddress = place;

    // Calculate new deliveryData
    await calculateDeliveryData();

    //
    notifyListeners();

    return Future.value();
  }

  Future<void> setBusiness(String businessId) async {
    DocumentReference businessRef =
        FirebaseFirestore.instance.collection('businesses').doc(businessId);

    // Load business data
    DocumentSnapshot businessDoc = await businessRef.get();
    _business = {...businessDoc.data(), "id": businessDoc.id};

    await calculateDeliveryData();

    notifyListeners();

    return Future.value();
  }

  /*Place getAddress(BuildContext context) {
    // Get from location
    if (_order.deliveryAddress == null) {
      _order.deliveryAddress =
          Provider.of<LocationProvider>(context).getAddress();
    }

    return _order.deliveryAddress;
  } */

  /*LatLng getLocation(BuildContext context) {
    if (_order.location == null) {
      _order.location = Provider.of<LocationProvider>(context).getLocation();
    }

    return _order.location;
  } */

  Future<void> calculateDeliveryData() async {
    _prefs = await SharedPreferences.getInstance();
    LatLng userLocation;
    LatLng centerLocation = LatLng(CITY_LATITUDE, CITY_LONGITUDE); // Epicentro

    // Get from business
    if (_business != null && _business['location'] != null) {
      centerLocation = LatLng(
          _business['location'].latitude, _business['location'].longitude);
    }

    if (_prefs.getString('userPlace') != null) {
      final userPlace = jsonDecode(_prefs.getString('userPlace'));
      _order.deliveryAddress = Place.fromJson(userPlace);
      userLocation = _order.deliveryAddress.location;
    } else {
      // Default location
      userLocation = LatLng(CITY_LATITUDE, CITY_LONGITUDE);
    }

    // Calculate delivery distance
    double distance = userLocation != null
        ? await DistanceApiProvider().getDistance(centerLocation, userLocation)
        : DELIVERY_ZONE6 + 1;

    _order.distance = distance;

    // San Martín Centro
    hasService = true;
    if (_order.distance < DELIVERY_ZONE0) {
      _order.deliveryCost = DELIVERY_COST_ZONE0;
    } else if (_order.distance < DELIVERY_ZONE1) {
      _order.deliveryCost = DELIVERY_COST_ZONE1;
    } else if (_order.distance < DELIVERY_ZONE2) {
      _order.deliveryCost = DELIVERY_COST_ZONE2;
    } else if (_order.distance < DELIVERY_ZONE3) {
      _order.deliveryCost = DELIVERY_COST_ZONE3;
    } else if (_order.distance < DELIVERY_ZONE4) {
      _order.deliveryCost = DELIVERY_COST_ZONE4;
    } else if (_order.distance < DELIVERY_ZONE5) {
      _order.deliveryCost = DELIVERY_COST_ZONE5;
    } else if (_order.distance < DELIVERY_ZONE6) {
      _order.deliveryCost = DELIVERY_COST_ZONE6;
    } else {
      hasService = false;
    }

    notifyListeners();

    return Future.value();
  }

  Future<String> validateCoupon(String couponCode) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('coupons')
        .where("code", isEqualTo: couponCode.toUpperCase())
        .get();

    if (result.size > 0) {
      Map<String, dynamic> couponData = result.docs[0].data();

      // Validate date
      final today = DateTime.now();
      final startDate =
          DateFormat('yyyy-MM-dd').parse(couponData['start_date']);
      final endDate = DateFormat('yyyy-MM-dd').parse(couponData['end_date']);

      if (today.isAfter(startDate) && today.isBefore(endDate) ||
          today.difference(endDate).inDays == 0) {
        _coupon = couponData;
        notifyListeners();
        return Future.value("success");
      }
    }

    return Future.value("error");
  }

  void deleteCoupon() {
    _coupon = null;
    notifyListeners();
  }

  double couponDiscount() {
    if (_coupon != null) {
      switch (_coupon['target']) {
        case DISCOUNT_SUBTOTAL:
          return calculateDiscount(order.subtotal);
          break;
        case DISCOUNT_DELIVERY:
          return calculateDiscount(order.deliveryCost);
          break;
        case DISCOUNT_TOTAL:
          return calculateDiscount(order.total);
          break;
      }
    }

    return 0.0;
  }

  String discountLabel() {
    String label = "Cupón de descuento";
    if (_coupon != null && _coupon['discount_type'] == 'percentage') {
      return label + " ${_coupon['amount']}%";
    }

    return label;
  }

  double calculateDiscount(amount) {
    double couponAmount = _coupon['amount'].toDouble();
    double discount = _coupon['discount_type'] == 'fixed'
        ? couponAmount
        : (amount * (couponAmount / 100));
    return discount;
  }

  double deliveryCost() {
    if (_coupon != null && _coupon['target'] == DISCOUNT_DELIVERY) {
      return order.deliveryCost - calculateDiscount(order.deliveryCost);
    }

    return order.deliveryCost;
  }

  double orderTotal() {
    double total = order.subtotal;

    if (_coupon != null) {
      switch (_coupon['target']) {
        case DISCOUNT_SUBTOTAL:
          total = total - couponDiscount() + order.deliveryCost;
          break;
        case DISCOUNT_DELIVERY:
          total = total + deliveryCost();
          break;
        case DISCOUNT_TOTAL:
          total = (total + order.deliveryCost) - couponDiscount();
          break;
      }
    } else {
      total += order.deliveryCost;
    }

    return total;
  }

  Future<DocumentReference> createOrder(BuildContext context) async {
    if (!Provider.of<LoginProvider>(context, listen: false).isLoggedIn()) {
      _prefs.setBool(
          "cartWithItems", true); // This hack will be used on main.dart
      launchScreen(context, LoginView.routeName);
      return Future.error("No logged");
    }

    CollectionReference orders =
        FirebaseFirestore.instance.collection('orders');
    DocumentReference client = FirebaseFirestore.instance
        .collection('users')
        .doc(_prefs.getString('uid'));

    if (_order.deliveryAddress == null) {
      _order.deliveryAddress =
          Provider.of<LocationProvider>(context, listen: false).getAddress();
      // _order.location = _order.deliveryAddress.location;

      if (_order.deliveryAddress.street == "Sin dirección") {
        Fluttertoast.showToast(msg: "Ingresa la dirección de envío.");
        return Future.error("Unknow address");
      }
    }

    DocumentSnapshot businessDoc = await _order.business.get();
    Map<String, dynamic> businessData = businessDoc.data();
    DocumentSnapshot clientDoc = await client.get();
    Map<String, dynamic> clientData = clientDoc.data();
    String phoneNumber = clientData['phone'];
    if (phoneNumber != null && phoneNumber.startsWith("+52")) {
      phoneNumber = phoneNumber.replaceAll("+", "").replaceFirst("52", "");
    }
    print(businessData['location']);
    // Make order
    DocumentReference order = await orders.add({
      'number': getUID(6),
      'business': _order.business,
      'business_name': businessData['name'],
      'business_address': businessData['address'],
      'business_location': GeoPoint(businessData['location'].latitude,
          businessData['location'].longitude),
      'client': client,
      'client_name': clientData['name'],
      'client_phone': phoneNumber.toString(),
      'client_address':
          "${_order.deliveryAddress.street}, ${_order.deliveryAddress.sublocality}",
      'client_address_instructions': _order.deliveryAddress.instructions,
      'client_address_city': _order.deliveryAddress.city,
      'client_location': GeoPoint(_order.deliveryAddress.location.latitude,
          _order.deliveryAddress.location.longitude),
      'subtotal': _order.subtotal,
      'delivery_cost': deliveryCost(),
      'delivery_distance': _order.distance,
      'discount': couponDiscount(),
      'total': orderTotal(),
      'payment_method': _order.paymentMethod,
      'payment_status': 'pending',
      'coupon': _coupon != null ? _coupon['code'] : null,
      'status': 'received',
      'status_step': 1,
      'time':
          FieldValue.serverTimestamp(), // Time when this order has been created
      'comment': _order.comment != '' ? _order.comment : 'Sin comentarios',
      'items': items.map((OrderItemModel item) {
        return {
          'name': item.item.name,
          'image': item.item.image != null ? item.item.image.url : null,
          'description': item.item.description,
          'quantity': item.quantity,
          'comment': item.comment,
          'subtotal': item.price,
          'total': item.total,
          'options': item.options
        };
      }).toList(),
      'order_processor': businessData['order_processor'],
      'driver_current_step': 1, // For driver
    });

    // Save current order
    _prefs.setString('orderInProgress', order.id);

    // Reset current
    _order = new OrderModel();
    notifyListeners();

    // Finished
    return Future.value(order);
  }
}
