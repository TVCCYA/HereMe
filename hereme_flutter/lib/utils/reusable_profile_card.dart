import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hereme_flutter/contants/constants.dart';

class ReusableProfileCard extends StatelessWidget {
  ReusableProfileCard({this.imageUrl, this.cardSize, this.onTap});

  final String imageUrl;
  final double cardSize;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: InkResponse(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: (cardSize / 2) - 12,
                  width: (cardSize / 2) - 12,
                  fit: BoxFit.cover,
                )
              : ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
              height: (cardSize / 2) - 12,
              width: (cardSize / 2) - 12,
              color: Colors.grey[200],
            ),
          )
        ),
      ),
    );
  }
}

class ReusableCard extends StatelessWidget {
  ReusableCard({this.imageFile, this.cardSize, this.onTap});

  final File imageFile;
  final double cardSize;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: InkResponse(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            height: (cardSize / 2) - 12,
            width: (cardSize / 2) - 12,
            child: imageFile != null
                ? Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                  )
                : Icon(
                    FontAwesomeIcons.exclamationTriangle,
                    color: kColorRed,
                  ),
          ),
        ),
      ),
    );
  }
}
