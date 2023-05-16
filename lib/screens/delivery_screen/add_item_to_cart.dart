import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/cart.dart';

import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import 'package:photo_view/photo_view.dart';

class AddItemToCart extends StatefulWidget {
  final Product item;
  AddItemToCart(this.item);

  @override
  _AddItemToCartState createState() => _AddItemToCartState();
}

final _formKey = GlobalKey<FormState>();

class _AddItemToCartState extends State<AddItemToCart> {
  var itemQuantity;
  String specialInstructions;

  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  FirebaseAnalytics analytics = FirebaseAnalytics();

  void _increaseQuantity() {
    setState(() => itemQuantity++);
  }

  void _decreaseQuantity() {
    setState(() => itemQuantity--);
  }

  Future<void> initAnalytics() async {
    await analytics.logEvent(
      name: 'view_product',
      parameters: {
        'itemId': widget.item.id,
        'itemName': widget.item.title,
        'itemCategory': widget.item.category,
        'currency': 'RON',
        'value': widget.item.price != widget.item.reducedPrice
            ? widget.item.reducedPrice
            : widget.item.price,
      },
    );
    print('log view_product');
  }

  @override
  void initState() {
    super.initState();
    itemQuantity =
        Provider.of<Cart>(context, listen: false).getQuantity(widget.item.id);
    specialInstructions = Provider.of<Cart>(context, listen: false)
        .getSpecialInstructions(widget.item.id);
    if (itemQuantity == 0) itemQuantity = 1;

    if (widget.item.video != null && widget.item.video != '') {
      initializePlayer();
    }

    initAnalytics();
  }

  @override
  void dispose() {
    if (widget.item.video != null && widget.item.video != '') {
      _videoPlayerController.dispose();
      _chewieController?.dispose();
    }
    super.dispose();
  }

