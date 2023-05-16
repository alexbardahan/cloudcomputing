import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerPage extends StatefulWidget {
  final File file;

  const PDFViewerPage({
    Key key,
    this.file,
  }) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  PDFViewController controller;
  int pages = 0;
  int indexPage = 0;

  @override
  Widget build(BuildContext context) {
    final name = 'Meniu';
    // final text = '${indexPage + 1} din $pages';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text(name),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 5),
            child: IconButton(
              icon: Icon(Icons.arrow_upward_rounded, size: 30),
              onPressed: () {
                controller.setPage(0);
              },
            ),
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            PDFView(
              filePath: widget.file.path,
              autoSpacing: true,
              nightMode: false,
              pageSnap: false,
              pageFling: false,
              enableSwipe: true,
              onRender: (pages) => setState(() => this.pages = pages),
              onViewCreated: (controller) =>
                  setState(() => this.controller = controller),
              onPageChanged: (indexPage, _) =>
                  setState(() => this.indexPage = indexPage),
            ),
            // Container(
            //   width: MediaQuery.of(context).size.width,
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Container(
            //         width: MediaQuery.of(context).size.width * 0.65 + 20,
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.end,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             // Container(
            //             //   width: MediaQuery.of(context).size.width * 0.5,
            //             //   margin: EdgeInsets.symmetric(vertical: 40),
            //             //   color: Colors.white,
            //             //   height: 50,
            //             //   child: Row(
            //             //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //             //     children: [
            //             //       IconButton(
            //             //         icon: Icon(Icons.chevron_left, size: 32),
            //             //         onPressed: () {
            //             //           final page =
            //             //               indexPage == 0 ? pages : indexPage - 1;
            //             //           controller.setPage(page);
            //             //         },
            //             //       ),
            //             //       Center(child: Text(text)),
            //             //       InkWell(
            //             //         onTap: () {
            //             //           final page = indexPage == pages - 1
            //             //               ? 0
            //             //               : indexPage + 1;
            //             //           controller.setPage(page);
            //             //         },
            //             //         child: Container(
            //             //           padding: EdgeInsets.all(10),
            //             //           child: Icon(Icons.chevron_right, size: 32),
            //             //         ),
            //             //       ),
            //             //     ],
            //             //   ),
            //             // ),
            //             // SizedBox(width: 20, height: 50),
            //             Container(
            //               width: MediaQuery.of(context).size.width * 0.15,
            //               margin: EdgeInsets.symmetric(vertical: 40),
            //               color: Colors.white,
            //               height: 50,
            //               child: IconButton(
            //                 icon: Icon(Icons.arrow_upward_outlined, size: 32),
            //                 onPressed: () {
            //                   controller.setPage(0);
            //                 },
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
