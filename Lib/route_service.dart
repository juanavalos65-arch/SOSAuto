import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong2.dart';

class RouteService {
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://project-osrm.org'
      '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];
        return coordinates.map((point) => LatLng(point[1], point[0])).toList();
      }
    } catch (e) {
      print("Error: $e");
    }
    return [];
  }
}
