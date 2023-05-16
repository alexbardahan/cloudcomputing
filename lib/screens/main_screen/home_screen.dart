import 'dart:async';

import 'package:cafe_noir/providers/advert.dart';
import 'package:cafe_noir/providers/event.dart';
import 'package:cafe_noir/providers/settings.dart';
import 'package:cafe_noir/screens/main_screen/event_screen.dart';
import 'package:cafe_noir/screens/main_screen/menu_screen.dart';
import 'package:cafe_noir/services/pdf_api.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'offers_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/auth.dart';
import 'dart:io' show Platform;

// video player
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

// notificari (start)
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// notificari (end)

class HomeScreen extends StatefulWidget {
  final Function _selectPage;
  HomeScreen(this._selectPage);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String token;
  int currentPhoto = 0;
  bool volume = false;
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    // notificari (start)
    const AndroidInitializationSettings initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    var initializationSettings = InitializationSettings(
      android: initialzationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      final data = message.data;
      print('am ajuns aici in onMessage');
      if (!Platform.isIOS) {
        if (notification != null || data != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            data['title'],
            data['body'],
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                color: Color.fromRGBO(128, 0, 128, 1),
                icon: android?.smallIcon,
                priority: Priority.high,
              ),
              iOS: IOSNotificationDetails(),
            ),
          );
        }
      }
    });
    // notificari (end)

    getToken(); // token pentru notificari (fiecare user are un token unic)
    initializePlayer(); // initializam videoclipul
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController =
        VideoPlayerController.asset("assets/videos/2021.mp4");
    await Future.wait([_videoPlayerController.initialize()]);
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    // final subtitles = [
    //     Subtitle(
    //       index: 0,
    //       start: Duration.zero,
    //       end: const Duration(seconds: 10),
    //       text: 'Hello from subtitles',
    //     ),
    //     Subtitle(
    //       index: 0,
    //       start: const Duration(seconds: 10),
    //       end: const Duration(seconds: 20),
    //       text: 'Whats up? :)',
    //     ),
    //   ];

    // final subtitles = [
    //   Subtitle(
    //     index: 0,
    //     start: Duration.zero,
    //     end: const Duration(seconds: 10),
    //     text: const TextSpan(children: [
    //       TextSpan(
    //         text: 'Hello',
    //         style: TextStyle(color: Colors.red, fontSize: 22),
    //       ),
    //       TextSpan(
    //         text: ' from ',
    //         style: TextStyle(color: Colors.green, fontSize: 20),
    //       ),
    //       TextSpan(
    //         text: 'subtitles',
    //         style: TextStyle(color: Colors.blue, fontSize: 18),
    //       )
    //     ]),
    //   ),
    //   Subtitle(
    //       index: 0,
    //       start: const Duration(seconds: 10),
    //       end: const Duration(seconds: 20),
    //       text: 'Whats up? :)'
    //       // text: const TextSpan(
    //       //   text: 'Whats up? :)',
    //       //   style: TextStyle(color: Colors.amber, fontSize: 22, fontStyle: FontStyle.italic),
    //       // ),
    //       ),
    // ];

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      showControls: true,
      showOptions: false,

      autoInitialize: true,
      allowMuting: true,
      showControlsOnInitialize: false,

      // subtitle: Subtitles(subtitles),
      // subtitleBuilder: (context, dynamic subtitle) => Container(
      //   padding: const EdgeInsets.all(10.0),
      //   child: subtitle is InlineSpan
      //       ? RichText(text: subtitle)
      //       : Text(subtitle.toString(), style: const TextStyle(color: Colors.black),
      // ),

      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),

      placeholder: Container(color: Colors.grey),
    );
    _chewieController.setVolume(0);
  }

  bool changeVolume() {
    setState(() {
      volume = !volume;
    });
    return volume;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double aspectRatio = 16 / 9;
    final settings = Provider.of<LoadSettings>(context, listen: false).settings;

    return SingleChildScrollView(
      child: Container(
        // color: Colors.red,
        width: deviceWidth,
        child: Column(
          children: [
            // video de prezentare
            PresentationVideo(
                aspectRatio, volume, changeVolume, _chewieController),

            // oferte
            AdvertWidget(deviceWidth),

            // view pdf
            MenuPdfWidget(deviceWidth),

            Container(
              width: deviceWidth,
              child: Column(
                children: [
                  GoToWidget(
                      widget._selectPage,
                      1,
                      'Comandă mâncarea ta preferată!',
                      'Fie că vrei să o livrăm noi sau să o ridici tu alege ce îți place direct din aplicația Cafe Noir!',
                      Color.fromRGBO(255, 201, 102, 1),
                      Color.fromRGBO(255, 184, 51, 1),
                      Icons.fastfood,
                      deviceWidth),
                  GoToWidget(
                      widget._selectPage,
                      2,
                      'Rezervă-ți masa acum!',
                      'Nu a fost niciodată atât de simplu să îți rezervi o masă direct din aplicație în mai puțin de un minut.',
                      Color.fromRGBO(153, 0, 153, 1),
                      Color.fromRGBO(102, 0, 102, 1),
                      Icons.schedule,
                      deviceWidth),
                ],
              ),
            ),

            // evenimente
            EventWidget(deviceWidth),
          ],
        ),
      ),
    );
  }

  void getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    setState(() {
      token = token;
    });

    final userId = Provider.of<Auth>(context, listen: false).getUser().uid;
    final String idToken =
        await Provider.of<Auth>(context, listen: false).refreshGetToken();
    final url = Uri.parse(
        'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/usersDetails/$userId.json?auth=$idToken');

    await http.patch(
      url,
      body: json.encode({
        'fcm_token': token,
        'device_os': Platform.isAndroid ? 'android' : 'ios',
      }),
    );
  }
}

