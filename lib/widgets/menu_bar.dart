import 'package:flutter/material.dart' hide Card;

import 'package:find_wg/model/card.dart';

class FloatingMenuBar extends StatefulWidget {
  final CardFeedProvider cardProvider;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const FloatingMenuBar(
    this.cardProvider, {
    Key? key,
    required this.onLike,
    required this.onDislike,
  }) : super(key: key);

  @override
  _FloatingMenuBarState createState() => _FloatingMenuBarState();
}

class _FloatingMenuBarState extends State<FloatingMenuBar>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton.icon(
            onPressed: () => widget.onLike(),
            icon: Icon(Icons.add_circle, color: Colors.red[800]),
            label: Text(''),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.menu, color: Colors.black54),
            label: Text(''),
          ),
          TextButton.icon(
            onPressed: () => widget.onDislike(),
            icon: Icon(Icons.remove_circle, color: Colors.blue),
            label: Text(''),
          ),
        ],
      ),
    );
  }
}
