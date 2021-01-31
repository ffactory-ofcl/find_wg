import 'package:find_wg/model/card.dart';
import 'package:flutter/material.dart';

import 'package:find_wg/widgets/match_page.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarBrightness: Brightness.dark));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roomride',
      theme: ThemeData(
        // primarySwatch: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider<CardFeedProvider>(
        create: (_) => CardFeedProvider(),
        lazy: false,
        child: MatchPage(),
      ),
    );
  }
}