class PresentationVideo extends StatelessWidget {
  final double aspectRatio;
  final bool volume;
  final Function changeVolume;
  final ChewieController _chewieController;

  PresentationVideo(
      this.aspectRatio, this.volume, this.changeVolume, this._chewieController);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / aspectRatio,
          margin: const EdgeInsets.only(bottom: 15),
          child: Center(
            child: _chewieController != null &&
                    _chewieController.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      const CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Colors.redAccent),
                      ),
                      const SizedBox(height: 20),
                      const Text('Loading'),
                    ],
                  ),
          ),
        ),
        Platform.isIOS
            ? Container()
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      bool volume = changeVolume();
                      _chewieController.setVolume(volume ? 1 : 0);
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 15, right: 15),
                      child: Icon(
                        volume
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: Colors.grey,
                        size: 24,
                        semanticLabel: 'Mute / Unmute',
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}

class MenuPdfWidget extends StatelessWidget {
  final double deviceWidth;

  MenuPdfWidget(this.deviceWidth);

  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    final double height = 150;

    return GestureDetector(
      onTap: () async {
        await analytics.logEvent(
          name: 'viewMenuPdf',
          parameters: {},
        );
        print('log event view menu pdf');

        final path = 'assets/menu_pdf/menu_compressed.pdf';
        final file = await PDFApi.loadAsset(path);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerPage(file: file),
          ),
        );
      },
      child: Container(
        height: height,
        width: deviceWidth,
        margin: const EdgeInsets.only(bottom: 15),
        child: Stack(
          children: [
            Container(
              width: deviceWidth,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/menu_pdf/poza_meniu.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdvertWidget extends StatelessWidget {
  final double deviceWidth;
  AdvertWidget(this.deviceWidth);

  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    final advert = Provider.of<LoadAdvert>(context, listen: false).advert;
    final double height = deviceWidth * 9 / 16;

    return GestureDetector(
      onTap: () async {
        await analytics.logEvent(
          name: 'viewPromotion',
          parameters: {},
        );
        print('log event promotion');
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => OffersScreen(advert)));
      },
      child: Container(
        height: height,
        width: deviceWidth,
        margin: const EdgeInsets.only(bottom: 15),
        child: Stack(
          children: [
            Container(
              width: deviceWidth,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  advert.photo,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: Colors.black.withOpacity(0.5),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 2, left: 10, right: 0, bottom: 5),
                  margin: const EdgeInsets.only(left: 12, bottom: 0, right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        advert.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        advert.header,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GoToWidget extends StatelessWidget {
  final Function selectPage;
  final int pageNumber;
  final String title;
  final String text;
  final Color color1;
  final Color color2;
  final IconData iconData;
  final double deviceWidth;

  GoToWidget(this.selectPage, this.pageNumber, this.title, this.text,
      this.color1, this.color2, this.iconData, this.deviceWidth);

  @override
  Widget build(BuildContext context) {
    final double marginBox = 10;
    final double paddingBox = 20;
    final double usableWidthBox = deviceWidth - 2 * marginBox;
    final double usableWidthInside = usableWidthBox - 2 * paddingBox;

    return Container(
      margin: EdgeInsets.only(
        left: marginBox,
        right: marginBox,
        bottom: 15,
      ),
      width: usableWidthBox,
      height: 125,
      child: GestureDetector(
        onTap: () {
          selectPage(pageNumber);
        },
        child: Container(
          width: usableWidthBox,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            // gradient: LinearGradient(colors: [color2, color1]),
            // color: pageNumber == 1
            //     ? Theme.of(context).accentColor
            //     : Theme.of(context).primaryColor,
            color: pageNumber == 1 ? color2 : Theme.of(context).primaryColor,
          ),
          padding: EdgeInsets.symmetric(horizontal: paddingBox, vertical: 15),
          child: Row(
            children: <Widget>[
              Container(
                width: usableWidthInside * 0.15,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Container(
                    child: Center(
                      child: Icon(
                        iconData,
                        color: pageNumber == 1
                            ? Theme.of(context).accentColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: usableWidthInside * 0.85,
                padding: const EdgeInsets.only(left: 20),
                // color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventWidget extends StatelessWidget {
  final double deviceWidth;
  EventWidget(this.deviceWidth);

  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    final event = Provider.of<LoadEvent>(context, listen: false).event;
    final double height = deviceWidth * 9 / 16;

    bool hasTitleAndHeader() {
      return (event.title != null && event.title != '') &&
          (event.header != null && event.header != '');
    }

    return GestureDetector(
      onTap: () async {
        await analytics.logEvent(
          name: 'viewEvent',
          parameters: {},
        );
        print('log event event');
        if (hasTitleAndHeader()) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => EventScreen(event)));
        }
      },
      child: Container(
        height: height,
        width: deviceWidth,
        margin: const EdgeInsets.only(bottom: 15),
        child: Stack(
          children: [
            Container(
              width: deviceWidth,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  event.photo,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            hasTitleAndHeader()
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            top: 2, left: 10, right: 0, bottom: 5),
                        margin: const EdgeInsets.only(
                            left: 12, bottom: 0, right: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              event.header,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

// slide show
// Container(
//   width: deviceWidth,
//   margin: EdgeInsets.symmetric(horizontal: 10),
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.all(Radius.circular(10)),
//   ),
//   child: Column(
//     children: [
//       Container(
//         height: deviceWidth * 9 / 18,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(10),
//             bottomRight: Radius.circular(10),
//           ),
//           // color: Theme.of(context).primaryColor,
//         ),
//         child: ImageSlideshow(
//           initialPage: 0,
//           indicatorColor: Theme.of(context).primaryColor,
//           indicatorBackgroundColor: Colors.grey,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(10),
//                 topRight: Radius.circular(10),
//               ),
//               child: Image.asset(
//                 'assets/slideshow_photos/noir1.jpg',
//                 fit: BoxFit.cover,
//               ),
//             ),
//             ClipRRect(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(10),
//                 topRight: Radius.circular(10),
//               ),
//               child: Image.asset(
//                 'assets/slideshow_photos/noir2.jpg',
//                 fit: BoxFit.cover,
//               ),
//             ),
//             ClipRRect(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(10),
//                 topRight: Radius.circular(10),
//               ),
//               child: Image.asset(
//                 'assets/slideshow_photos/noir3.jpg',
//                 fit: BoxFit.cover,
//               ),
//             ),
//             ClipRRect(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(10),
//                 topRight: Radius.circular(10),
//               ),
//               child: Image.asset(
//                 'assets/slideshow_photos/noir4.jpg',
//                 fit: BoxFit.cover,
//               ),
//             )
//           ],
//           onPageChanged: (value) {
//             setState(() {
//               currentPhoto = value;
//             });
//           },
//           autoPlayInterval: 3000,
//         ),
//       ),
//       Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(10),
//             bottomRight: Radius.circular(10),
//           ),
//           color: Theme.of(context).primaryColor,
//         ),
//         padding: EdgeInsets.symmetric(vertical: 5),
//         child: Stack(
//           children: [
//             AnimatedOpacity(
//               opacity: currentPhoto == 0 || currentPhoto == 1
//                   ? 1.0
//                   : 0.0,
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.decelerate,
//               child: Center(
//                 child: Text(
//                   'Days with us',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//             AnimatedOpacity(
//               opacity: currentPhoto == 2 || currentPhoto == 3
//                   ? 1.0
//                   : 0.0,
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.decelerate,
//               child: Center(
//                 child: Text(
//                   'Nights with us',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ],
//   ),
// ),
