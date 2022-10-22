import 'package:flutter/material.dart';
import 'package:parking_app/models/models.dart';
import 'package:parking_app/themes/app_theme.dart';

class CarCard extends StatelessWidget {
  final Car car;

  const CarCard({
    Key? key,
    required this.car,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*Color dentroColor = Colors.red;
    if (status == 'dentro') {
      dentroColor = Colors.green;
    }*/
    car.heroId = 'card-${car.id}';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, 'details', arguments: car),
      child: Card(
        color: AppTheme.blurSecondary,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 10,
        shadowColor: AppTheme.primary,
        child: Column(children: [
          Hero(
            tag: car.heroId!,
            child: FadeInImage(
              image: NetworkImage(car.fullCarImage),
              placeholder: const AssetImage('assets/loading.gif'),
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            alignment: AlignmentDirectional.centerStart,
            padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
            child: Text(
              car.carName,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            alignment: AlignmentDirectional.centerStart,
            padding: const EdgeInsets.only(right: 30, top: 10, bottom: 10),
            child: Text(
              'Matricula: ${car.carPlate}',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Container(
            color: car.statusColor,
            alignment: AlignmentDirectional.centerEnd,
            padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
            child: Text(
              car.statusText,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ]),
      ),
    );
  }
}
