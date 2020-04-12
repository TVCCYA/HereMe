import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants.dart';

Widget cachedNetworkImage(String imageUrl) {
  return imageUrl != null
      ? CachedNetworkImage(
          imageUrl: imageUrl,
          errorWidget: (context, url, error) =>
              Icon(FontAwesomeIcons.userAlt, color: kColorLightGray),
        )
      : Icon(FontAwesomeIcons.exclamationCircle, color: kColorRed);
}

Widget cachedUserResultImage(String imageUrl, double size, bool hasBorder) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    imageBuilder: (context, imageProvider) => Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 2),
        border: hasBorder ? Border.all(
          width: 1,
          color: kColorOffWhite,
        ) : Border.all(width: 0.0, color: Colors.transparent),
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
//                colorFilter: ColorFilter.mode(
//                    kColorBlack71.withOpacity(0.05), BlendMode.multiply),
        ),
      ),
    ),
//    placeholder: (context, url) => circularProgress(),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}

Widget cachedRoundedCornerImage(String imageUrl, double size) {
  return Card(
    clipBehavior: Clip.hardEdge,
    elevation: 2.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    child: CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
//      placeholder: (context, url) => circularProgress(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    ),
  );
}
