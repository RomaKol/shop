import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as oi;

class OrderItem extends StatefulWidget {
  final oi.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(
        milliseconds: 300,
      ),
      height: this._expanded
          ? min(widget.order.products.length * 20.0 + 110, 200)
          : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$${this.widget.order.amount}'),
              subtitle: Text(DateFormat('dd/MM/yyyy HH:mm')
                  .format(this.widget.order.dateTime)),
              trailing: IconButton(
                icon: Icon(
                    this._expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    this._expanded = !this._expanded;
                  });
                },
              ),
            ),
            // if (this._expanded)
            AnimatedContainer(
              duration: Duration(
                milliseconds: 300,
              ),
              height: this._expanded
                  ? min(widget.order.products.length * 20.0 + 10, 100)
                  : 0,
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.order.products[index].title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.order.products[index].quantity}x \$${widget.order.products[index].price}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                itemCount: widget.order.products.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
