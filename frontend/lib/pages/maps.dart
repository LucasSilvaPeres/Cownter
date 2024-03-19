import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:latlong2/latlong.dart';

import '../constants/testGeoJson.dart';
import '../controllers/dashboard_controller.dart';
import 'package:cownter/maps/lib/flutter_map.dart';
import 'package:cownter/maps_geojson/lib/flutter_map_geojson.dart';

class AppMaps extends StatefulWidget {
  final VoidCallback? onTap;
  const AppMaps({super.key, this.onTap});

  @override
  State<AppMaps> createState() => _AppMapsState();
  void limpaMapa() {
    _AppMapsState().limpaMapa();
  }
}

class _AppMapsState extends State<AppMaps> {
  GeoJsonParser myGeoJson = GeoJsonParser(
      defaultMarkerColor: Colors.red,
      defaultPolygonBorderColor: Colors.red,
      defaultPolygonFillColor: Colors.red.withOpacity(0.1));

  // this is callback that gets executed when user taps the marker
  void onTapMarkerFunction(Map<String, dynamic> map) {
    // ignore: avoid_print
    print('onTapMarkerFunction: $map');
  }

  void limpaMapa() {
    print('zerar Mapa');
    //myGeoJson.markers.clear();
  }

  Future<void> processData() async {
    // parse a small test geoJson
    // normally one would use http to access geojson on web and this is
    // the reason why this funcyion is async.
    myGeoJson.parseGeoJsonAsString(testeGeoJson);
  }

  bool loadingData = false;

  @override
  void initState() {
    myGeoJson.setDefaultMarkerTapCallback(onTapMarkerFunction);

    loadingData = true;
    Stopwatch stopwatch2 = Stopwatch()..start();
    processData().then((_) {
      setState(() {
        loadingData = false;
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('GeoJson Processing time: ${stopwatch2.elapsed}'),
      //     duration: const Duration(milliseconds: 5000),
      //     behavior: SnackBarBehavior.floating,
      //     backgroundColor: Colors.green,
      //   ),
      // );
    });
    super.initState();
  }

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int i = 0; i < polygon.length - 1; i++) {
      LatLng p1 = polygon[i];
      LatLng p2 = polygon[i + 1];
      if (((p1.latitude > point.latitude) != (p2.latitude > point.latitude)) &&
          (point.longitude <
              (p2.longitude - p1.longitude) *
                      (point.latitude - p1.latitude) /
                      (p2.latitude - p1.latitude) +
                  p1.longitude)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  @override
  Widget build(BuildContext context) {
    DashboardController controller = GetIt.I.get<DashboardController>();

    // controller.requisitarDados(null);

    return SizedBox(
        width: double.infinity,
        height: 300,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FlutterMap(
              mapController: MapController(),
              options: MapOptions(
                onTap: (tapPosition, point) {
                  var lat = point.latitude;
                  var lon = point.longitude;
                  var abc = myGeoJson.polygons.where((element) {
                    return isPointInPolygon(point, element.points);
                  });
                  var jsondecode = jsonEncode(abc.first.properties);
                  var json = jsonDecode(jsondecode);
                  var nameJson = json['nome'];
                  var id = json['id'];
                  //  print(nameJson + ' --- ' + id);

                  controller.dadosFiltradosMapa(id);

                  // print(abc.first.properties);
                  myGeoJson.markers.clear();
                  //print(myGeoJson.polygons[0].label[0].toString());
                  myGeoJson.markers.add(Marker(
                      point: point,
                      builder: (context) => const Icon(
                            Icons.crisis_alert,
                            color: Colors.green,
                          )));
                },
                center: LatLng(-20.4677642, -49.067743),
                zoom: 16,
              ),
              children: [
                TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                    subdomains: const ['a', 'b', 'c']),
                //userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                loadingData
                    ? const Center(child: CircularProgressIndicator())
                    : PolygonLayer(
                        polygons: myGeoJson.polygons,
                      ),
                if (!loadingData)
                  PolylineLayer(
                    polylines: myGeoJson.polylines,
                  ),
                if (!loadingData) MarkerLayer(markers: myGeoJson.markers),
              ],
            ),
          ),
        ));
  }
}
