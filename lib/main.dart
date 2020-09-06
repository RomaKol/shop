import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => Products(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => Orders(),
        ),
      ],
      child: MaterialApp(
        title: 'My shop',
        theme: ThemeData(
          primarySwatch: Colors.green,
          accentColor: Colors.redAccent,
          fontFamily: 'Lato',
          primaryTextTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        home: ProductsOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName: (BuildContext context) =>
              ProductDetailScreen(),
          CartScreen.routeName: (BuildContext context) => CartScreen(),
          OrdersScreen.routeName: (BuildContext context) => OrdersScreen(),
          UserProductsScreen.routeName: (BuildContext context) =>
              UserProductsScreen(),
        },
      ),
    );
  }
}
