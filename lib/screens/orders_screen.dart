import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((response) async {
      setState(() {
        this._isLoading = true;
      });
      await Provider.of<Orders>(context, listen: false).fetchSetOrders();
      setState(() {
        this._isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders!'),
      ),
      body: this._isLoading
          ? CircularProgressIndicator()
          : ListView.builder(
              itemBuilder: (BuildContext context, int index) =>
                  OrderItem(orderData.orders[index]),
              itemCount: orderData.orders.length,
            ),
      drawer: AppDrawer(),
    );
  }
}
