import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';

class ProfileImageFullScreen extends StatelessWidget {
  final String profileImageUrl;
  ProfileImageFullScreen(this.profileImageUrl);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: <Widget>[
            Center(
              child: CachedNetworkImage(
                imageUrl: profileImageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Icon(FontAwesomeIcons.times, color: Colors.white),
              ),
            ),
          ],
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

