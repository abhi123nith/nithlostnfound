import 'dart:io';
import 'package:flutter/material.dart';

Widget platformImageWidget(File file) {
  return Image.file(
    file,
    width: 100,
    height: 100,
    fit: BoxFit.cover,
  );
}
