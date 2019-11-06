import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';

class ProfileImageFullScreen extends StatelessWidget {
  final String profileImageUrl;
  ProfileImageFullScreen(this.profileImageUrl);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: FlatButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(FontAwesomeIcons.times, color: Colors.white,),
                  label: Text(''),
                ),
              ),
              Center(
                child: CachedNetworkImage(
                  imageUrl: profileImageUrl,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SizeRoute extends PageRouteBuilder {
  final Widget page;
  SizeRoute({this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        Align(
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        ),
  );
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        FadeTransition(
          opacity: animation,
          child: child,
        ),
  );
}

