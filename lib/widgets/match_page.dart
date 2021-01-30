import 'package:find_wg/model/card.dart';
import 'package:find_wg/widgets/cardfeed_widget.dart';
import 'package:find_wg/widgets/menu_bar.dart';
import 'package:flutter/material.dart';

class MatchPage extends StatefulWidget {
  MatchPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  CardFeedProvider cardProvider = CardFeedProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardsFeed(cardProvider),
    );
  }
}
