import 'package:find_wg/model/card.dart';
import 'package:find_wg/widgets/cardfeed_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MatchPage extends StatefulWidget {
  MatchPage({Key? key}) : super(key: key);

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  CardFeedProvider cardProvider = CardFeedProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CardFeedProvider>(builder: (_, cardProvider, __) {
        // print("called consumer build");
        return Center(
            child: Container(
          child: CardsFeed(cardProvider),
          constraints: BoxConstraints(maxWidth: 700),
        ));
      }),
    );
  }
}
