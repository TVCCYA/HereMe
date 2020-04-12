import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/constants.dart';

class ReusableProfileCard extends StatelessWidget {
  ReusableProfileCard({this.imageUrl, this.cardSize, this.onTap});

  final String imageUrl;
  final double cardSize;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: kColorExtraLightGray),
        ),
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                height: cardSize,
                width: cardSize,
                fit: BoxFit.cover,
              )
            : Container(
                height: cardSize,
                width: cardSize,
                color: kColorExtraLightGray,
              ),
      ),
    );
  }
}

class ReusableCard extends StatelessWidget {
  ReusableCard({this.imageFile, this.onTap});

  final File imageFile;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: InkResponse(
        onTap: onTap,
        child: imageFile != null
            ? Image.file(
                imageFile,
                fit: BoxFit.contain,
              )
            : Icon(
                FontAwesomeIcons.exclamationTriangle,
                color: kColorRed,
              ),
      ),
    );
  }
}


class CircleCard extends StatelessWidget {
  CircleCard({this.imageFile, this.size, this.onTap});

  final File imageFile;
  final double size;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size / 2),
      ),
      elevation: 4.0,
      child: InkResponse(
        onTap: onTap,
        child: imageFile != null
            ? Image.file(
          imageFile,
          height: size,
          width: size,
          fit: BoxFit.cover,
        )
            : Icon(
          FontAwesomeIcons.exclamationTriangle,
          color: kColorRed,
        ),
      ),
    );
  }
}