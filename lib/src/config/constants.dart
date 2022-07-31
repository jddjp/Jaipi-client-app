import 'package:flutter/material.dart';
import 'package:jaipi/src/helpers/helpers.dart';

const primaryColor = Color(0xff0A1C49);

/*fonts*/
const fontRegular = FontWeight.normal;
const fontMedium = FontWeight.w500;
const fontSemibold = FontWeight.w600;
const fontBold = FontWeight.bold;
// const fontAntina = 'Andina';
/* font sizes*/
const textSizeSmall = 12.0;
const textSizeSMedium = 14.0;
const textSizeMedium = 16.0;
const textSizeLargeMedium = 18.0;
const textSizeNormal = 20.0;
const textSizeLarge = 24.0;
const textSizeXLarge = 34.0;

/* margin */

const spacing_control_half = 2.0;
const spacing_control = 4.0;
const spacing_standard = 8.0;
const spacing_middle = 10.0;
const spacing_standard_new = 16.0;
const spacing_large = 24.0;
const spacing_xlarge = 32.0;
const spacing_xxLarge = 40.0;

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(textSizeLarge),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const ORDER_RECEIVED = 'received';
const ORDER_IN_PROGRESS = 'progress';
const ORDER_READY = 'ready';
const ORDER_WAITING_DRIVER = 'waiting_driver';
const ORDER_WAITING_ORDER = 'waiting_order';
const ORDER_DELIVERING = 'delivering';
const ORDER_WAITING_CLIENT = 'waiting_client';
const ORDER_FINISHED = 'finished';
const ORDER_CANCELED = 'canceled';

//const ORDER_DRIVER_WAITING_DRIVER_STEP = 1;
//const ORDER_DRIVER_WAITING_ORDER_STEP = 2;
//const ORDER_DRIVER_DELIVERING_STEP = 3;
//const ORDER_DRIVER_WAITING_CLIENT_STEP = 4;
const ORDER_DRIVER_FINISHED_STEP = 5;

const ORDER_CLIENT_RECEIVED_STEP = 1;
const ORDER_CLIENT_IN_PROGRESS_STEP = 2;
const ORDER_CLIENT_DELIVERING_STEP = 3;
const ORDER_CLIENT_WAITING_CLIENT_STEP = 4;
const ORDER_CLIENT_FINISHED_STEP = 5;

const DELIVERY_COST_ZONE0 = 18.0;
const DELIVERY_COST_ZONE1 = 25.0;
const DELIVERY_COST_ZONE2 = 30.0;
const DELIVERY_COST_ZONE3 = 35.0;
const DELIVERY_COST_ZONE4 = 45.0;
const DELIVERY_COST_ZONE5 = 55.0;
const DELIVERY_COST_ZONE6 = 60.0;

const DELIVERY_ZONE0 = 1500.0;
const DELIVERY_ZONE1 = 2500.0;
const DELIVERY_ZONE2 = 4000.0;
const DELIVERY_ZONE3 = 5500.0;
const DELIVERY_ZONE4 = 6500.0;
const DELIVERY_ZONE5 = 7500.0;
const DELIVERY_ZONE6 = 10000.0;

const DISCOUNT_SUBTOTAL = 'order';
const DISCOUNT_DELIVERY = 'delivery';
const DISCOUNT_TOTAL = 'default';

const WEEK_DAYS = {
  "1": "monday",
  "2": "tuesday",
  "3": "wednesday",
  "4": "thursday",
  "5": "friday",
  "6": "saturday",
  "7": "sunday"
};

// Guerrero / Epicentro
const CITY_LATITUDE = 17.008190;
const CITY_LONGITUDE = -100.084067;
const WHATSAPPPHONE = '7811082699';
