import 'package:cafe_noir/models/product.dart';
import 'package:cafe_noir/providers/menuData.dart';
import 'package:cafe_noir/providers/settings.dart';
import 'package:cafe_noir/screens/profile_screen/my_orders.dart';
import 'package:cafe_noir/screens/delivery_screen/choose_order_type.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'address_order_details.dart';
import 'delivery_category_item.dart';
import 'delivery_item.dart';
import '../../providers/cart.dart';
import '../../providers/auth.dart';
import 'pickup_order_details.dart';
import 'restaurant_order_details.dart';

import 'package:toggle_switch/toggle_switch.dart';

class DeliveryScreen extends StatefulWidget {
  final Function _selectPage;
  DeliveryScreen(this._selectPage);

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final List<Map<String, dynamic>> categoriesList = [
    // best
    {
      'name': 'Best',
      'subCategories': ['Best'],
      'icon': 'assets/icons/best.png',
      'index': 0,
    },

    // mancare
    {
      'name': 'Breakfast',
      'subCategories': ['Breakfast', 'Sandwiches'],
      'icon': 'assets/icons/breakfast.png',
      'index': 1,
    },
    {
      'name': 'Starters',
      'subCategories': ['Starters'],
      'icon': 'assets/icons/starters.png',
      'index': 2,
    },
    {
      'name': 'Cream Soups',
      'subCategories': ['Cream Soups'],
      'icon': 'assets/icons/soups.png',
      'index': 3,
    },
    {
      'name': 'Meat',
      'subCategories': ['Chicken', 'Pork', 'Beef', 'Lamb'],
      'icon': 'assets/icons/meat.png',
      'index': 4,
    },
    {
      'name': 'Burgers',
      'subCategories': ['Burgers'],
      'icon': 'assets/icons/burgers.png',
      'index': 5,
    },
    {
      'name': 'Pizza',
      'subCategories': ['Pizza'],
      'icon': 'assets/icons/pizza.png',
      'index': 6,
    },
    {
      'name': 'Pasta',
      'subCategories': ['Pasta'],
      'icon': 'assets/icons/pasta.png',
      'index': 7,
    },
    {
      'name': 'Seafood & Fish',
      'subCategories': ['Seafood', 'Fish'],
      'icon': 'assets/icons/seafood.png',
      'index': 8,
    },
    {
      'name': 'Salads',
      'subCategories': ['Salads'],
      'icon': 'assets/icons/salads.png',
      'index': 9,
    },
    {
      'name': 'Sides & Souces',
      'subCategories': ['Sides', 'Salads', 'Souces'],
      'icon': 'assets/icons/sides.png',
      'index': 10,
    },
    {
      'name': 'Dessert',
      'subCategories': ['Dessert'],
      'icon': 'assets/icons/dessert.png',
      'index': 11,
    },

    // bautura
    {
      'name': 'Juices',
      'subCategories': ['Fresh', 'Răcoritoare', 'Energizant'],
      'icon': 'assets/icons/juices.png',
      'index': 12,
    },
    // {
    //   'name': 'Lemonade',
    //   'subCategories': ['Lemonade'],
    //   'icon': 'assets/icons/lemonades.png',
    //   'index': 13,
    // },
    // {
    //   'name': 'Coffee & Tea',
    //   'subCategories': [
    //     'Coffee',
    //     'Coffee drinks',
    //     'Hot chocolate',
    //     'Hot&IcedTea',
    //     'Frappe',
    //     'Milkshake'
    //   ],
    //   'icon': 'assets/icons/coffee.png',
    //   'index': 14,
    // },
    // {
    //   'name': 'Alcoholic drinks',
    //   'subCategories': [
    //     'Cocktails',
    //     'Non Alcoholoc Cocktails',
    //     'Long drinks',
    //     'Shots',
    //     'Digestiv',
    //     'Aperitif',
    //     'Rom',
    //     'Liqour',
    //     'Gin',
    //     'Spritz',
    //     'Whisky',
    //     'Cognac',
    //     'Vodka'
    //   ],
    //   'icon': 'assets/icons/alcoholic.png',
    //   'index': 15,
    // },
    // {
    //   'name': 'Wine',
    //   'subCategories': [
    //     'Crama Rasova',
    //     'Domeniul Regas',
    //     'Domeniul Urlati',
    //     'Domeniul Dealul Mare',
    //     'Castelul Huniade',
    //     'Beciul Domnesc',
    //     'Crama Cricova',
    //     'Purcari',
    //     'Crama Budurească',
    //     'Domeniul Coroanei Segarcea',
    //     'Cramele B&G',
    //     'Domeniul Sâmburești',
    //     'Domeniul Jidvei',
    //     'Tohani',
    //     'Vinuri de măcin',
    //     'Spumant',
    //     'Șampanie'
    //   ],
    //   'icon': 'assets/icons/wine.png',
    //   'index': 16
    // },
  ];

