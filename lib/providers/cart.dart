import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/cart_item.dart';

class Cart with ChangeNotifier {
  Set<CartItem> _items = {};

  Set<CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    int itemcount = 0;
    if (_items.isNotEmpty) {
      _items.forEach((element) {
        itemcount += element.quantity;
      });
    }
    return itemcount;
  }

  int get numberOfProducts {
    if (_items.length != null) {
      return _items.length;
    } else {
      return 0;
    }
  }

  String getSpecialInstructions(String productId) {
    CartItem aux;
    if (_items.isNotEmpty) {
      aux = _items.firstWhere((element) => element.productInfo.id == productId,
          orElse: () => null);
    } else {
      return '';
    }

    if (aux != null) {
      return aux.specialInstructions;
    } else {
      return '';
    }
  }

  int getQuantity(String productId) {
    CartItem aux;
    if (_items.isNotEmpty) {
      aux = _items.firstWhere((element) => element.productInfo.id == productId,
          orElse: () => null);
    } else {
      return 0;
    }

    if (aux != null) {
      return aux.quantity;
    } else {
      return 0;
    }
  }

  void addItem(Product product, int productQuantity, String instructions) {
    final aux = CartItem(
      productInfo: product,
      quantity: productQuantity,
      specialInstructions: instructions,
    );
    bool alreadyOrdered = false;
    _items.forEach((element) {
      if (element.productInfo.id == product.id) {
        element.setQuantity(productQuantity);
        alreadyOrdered = true;
      }
    });
    if (!alreadyOrdered) _items.add(aux);
    notifyListeners();
  }

  void deleteItem(String productId) {
    _items.remove(
        _items.firstWhere((element) => element.productInfo.id == productId));
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    _items
        .firstWhere((element) => element.productInfo.id == productId)
        .increaseItemQuantity();
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    _items
        .firstWhere((element) => element.productInfo.id == productId)
        .decreaseItemQuantity();
    if (_items
            .firstWhere((element) => element.productInfo.id == productId)
            .quantity ==
        0) {
      deleteItem(productId);
    }
    notifyListeners();
  }

  double getTotalAmount() {
    double _totalAmount = 0;
    if (_items.isNotEmpty) {
      _items.forEach((element) {
        _totalAmount += element.cartItemValue();
      });
    }

    return _totalAmount;
  }

  double getReduction() {
    double _totalReduction = 0;
    if (_items.isNotEmpty) {
      _items.forEach((element) {
        _totalReduction += element.cartItemReduction();
      });
    }

    return _totalReduction;
  }

  double getCartItemValue(productId) {
    return _items
        .firstWhere((element) => element.productInfo.id == productId)
        .cartItemValue();
  }

  double getCartItemValueReduced(productId) {
    return _items
        .firstWhere((element) => element.productInfo.id == productId)
        .cartItemValueReduced();
  }

  void emptyCart() {
    _items.clear();
    notifyListeners();
  }

  void deleteItems(Iterable<CartItem> cartItems) {
    _items.removeAll(cartItems);
  }
}
