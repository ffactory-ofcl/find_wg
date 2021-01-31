import 'dart:math';
import 'dart:typed_data';
import 'package:find_wg/model/card.dart';
import 'package:find_wg/util/unsplash_adapter.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'extensions.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._();
  NetworkManager._();
  static NetworkManager get instance => _instance;

  UnsplashAdapter unsplashAdapter = UnsplashAdapter.instance;

  final _devRandom = Random();
  final _devTitles = [
    "Nette Garconniere mit Blick ins Grüne",
    "Zwei Zimmer Wohnung, hell",
    "STUDENTENHIT: Zentrale Wohnung in Uni-Nähe",
    "Perfekt für Pärchen - 50m2 in Graz-Eggenberg",
  ];
  final _devDesc = [
    "In Graz gelangen nagelneue Erstbezugswohnungen zur Vermietung. Die Wohnungen sind AB SOFORT verfügbar!",
    "Die 2-Zimmerwohnung hat ca. 59m² Wohnfläche und besteht aus: 1 Vorraum, 1 Wohnraum, 1 Küche ...",
    """Exklusiv zur Vermietung gelangt diese modern sanierte Immobilie in zentraler Lage mit folgenden Highlights:

    - Provisionsfrei!
    - Großer Balkon
    - Idealer Grundriss für Familien und WGs
    - Sehr hell
    - Moderne Laminatböden
    - Hochwertige Küche
    """
        .stripMargin(),
    "Description4",
  ];

  Card loadCard(VoidCallback notifyListeners) {
    return Card(_devTitles[_devRandom.nextInt(_devTitles.length)],
        _devDesc[_devRandom.nextInt(_devDesc.length)],
        notifyListeners: notifyListeners,
        images: ([
              unsplashAdapter.randomImageUrl
            ]) + // Add one to three random images
            (_devRandom.nextBool() ? [unsplashAdapter.randomImageUrl] : []) +
            (_devRandom.nextBool() ? [unsplashAdapter.randomImageUrl] : []));
  }

  void saveReaction(Reaction reaction, Card card) {
    // TODO:
    return;
  }

  Future<Uint8List?> loadImage(String url) {
    return unsplashAdapter
        .loadImage(url)
        .catchError((_) => null)
        .timeout(Duration(seconds: 4), onTimeout: () => null);
  }
}
