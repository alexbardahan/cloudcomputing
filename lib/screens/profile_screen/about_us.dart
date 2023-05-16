import 'package:cafe_noir/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class AboutUs extends StatelessWidget {
  static const routeName = 'about-us';
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<LoadSettings>(context, listen: false).settings;
    return Scaffold(
      appBar: AppBar(
        title: Text('Despre noi'),
        elevation: 0,
        backgroundColor: Color.fromRGBO(128, 0, 128, 1),
        toolbarHeight: 45,
      ),
      body: Container(
        child: SingleChildScrollView(
            child: Column(
          children: [
            // Image.asset(
            //   'assets/slideshow_photos/noir1.jpg',
            //   fit: BoxFit.cover,
            // ),
            Container(
              width: double.infinity,
              height: 250,
              child: ClipRect(
                child: PhotoView(
                  imageProvider:
                      AssetImage('assets/slideshow_photos/noir1.jpg'),
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                  minScale: PhotoViewComputedScale.covered * 1,
                  initialScale: PhotoViewComputedScale.covered,
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 20, bottom: 10),
            //   child: Text('Povestea Cafe Noir',
            //       style: TextStyle(
            //         fontSize: 20,
            //         fontStyle: FontStyle.italic,
            //         color: Theme.of(context).primaryColor,
            //       )),
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 20, right: 20),
            //   child: Text(
            //       "    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            //       style: TextStyle(
            //         color: Colors.grey,
            //       )),
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Text('Telefon',
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
            Container(
              child: Text(settings.phone, style: TextStyle(fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Text('Program',
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                  ),
                  child:
                      Text(settings.program1, style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                  ),
                  child:
                      Text(settings.program2, style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                  ),
                  child:
                      Text(settings.program3, style: TextStyle(fontSize: 16)),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Text('Locație',
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('Calea Călărașilor nr. 30, Brăila',
                      style: TextStyle(fontSize: 16)),
                ),
                Image.asset(
                  'assets/others/locatie-cafe-noir.png',
                  fit: BoxFit.cover,
                ),
              ],
            )
          ],
        )),
      ),
    );
  }
}
