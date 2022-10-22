import 'package:flutter/material.dart';

class Car {
  Car({
    this.carImage,
    this.heroId,
    required this.carName,
    required this.carPlate,
    required this.status,
    required this.id,
  });

  String id;
  String? carImage;
  String carName;
  String carPlate;
  bool status;
  String? heroId;

  get fullCarImage {
    return (carImage != null)
        ? carImage
        : 'https://i.stack.imgur.com/GNhxO.png';
  }

  get statusText {
    return (status) ? 'DENTRO' : 'FUERA';
  }

  get statusColor {
    return (status) ? Colors.green : Colors.red;
  }
}
