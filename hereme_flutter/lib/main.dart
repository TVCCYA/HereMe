import 'package:flutter/material.dart';

import 'home/bottom_bar.dart';

void main() {
  runApp(
    MaterialApp(
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
        home: BottomBar(),
    ),
  );
}
