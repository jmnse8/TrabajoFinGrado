

import 'package:flutter/material.dart';

class AddCarScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    //final productService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
      create: ( _ ) => ProductFormProvider( productService.selectedProduct ),
      child: _AddCarScreenBody(productService: productService),
    );
  }
}

class _AddCarScreenBody extends StatelessWidget {
  const _AddCarScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}