import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  Product _editedProduct = new Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  Map<String, Object> _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(this._updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (this._isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        this._editedProduct =
            Provider.of<Products>(context).findById(productId);
        this._initValues = {
          'title': this._editedProduct.title,
          'description': this._editedProduct.description,
          'price': this._editedProduct.price.toString(),
          // 'imageUrl': this._editedProduct.imageUrl,
          'imageUrl': '',
        };
        this._imageUrlController.text = this._editedProduct.imageUrl;
      }
    }
    this._isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(this._updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = this._form.currentState.validate();
    if (!isValid) {
      return;
    }
    this._form.currentState.save();
    setState(() {
      this._isLoading = true;
    });
    if (this._editedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(this._editedProduct.id, this._editedProduct);
      setState(() {
        this._isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      Provider.of<Products>(context, listen: false)
          .addProduct(this._editedProduct)
          .catchError((error) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error!'),
            content: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }).then((response) {
        setState(() {
          this._isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: this._saveForm,
          ),
        ],
      ),
      body: this._isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: this._form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: this._initValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        this._editedProduct = Product(
                          title: value,
                          price: this._editedProduct.price,
                          description: this._editedProduct.description,
                          imageUrl: this._editedProduct.imageUrl,
                          id: this._editedProduct.id,
                          isFavorite: this._editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: this._initValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a price!';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number!';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than zero!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        this._editedProduct = Product(
                          title: this._editedProduct.title,
                          price: double.parse(value),
                          description: this._editedProduct.description,
                          imageUrl: this._editedProduct.imageUrl,
                          id: this._editedProduct.id,
                          isFavorite: this._editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: this._initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Description!';
                        }
                        if (value.length < 10) {
                          return 'Should be at least 10 characters long!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        this._editedProduct = Product(
                          title: this._editedProduct.title,
                          price: this._editedProduct.price,
                          description: value,
                          imageUrl: this._editedProduct.imageUrl,
                          id: this._editedProduct.id,
                          isFavorite: this._editedProduct.isFavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (value) {
                              this._saveForm();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter n image URL!';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL!';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please enter a valid image URL!';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              this._editedProduct = Product(
                                title: this._editedProduct.title,
                                price: this._editedProduct.price,
                                description: this._editedProduct.description,
                                imageUrl: value,
                                id: this._editedProduct.id,
                                isFavorite: this._editedProduct.isFavorite,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
