import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
// import 'package:firebase_core/firebase_core.dart';

import './add_item_to_cart.dart';
import '../../providers/cart.dart';
import '../../models/product.dart';

class ProductItem extends StatefulWidget {
  final Product item;
  ProductItem(this.item);

  // static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  bool hasImage() {
    return (widget.item.imageSmall != null && widget.item.imageSmall != '');
  }

  bool needsBigBox() {
    return widget.item.bigElement == 'yes';
  }

  @override
  Widget build(BuildContext context) {
    var itemQuantity =
        Provider.of<Cart>(context, listen: false).getQuantity(widget.item.id);

    double width = MediaQuery.of(context).size.width;
    double usableWidth = width - 20;

    double photoPercentage = hasImage() ? 0.3 : 0;
    double contentPercentage = 1 - photoPercentage;
    double photoWidth = usableWidth * photoPercentage;
    double contentWidth = usableWidth * contentPercentage;

    double titlePercentage = 0.65;
    double pricePercentage = 1 - titlePercentage;
    double titleWidth = (contentWidth * titlePercentage) - 10;
    double priceWidth = (contentWidth * pricePercentage) - 10;

    double heightBig = 113;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddItemToCart(widget.item),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0.8,
        child: Container(
          height: needsBigBox() ? heightBig : 60,
          width: usableWidth,
          child: Row(
            children: [
              needsBigBox()
                  ? hasImage()
                      ? Container(
                          // color: Colors.red,
                          height: heightBig,
                          width: photoWidth,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              widget.item.imageSmall,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        )
                      : Container()
                  : Container(),
              needsBigBox()
                  ? hasImage()
                      ? Expanded(
                          child: Container(
                            // color: Colors.red,
                            width: contentWidth,
                            padding: EdgeInsets.only(
                                top: 10, left: 10, bottom: 10, right: 10),
                            // decoration: BoxDecoration(color: Colors.blue),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: titleWidth,
                                  // color: Colors.red,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          widget.item.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        child: Text(
                                          widget.item.description,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: priceWidth,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      widget.item.price !=
                                              widget.item.reducedPrice
                                          ? Column(
                                              children: [
                                                Text(
                                                  widget.item.price
                                                          .toStringAsFixed(2) +
                                                      ' Lei',
                                                  style: TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    color: Colors.grey[700],
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  widget.item.reducedPrice
                                                          .toStringAsFixed(2) +
                                                      ' Lei',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              widget.item.reducedPrice
                                                      .toStringAsFixed(2) +
                                                  ' Lei',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                      itemQuantity > 0
                                          ? IncreaseDecreaseButton(
                                              widget.item, itemQuantity)
                                          : AddToCartButton(widget.item),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: Container(
                            width: usableWidth,
                            padding: EdgeInsets.only(
                                top: 10, left: 35, bottom: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: titleWidth - 25,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          widget.item.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        child: Text(
                                          widget.item.description,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: priceWidth,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      widget.item.price !=
                                              widget.item.reducedPrice
                                          ? Column(
                                              children: [
                                                Text(
                                                  widget.item.price
                                                          .toStringAsFixed(2) +
                                                      ' Lei',
                                                  style: TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    color: Colors.grey[700],
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  widget.item.reducedPrice
                                                          .toStringAsFixed(2) +
                                                      ' Lei',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              widget.item.reducedPrice
                                                      .toStringAsFixed(2) +
                                                  ' Lei',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                      itemQuantity > 0
                                          ? IncreaseDecreaseButton(
                                              widget.item, itemQuantity)
                                          : AddToCartButton(widget.item),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                  : Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 10, left: 10, bottom: 10, right: 10),
                        // decoration: BoxDecoration(color: Colors.blue),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Text(
                                widget.item.title.length >= 17
                                    ? widget.item.title.characters
                                            .take(17)
                                            .string +
                                        '...'
                                    : widget.item.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  child: widget.item.price !=
                                          widget.item.reducedPrice
                                      ? Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 3.0),
                                              child: Text(
                                                widget.item.price
                                                        .toStringAsFixed(2) +
                                                    ' Lei',
                                                style: TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  color: Colors.grey[700],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              widget.item.reducedPrice
                                                      .toStringAsFixed(2) +
                                                  ' Lei',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          widget.item.reducedPrice
                                                  .toStringAsFixed(2) +
                                              ' Lei',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  height: 30,
                                  child: itemQuantity > 0
                                      ? IncreaseDecreaseButton(
                                          widget.item, itemQuantity)
                                      : AddToCartButton(widget.item),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class IncreaseDecreaseButton extends StatelessWidget {
  final Product product;
  final int itemQuantity;
  IncreaseDecreaseButton(this.product, this.itemQuantity);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.only(right: 5),
          child: GestureDetector(
            child: Icon(
              Icons.remove_circle_rounded,
              color: Theme.of(context).primaryColor,
              size: 25,
            ),
            onTap: () => Provider.of<Cart>(context, listen: false)
                .decreaseQuantity(product.id),
          ),
        ),
        Text(
          itemQuantity.toString(),
          style: TextStyle(
            color: Colors.grey[850],
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 5,
          ),
          child: GestureDetector(
            child: Icon(
              Icons.add_circle_rounded,
              color: Theme.of(context).primaryColor,
              size: 25,
            ),
            onTap: () => Provider.of<Cart>(context, listen: false)
                .increaseQuantity(product.id),
          ),
        ),
      ],
    );
  }
}

class AddToCartButton extends StatelessWidget {
  final Product product;
  AddToCartButton(this.product);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddItemToCart(product),
                ),
              );
            },
            child: Ink(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  'Adaugă',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
