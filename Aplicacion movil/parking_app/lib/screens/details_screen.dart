import 'package:flutter/material.dart';
import 'package:parking_app/models/models.dart';
import 'package:parking_app/themes/app_theme.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Car car = ModalRoute.of(context)!.settings.arguments as Car;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _CustomAppBar(car: car),
          SliverList(
            delegate: SliverChildListDelegate([
              const Text('aaaaaaa'),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final Car car;

  const _CustomAppBar({Key? key, required this.car}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.primary,
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
          color: Colors.black12,
          child: Text(
            car.carName,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        background: Hero(
          tag: car.heroId!,
          child: FadeInImage(
            placeholder: const AssetImage('assets/loading.gif'),
            image: NetworkImage(car.fullCarImage),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
