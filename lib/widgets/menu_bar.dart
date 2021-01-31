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
      height: 64,
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFBBBBBB), width: 1),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(11),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkResponse(
                radius: 32 + 8,
                highlightShape: BoxShape.circle,
                splashColor: Colors.red.withOpacity(0.35),
                highlightColor: Colors.transparent,
                onTap: () => widget.onLike(),
                child: Image.asset(
                  "resources/img/like.png",
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 24),
              InkResponse(
                radius: 32 + 8,
                highlightShape: BoxShape.circle,
                splashColor: Colors.grey.withOpacity(0.35),
                highlightColor: Colors.transparent,
                onTap: () {},
                child: Icon(Icons.menu, color: Colors.black54),
              ),
              SizedBox(width: 24),
              InkResponse(
                radius: 32 + 8,
                highlightShape: BoxShape.circle,
                splashColor: Colors.red[700]!.withOpacity(0.35),
                highlightColor: Colors.transparent,
                onTap: () => widget.onDislike(),
                child: Image.asset(
                  "resources/img/dislike.png",
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
