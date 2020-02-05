import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/user_profile/profile.dart';
import 'package:hereme_flutter/utils/custom_image.dart';
import 'package:video_player/video_player.dart';

import 'home.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int pageIndex = 0;
  PageController pageController;

  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void changePage(int index) {
    setState(() {
      this.pageIndex = index;
    });
  }

  onTap(int index) {
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final double squareWidth = (screenWidth / 2.75);
    final double height = (screenWidth / 3.5) * 2 + 12;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => print('add'),
        child: Icon(FontAwesomeIcons.plus),
        backgroundColor: kColorRed,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BubbleBottomBar(
        hasNotch: true,
        fabLocation: BubbleBottomBarFabLocation.end,
        opacity: .2,
        currentIndex: pageIndex,
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                16)),
        elevation: 2,
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(
              backgroundColor: Colors.red,
              icon: Icon(
                FontAwesomeIcons.home,
                color: Colors.black,
              ),
              activeIcon: Icon(
                FontAwesomeIcons.home,
                color: Colors.red,
              ),
              title: Text("Home")),
          BubbleBottomBarItem(
              backgroundColor: Colors.deepPurple,
              icon: Icon(FontAwesomeIcons.play),
              activeIcon: Icon(FontAwesomeIcons.play),
              title: Text("Profile")),
        ],
      ),
      body: Container(
        width: screenWidth,
        height: height,
        child: PageView(
          children: <Widget>[Scaffold(
            appBar: AppBar(
              title: Text('Butterfly Video'),
            ),
            body: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ),
            Home(),
          ],
          controller: pageController,
          onPageChanged: changePage,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }
}