  Future<void> initializePlayer() async {
    String dataSource = widget.item.video;
    _videoPlayerController = VideoPlayerController.network(dataSource);
    await Future.wait([_videoPlayerController.initialize()]);
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      showControls: true,
      showOptions: false,
      autoInitialize: true,
      allowMuting: true,
      showControlsOnInitialize: false,
      placeholder: Container(color: Colors.grey),
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
    );
    _chewieController.setVolume(0);
  }

  final appBar = AppBar(
    title: Text(''),
    elevation: 0,
    backgroundColor: Color.fromRGBO(128, 0, 128, 1),
    toolbarHeight: 45,
  );

  bool hasImage() {
    return (widget.item.imageBig != null && widget.item.imageBig != '');
  }

  bool hasVideo() {
    return (widget.item.video != null && widget.item.video != '');
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height;
    final double maxWidth = MediaQuery.of(context).size.width;
    final double appBarHeight = appBar.preferredSize.height;
    final double topBarHeight = MediaQuery.of(context).padding.top;
    final double usableHeight = maxHeight - appBarHeight - topBarHeight;

    final photoPercentage = 0.4;
    final double photoHeight = usableHeight * photoPercentage;
    final double buttonsHeight = 80;
    double aspectRatio = 16 / 9;

    return Scaffold(
      appBar: appBar,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Container(
            height: usableHeight,
            child: Stack(
              children: [
                Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        hasImage()
                            ? Container(
                                height: photoHeight,
                                width: double.infinity,
                                child: ClipRect(
                                  child: PhotoView(
                                    imageProvider:
                                        NetworkImage(widget.item.imageBig),
                                    maxScale:
                                        PhotoViewComputedScale.covered * 2.0,
                                    minScale:
                                        PhotoViewComputedScale.covered * 1,
                                    initialScale:
                                        PhotoViewComputedScale.covered,
                                  ),
                                ),
                              )
                            : Stack(
                                children: [
                                  Container(
                                    child: CustomPaint(
                                      size: Size(maxWidth,
                                          (maxWidth * 0.5).toDouble()),
                                      painter: RPSCustomPainter2(),
                                    ),
                                  ),
                                  Container(
                                    child: CustomPaint(
                                      size: Size(maxWidth,
                                          (maxWidth * 0.5).toDouble()),
                                      painter: RPSCustomPainter1(),
                                    ),
                                  ),
                                ],
                              ),
                        Container(
                          width: maxWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Container(
                                  margin: hasImage()
                                      ? EdgeInsets.only(
                                          top: 20, left: 20, right: 20)
                                      : EdgeInsets.only(
                                          top: 0, left: 20, right: 20),
                                  child: Text(
                                    widget.item.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              widget.item.price != widget.item.reducedPrice
                                  ? Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 5),
                                          child: Text(
                                            widget.item.price
                                                    .toStringAsFixed(2) +
                                                ' Lei',
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontSize: 17,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: Text(
                                            widget.item.reducedPrice
                                                    .toStringAsFixed(2) +
                                                ' Lei',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : Container(
                                      margin: EdgeInsets.only(top: 5),
                                      child: Text(
                                        widget.item.price.toStringAsFixed(2) +
                                            ' Lei',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                              widget.item.description != ''
                                  ? Container(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 6,
                                        bottom: 3,
                                      ),
                                      child: Text(
                                        widget.item.description,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              widget.item.allergens != ''
                                  ? Container(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 3,
                                      ),
                                      child: Text(
                                        'Alergeni: ' + widget.item.allergens,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              hasVideo()
                                  ? PresentationVideo(
                                      aspectRatio, _chewieController)
                                  : Container(),
                              Form(
                                key: _formKey,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: 20, right: 20, top: 15),
                                  child: SizedBox(
                                    height: 100,
                                    child: TextFormField(
                                      textInputAction: TextInputAction.done,
                                      maxLines: null,
                                      expands: true,
                                      textAlignVertical: TextAlignVertical.top,
                                      style: TextStyle(color: Colors.black87),
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        labelText: 'Instructiuni speciale',
                                        alignLabelWithHint: true,
                                        labelStyle:
                                            TextStyle(color: Colors.grey[400]),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 13,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      initialValue: specialInstructions,
                                      onChanged: (value) {
                                        specialInstructions = value;
                                      },
                                      onSaved: (value) {
                                        specialInstructions = value;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 120)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: usableHeight - buttonsHeight - 5,
                  child: Container(
                    height: buttonsHeight + 5,
                    width: maxWidth,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                left: 30,
                                right: 4.0,
                                bottom: 10,
                              ),
                              child: IconButton(
                                icon: itemQuantity > 1
                                    ? Icon(
                                        Icons.remove_circle_rounded,
                                        color: Theme.of(context).accentColor,
                                        size: 30,
                                      )
                                    : Icon(
                                        Icons.remove_circle_rounded,
                                        color: Colors.grey[300],
                                        size: 30,
                                      ),
                                onPressed:
                                    itemQuantity > 1 ? _decreaseQuantity : null,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                itemQuantity.toString(),
                                style: TextStyle(
                                  color: Colors.grey[850],
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(4.0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.add_circle_rounded,
                                  color: Theme.of(context).accentColor,
                                  size: 30,
                                ),
                                onPressed: _increaseQuantity,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () async {
                            Provider.of<Cart>(context, listen: false).addItem(
                              widget.item,
                              itemQuantity,
                              specialInstructions,
                            );

                            await analytics.logAddToCart(
                              itemId: widget.item.id,
                              itemName: widget.item.title,
                              itemCategory: widget.item.category,
                              currency: 'RON',
                              value:
                                  widget.item.price != widget.item.reducedPrice
                                      ? itemQuantity * widget.item.reducedPrice
                                      : itemQuantity * widget.item.price,
                              quantity: itemQuantity,
                            );
                            print('log add to card');

                            Navigator.of(context).pop();
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 25, bottom: 10),
                            width: 200,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'Adaugă în coș',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RPSCustomPainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0 = Paint()
      ..color = const Color.fromRGBO(128, 0, 128, 1)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    Path path0 = Path();
    path0.moveTo(0, 0);
    path0.lineTo(size.width, size.height);
    path0.lineTo(size.width, 0);
    path0.lineTo(0, 0);
    path0.close();

    canvas.drawPath(path0, paint0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class RPSCustomPainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0 = Paint()
      ..color = const Color.fromRGBO(255, 192, 78, 1)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    Path path0 = Path();
    path0.moveTo(0, 0);
    path0.lineTo(0, size.height * 0.8767000);
    path0.lineTo(size.width * 0.4987500, size.height * 0.4225000);
    path0.lineTo(0, 0);
    path0.close();

    canvas.drawPath(path0, paint0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PresentationVideo extends StatelessWidget {
  final double aspectRatio;
  final ChewieController _chewieController;
  const PresentationVideo(this.aspectRatio, this._chewieController);

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double margin = 15;
    double usableWidth = maxWidth - 2 * margin;

    return Stack(
      children: [
        Container(
          width: usableWidth,
          height: usableWidth / aspectRatio,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          margin: EdgeInsets.only(
              left: margin, right: margin, bottom: margin, top: 13),
          child: Center(
            child: _chewieController != null &&
                    _chewieController.videoPlayerController.value.isInitialized
                ? ClipRRect(
                    child: Chewie(controller: _chewieController),
                    borderRadius: BorderRadius.circular(10),
                  )
                : Container(
                    // color: Colors.red,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Colors.redAccent),
                        ),
                        SizedBox(height: 20),
                        Text('Loading'),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// Color.fromRGBO(128, 0, 128, 1)
// Color.fromRGBO(255, 192, 78, 1),