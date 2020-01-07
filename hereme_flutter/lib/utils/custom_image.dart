import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants.dart';

Widget cachedNetworkImage(String imageUrl) {
  return imageUrl != null ? CachedNetworkImage(
    imageUrl: imageUrl,
    errorWidget: (context, url, error) => Icon(FontAwesomeIcons.userAlt, color: kColorLightGray),
  ) : Icon(FontAwesomeIcons.exclamationCircle, color: kColorRed);
}

Widget cachedUserResultImage(imageUrl, double radius) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
    child: imageUrl != null ? CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Padding(
            child: Container(color: kColorExtraLightGray),
            padding: EdgeInsets.all(0.0),
          ),
      errorWidget: (context, url, error) => Icon(FontAwesomeIcons.userAlt, color: kColorLightGray,),
    ) : Icon(FontAwesomeIcons.exclamationCircle, color: kColorRed),
  );
}

Widget noImagePlaceholder() {
  return Container(
    color: Colors.black,
    decoration: BoxDecoration(
        border: Border.all(
      color: Colors.red, //                   <--- border color
      width: 5.0,
    ),
    ),
  );
}
