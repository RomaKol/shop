import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import '../screens/edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your product'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: this._refreshProducts(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => this._refreshProducts(context),
                child: Consumer<Products>(
                  builder: (ctx, productData, _) => Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) => Column(
                        children: <Widget>[
                          UserProductItem(
                            productData.items[index].id,
                            productData.items[index].title,
                            productData.items[index].imageUrl,
                          ),
                          Divider(),
                        ],
                      ),
                      itemCount: productData.items.length,
                    ),
                  ),
                ),
              ),
      ),
      drawer: AppDrawer(),
    );
  }
}
