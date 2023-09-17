import 'package:flutter/material.dart';

class Restaurant {
  String? key;
  RestaurantData? restaurantData;

  Restaurant({this.key, this.restaurantData});
}

class RestaurantData {
  String? name;
  String? typeOfFood;
  String? address;
  TimeOfDay? start;
  TimeOfDay? end;

  RestaurantData(
      {required this.name,
      required this.typeOfFood,
      required this.address,
      required this.start,
      required this.end});

  RestaurantData.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    typeOfFood = json['typeOfFood'];
    address = json['address'];
    start = TimeOfDay(hour: int.parse(json['start'].toString().split(":")[0]), minute: int.parse(json['start'].toString().split(":")[1]));
    end = TimeOfDay(hour: int.parse(json['end'].toString().split(":")[0]), minute: int.parse(json['end'].toString().split(":")[1]));;
  }
}
