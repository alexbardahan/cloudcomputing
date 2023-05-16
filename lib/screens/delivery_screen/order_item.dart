import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart.dart';
import '../../models/cart_item.dart';

class OrderItem extends StatefulWidget {
  final CartItem cartItem;
  OrderItem(this.cartItem);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  widget.cartItem.productInfo.title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              widget.cartItem.quantity > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  left: 5, top: 12, right: 10, bottom: 5),
                              child: GestureDetector(
                                  child: Icon(
                                    Icons.remove_circle,
                                    color: Theme.of(context).accentColor,
                                    size: 25,
                                  ),
                                  onTap: () {
                                    Provider.of<Cart>(context, listen: false)
                                        .decreaseQuantity(
                                            widget.cartItem.productInfo.id);
                                  }),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 12, bottom: 5),
                              child: Text(
                                '${widget.cartItem.quantity.toString()}',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: 10, top: 12, right: 10, bottom: 5),
                              child: GestureDetector(
                                child: Icon(
                                  Icons.add_circle,
                                  color: Theme.of(context).accentColor,
                                  size: 25,
                                ),
                                onTap: () {
                                  return Provider.of<Cart>(context,
                                          listen: false)
                                      .increaseQuantity(
                                          widget.cartItem.productInfo.id);
                                },
                              ),
                            ),
                          ],
                        ),
                        widget.cartItem.productInfo.reducedPrice !=
                                widget.cartItem.productInfo.price
                            ? Row(
                                children: [
                                  Container(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          right: 5, top: 12, bottom: 5),
                                      child: Text(
                                        cart
                                                .getCartItemValue(widget
                                                    .cartItem.productInfo.id)
                                                .toStringAsFixed(2) +
                                            " Lei",
                                        style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          right: 10, top: 12, bottom: 5),
                                      child: Text(
                                        cart
                                                .getCartItemValueReduced(widget
                                                    .cartItem.productInfo.id)
                                                .toStringAsFixed(2) +
                                            " Lei",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : Container(
                                child: Container(
                                  padding: EdgeInsets.only(
                                      right: 10, top: 12, bottom: 5),
                                  child: Text(
                                    cart
                                            .getCartItemValue(
                                                widget.cartItem.productInfo.id)
                                            .toStringAsFixed(2) +
                                        " Lei",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              )
                      ],
                    )
                  : null
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Divider(color: Colors.grey[500]),
          )
        ],
      ),
    );
  }
}
