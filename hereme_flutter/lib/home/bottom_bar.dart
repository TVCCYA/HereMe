import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';
import 'package:hereme_flutter/user_profile/profile.dart';
import 'package:hereme_flutter/utils/custom_image.dart';

import 'home.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int pageIndex = 0;
  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
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
                16)), //border radius doesn't work when the notch is enabled.
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
              icon: cachedUserResultImage(currentUser.profileImageUrl, 5, 30),
              activeIcon:
                  cachedUserResultImage(currentUser.profileImageUrl, 5, 30),
              title: Text("Profile")),
        ],
      ),
      body: PageView(
        children: <Widget>[
          Home(),
          Profile(user: currentUser, locationLabel: currentUser.city ?? 'Here'),
        ],
        controller: pageController,
        onPageChanged: changePage,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }
}
