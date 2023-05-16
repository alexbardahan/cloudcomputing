import 'package:flutter/material.dart';

import './product.dart';

class CartItem {
  Product productInfo;
  int quantity;
  String specialInstructions;

  CartItem(
      {@required this.productInfo,
      @required this.quantity,
      this.specialInstructions});

  void setQuantity(int value) {
    quantity = value;
  }

  void increaseItemQuantity() {
    quantity++;
  }

  void decreaseItemQuantity() {
    quantity--;
  }

  double cartItemValue() {
    if (quantity != null) {
      return quantity * productInfo.price;
    } else {
      return 0;
    }
  }

  double cartItemValueReduced() {
    if (quantity != null) {
      return quantity * productInfo.reducedPrice;
    } else {
      return 0;
    }
  }

  double cartItemReduction() {
    if (quantity != null) {
      return quantity * (productInfo.price - productInfo.reducedPrice);
    } else {
      return 0;
    }
  }
}
