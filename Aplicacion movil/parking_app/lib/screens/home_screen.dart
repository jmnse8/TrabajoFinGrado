import 'package:flutter/material.dart';
import 'package:parking_app/themes/app_theme.dart';
import 'package:parking_app/widgets/widgets.dart';

import 'package:parking_app/models/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondary,
      appBar: AppBar(
        title: const Text('Parking automático'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          CarCard(
            car: Car(
                id: '1',
                carImage:
                    'https://static.motor.es/fotos-noticias/2021/01/chevrolet-camaro-ford-mustang-dodge-challenger-ventas-2020-202174502-1610712872_2.jpg',
                carName: 'Chevrolet Camaro',
                carPlate: '1492 AEE',
                status: true),
          ),
          const SizedBox(height: 20),
          CarCard(
            car: Car(
                id: '2',
                carImage:
                    'https://cdn.car-recalls.eu/wp-content/uploads/2020/04/honda-civic-2009-recall-768x512.jpg',
                carName: 'Honda Civic',
                carPlate: '2000 JMN',
                status: false),
          ),
          const SizedBox(height: 20),
          CarCard(
            car: Car(
              id: '3',
              carName: 'Hyundai Atos',
              carPlate: '2001 TSE',
              status: false,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
