import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sport_event.dart';

class ApiService {
  static const String host = 'http://localhost:8000';
  static const String baseUrl = '$host/api';

  Future<List<SportEvent>> getEvents({
    String? category,
    String? country,
    int? startYear,
    int? endYear,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (country != null) queryParams['country'] = country;
    if (startYear != null) queryParams['start_year'] = startYear.toString();
    if (endYear != null) queryParams['end_year'] = endYear.toString();

    final uri = Uri.parse('$baseUrl/events').replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SportEvent.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<SportEvent> getEventById(String id) async {
    final uri = Uri.parse('$baseUrl/events/$id');
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return SportEvent.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Event not found');
      } else {
        throw Exception('Failed to load event: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<String>> getCategories() async {
    final uri = Uri.parse('$baseUrl/categories');
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['categories']);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<String>> getCountries() async {
    final uri = Uri.parse('$baseUrl/countries');
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['countries']);
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
