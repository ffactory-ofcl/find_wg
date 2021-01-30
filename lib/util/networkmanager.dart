import 'dart:math';
import 'dart:typed_data';
import 'package:find_wg/model/card.dart';
import 'package:http/http.dart' as http;

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._();
  NetworkManager._();

  factory NetworkManager.getInstance() {
    return _instance;
  }

  final _devRandom = Random();
  final _devTitles = [
    "Nette Garconniere mit Blick ins Grüne",
    "Zwei Zimmer Wohnung, hell",
    "STUDENTENHIT: Zentrale Wohnung in Uni-Nähe",
    "Perfekt für Pärchen - 50m2 in Graz-Eggenberg",
  ];
  final _devDesc = [
    "Nette Garconniere mit Blick ins Grüne",
    "Zwei Zimmer Wohnung, hell",
    "STUDENTENHIT: Zentrale Wohnung in Uni-Nähe",
    "Perfekt für Pärchen - 50m2 in Graz-Eggenberg",
  ];

  Card loadCard() {
    return Card(_devTitles[_devRandom.nextInt(_devTitles.length)],
        _devDesc[_devRandom.nextInt(_devDesc.length)],
        images: [
          "https://source.unsplash.com/collection/1540143/600x400?auto=format&fit=crop&w=400&q=80&sig=" +
              _devRandom.nextInt(10000).toString(),
          "https://source.unsplash.com/collection/1540143/600x400?auto=format&fit=crop&w=400&q=80&sig=" +
              _devRandom.nextInt(10000).toString()
        ]);
  }

  void saveReaction(Reaction reaction, Card card) {
    // TODO:
    return;
  }

  Future<Uint8List> loadImage(String url) {
    return http.get(Uri.parse(url)).then((response) => response.bodyBytes);
  }
}
