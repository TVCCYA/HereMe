import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(mediaUrl) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(5),
    child: CachedNetworkImage(
      imageUrl: mediaUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Padding(
            child: Container(color: Colors.grey[200]),
            padding: EdgeInsets.all(0.0),
          ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    ),
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
