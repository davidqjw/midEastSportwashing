import 'package:flutter/foundation.dart';
import '../models/sport_event.dart';
import '../services/api_service.dart';

class EventProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<SportEvent> _events = [];
  List<SportEvent> get events => _events;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  String? _selectedCategory;
  String? _selectedCountry;
  int? _startYear;
  int? _endYear;

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _apiService.getEvents(
        category: _selectedCategory,
        country: _selectedCountry,
        startYear: _startYear,
        endYear: _endYear,
      );
      
      // Sort by date
      _events.sort((a, b) => a.date.compareTo(b.date));
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void applyFilter({
    String? category,
    String? country,
    int? startYear,
    int? endYear,
  }) {
    _selectedCategory = category;
    _selectedCountry = country;
    _startYear = startYear;
    _endYear = endYear;
    loadEvents();
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedCountry = null;
    _startYear = null;
    _endYear = null;
    loadEvents();
  }

  Map<int, List<SportEvent>> getEventsByYear() {
    final Map<int, List<SportEvent>> eventsByYear = {};
    
    for (var event in _events) {
      final year = event.year;
      if (!eventsByYear.containsKey(year)) {
        eventsByYear[year] = [];
      }
      eventsByYear[year]!.add(event);
    }
    
    return eventsByYear;
  }
}
