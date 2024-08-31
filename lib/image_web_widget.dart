import 'package:flutter/material.dart';

Widget platformImageWidget(String url) {
  return Image.network(
    url,
    width: 100,
    height: 100,
    fit: BoxFit.cover,
  );
}