  final itemControllerVertical = ItemScrollController();
  final itemListenerVertical = ItemPositionsListener.create();

  final itemControllerHorizontal = ItemScrollController();
  final itemListenerHorizontal = ItemPositionsListener.create();

  void _scrollToItemVertical(int index) {
    setState(() {
      itemControllerVertical.jumpTo(
        index: index,
      );
    });
  }

  void _scrollToItemHorizontal(int index) {
    // 0 1 2 la fel
    // >= 3 muta

    if (index >= 3) {
      index -= 2;
    } else if (index == 2) {
      index -= 1;
    } else if (index == 1) {
      index -= 1;
    }

    setState(() {
      itemControllerHorizontal.jumpTo(
        index: index,
      );
    });
  }

  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();

    itemListenerVertical.itemPositions.addListener(() {
      final indices = itemListenerVertical.itemPositions.value
          // .where((element) {
          //   final isTopVisible = element.itemLeadingEdge >= 0;
          //   final isBottomVisible = element.itemTrailingEdge <= 1;
          //   return isTopVisible || isBottomVisible;
          // })
          .map((e) => e.index)
          .toList();
      indices.sort((e1, e2) => e1.compareTo(e2));
      if (indices[0] != _selectedCategory) {
        _selectCategoryItem(indices[0]);
      }
    });

    _orderType = 'Livrare la adresa';
  }

  void _selectCategoryItem(int selectedCategory) {
    setState(() {
      _selectedCategory = selectedCategory;
      _scrollToItemHorizontal(_selectedCategory);
    });
  }

  Future<void> _showOrderDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text('Comanda ta a fost plasata cu succes!',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600)),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  child: Lottie.asset('assets/lottie/lottie_succes.json',
                      repeat: false),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Doresti sa vezi detaliile comenzii?',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                //imagine emoji sad
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text('Inapoi',
                        style: TextStyle(color: Colors.black, fontSize: 15)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Vezi detalii comanda',
                        style: TextStyle(color: Colors.black, fontSize: 15)),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(MyOrders.routeName)
                          .then((_) => Navigator.of(context).pop());
                    },
                  ),
                ],
              ),
            ),
          ],
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      },
    );
  }

  Future<void> _showClosedRestaurantDialog(
      BuildContext context, int openingHour, int closingHour, bool open) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              open
                  ? 'Ne pare rau, dar am inchis!'
                  : 'Ne pare rău, dar restaurantul s-a închis!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                      'assets/lottie/lottie_restaurant_closed.json'),
                ),
                if (open)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Program restaurant: $openingHour - $closingHour',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Text('Inapoi',
                    style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      },
    );
  }

  Future<String> _showChangedOrderTypeDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'Atentie!',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  child: Lottie.asset(
                    'assets/lottie/lottie_restaurant_only.json',
                    repeat: true,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Unul dintre produsele alese poate fi servit exclusiv in restaurant. Schimband modalitatea de servire, acesta va fi automat sters din cos.',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text(
                      'Inapoi',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop('cancel');
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Continua',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop('continue');
                    },
                  ),
                ],
              ),
            ),
          ],
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  String _orderType;

  void _setOrderType(String newValue) {
    (Provider.of<Cart>(context, listen: false)
                .items
                .any((element) => element.productInfo.delivery == 'no') &&
            newValue != 'Comanda la masa')
        ? _showChangedOrderTypeDialog(context).then((value) {
            if (value == 'cancel') {
              return;
            } else {
              final delete = Provider.of<Cart>(context, listen: false)
                  .items
                  .where((element) => element.productInfo.delivery == 'no');
              Provider.of<Cart>(context, listen: false).deleteItems(delete);
              setState(() {
                _orderType = newValue;
              });
            }
          })
        : setState(() {
            _orderType = newValue;
          });
  }

  bool _closedRestaurant(int openingHour, int closingHour, bool open) {
    if (!open) return true;
    final currTime = DateTime.now();
    final openingTime =
        DateTime(currTime.year, currTime.month, currTime.day, openingHour);
    final closingTime =
        DateTime(currTime.year, currTime.month, currTime.day, closingHour);
    return !(currTime.isAfter(openingTime) && currTime.isBefore(closingTime));
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final user = Provider.of<Auth>(context, listen: false).getUser();
    final settings = Provider.of<LoadSettings>(context, listen: false).settings;

    final int openingHour = settings.openingHour;
    final int closingHour = settings.closingHour;
    final bool open = settings.open;

    return _orderType == null
        ? ChooseOrderType(_setOrderType)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 16,
                  right: 10,
                ),
                height: Theme.of(context).platform == TargetPlatform.android
                    ? 45 + MediaQuery.of(context).padding.top
                    : 89,
                width: double.infinity,
                color: Theme.of(context).primaryColor,
                child: new Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.black87,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 13),
                              child: Text(
                                _orderType == 'Livrare la adresa'
                                    ? 'Livrare la adresă'
                                    : 'Ridicare personală',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 19),
                              ),
                            ),
                            ToggleSwitch(
                              minWidth: 40,
                              initialLabelIndex:
                                  _orderType == 'Livrare la adresa' ? 0 : 1,
                              cornerRadius: 20,
                              radiusStyle: true,
                              activeFgColor: Colors.white,
                              inactiveBgColor: Colors.grey[100],
                              inactiveFgColor: Colors.white,
                              totalSwitches: 2,
                              customIcons: [
                                Icon(
                                  Icons.delivery_dining_outlined,
                                  size: 20,
                                ),
                                Icon(
                                  Icons.pin_drop_outlined,
                                  size: 20,
                                )
                              ],
                              activeBgColors: [
                                [Theme.of(context).accentColor],
                                [Theme.of(context).accentColor]
                              ],
                              onToggle: (index) {
                                // print('switched to: $index');

                                _setOrderType(index == 0
                                    ? 'Livrare la adresa'
                                    : 'Ridicare personala');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10, top: 5, bottom: 0),
                child: Row(
                  children: [
                    Text(
                      'Hi, ',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 24,
                        color: Colors.black54,
                      ),
                    ),
                    Consumer<Auth>(
                      builder: (ctx, userData, _) => Text(
                        user.displayName == '' || user.displayName == null
                            ? ''
                            : user.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 24,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10, top: 0, bottom: 3),
                child: Text(
                  'What would you like to eat?',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 17.5,
                    color: Colors.grey,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                height: 90,
                width: double.infinity,
                child: ScrollablePositionedList.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoriesList.length,
                  itemBuilder: (context, index) {
                    final category = categoriesList.firstWhere(
                        (element) => element['index'] as int == index);

                    return CategoryItem(
                      category['name'],
                      category['icon'],
                      _selectCategoryItem,
                      _selectedCategory,
                      index,
                      _scrollToItemVertical,
                    );
                  },
                  itemScrollController: itemControllerHorizontal,
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 5, right: 5, top: 3),
                  child: Stack(
                    children: [
                      ScrollablePositionedList.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: categoriesList.length,
                        itemBuilder: (context, index) {
                          List<String> subCategories =
                              categoriesList.firstWhere((element) =>
                                  element['index'] ==
                                  index)['subCategories'] as List<String>;

                          return Column(
                            children: [
                              ...subCategories
                                  .map((e) => Subcategory(e, _orderType))
                                  .toList(),
                              SizedBox(height: 20),
                            ],
                          );
                        },
                        itemScrollController: itemControllerVertical,
                        itemPositionsListener: itemListenerVertical,
                      ),
                      cart.itemCount == 0
                          ? Container() //sterge asta
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(),
                                Center(
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (_closedRestaurant(
                                          openingHour, closingHour, open)) {
                                        _showClosedRestaurantDialog(context,
                                            openingHour, closingHour, open);
                                      } else {
                                        if (_orderType == 'Livrare la adresa') {
                                          await Navigator.of(context)
                                              .pushNamed(
                                                  AddressOrderDetails.routeName)
                                              .then((value) {
                                            if (value == 'ordered') {
                                              setState(() {
                                                cart.emptyCart();
                                                _showOrderDialog(context);
                                              });
                                            }
                                          });
                                        } else if (_orderType ==
                                            'Ridicare personala') {
                                          await Navigator.of(context)
                                              .pushNamed(
                                                  PickupOrderDetails.routeName)
                                              .then((value) {
                                            if (value == 'ordered') {
                                              setState(() {
                                                cart.emptyCart();
                                                _showOrderDialog(context);
                                              });
                                            }
                                          });
                                        } else {
                                          if (_orderType ==
                                              'Livrare la adresa') {
                                            await Navigator.of(context)
                                                .pushNamed(AddressOrderDetails
                                                    .routeName)
                                                .then((value) {
                                              if (value == 'ordered') {
                                                setState(() {
                                                  cart.emptyCart();
                                                  _showOrderDialog(context);
                                                });
                                              }
                                            });
                                          } else if (_orderType ==
                                              'Ridicare personala') {
                                            await Navigator.of(context)
                                                .pushNamed(PickupOrderDetails
                                                    .routeName)
                                                .then((value) {
                                              if (value == 'ordered') {
                                                setState(() {
                                                  cart.emptyCart();
                                                  _showOrderDialog(context);
                                                });
                                              }
                                            });
                                          } else {
                                            await Navigator.of(context)
                                                .pushNamed(
                                                    RestaurantOrderDetails
                                                        .routeName)
                                                .then((value) {
                                              if (value == 'ordered') {
                                                setState(() {
                                                  cart.emptyCart();
                                                  _showOrderDialog(context);
                                                });
                                              }
                                            });
                                          }
                                        }
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 20,
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 13),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: _closedRestaurant(
                                                openingHour, closingHour, open)
                                            ? Colors.grey[300]
                                            : Theme.of(context).accentColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Comandă ${cart.itemCount} pentru ${(cart.getTotalAmount() - cart.getReduction()).toStringAsFixed(2)} lei',
                                          style: TextStyle(
                                            color: _closedRestaurant(
                                                    openingHour,
                                                    closingHour,
                                                    open)
                                                ? Colors.grey[500]
                                                : Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}

class Subcategory extends StatefulWidget {
  final String subCategory;
  final String orderType;

  Subcategory(this.subCategory, this.orderType);

  @override
  _SubcategoryState createState() => _SubcategoryState();
}

class _SubcategoryState extends State<Subcategory> {
  @override
  Widget build(BuildContext context) {
    List<Product> products =
        Provider.of<MenuData>(context, listen: false).items;

    if (widget.subCategory == 'Best') {
      products = products
          .where((element) =>
              element.best == 'yes' &&
              element.status == 'available' &&
              (widget.orderType == 'Comanda la masa' ||
                  (element.delivery == 'yes')))
          .toList();
    } else {
      products = products
          .where((element) =>
              element.subCategory == widget.subCategory &&
              element.status == 'available' &&
              (widget.orderType == 'Comanda la masa' ||
                  (element.delivery == 'yes')))
          .toList();
    }

    List<ProductItem> productsWithPhotos = [];
    List<ProductItem> productsWithoutPhotos = [];
    products.map((e) => ProductItem(e)).toList().forEach((element) {
      if (element.item.imageSmall == null || element.item.imageSmall == '') {
        productsWithoutPhotos.add(element);
      } else {
        productsWithPhotos.add(element);
      }
    });

    productsWithoutPhotos.sort((a, b) {
      if (b.item.bigElement == 'yes') {
        return 1;
      }
      return -1;
    });

    return products.length == 0
        ? Container()
        : Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 5, top: 5),
                  child: Text(
                    widget.subCategory,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                    ),
                  ),
                ),
                ...productsWithPhotos,
                ...productsWithoutPhotos,
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          );
  }
}
