import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../providers/event_provider.dart';
import '../models/sport_event.dart';
import '../widgets/event_detail_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  int _activeYearIndex = 0;
  String? _selectedCategory;
  String? _selectedCountry;
  SportEvent? _selectedImpactEvent;
  bool? _isImpactPanelOpen;
  Map<int, int> _flatIndexToSidebarIndex = {};
  Map<String, int> _eventFlatIndex = {};
  Map<int, int> _yearFlatIndex = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
    _itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final mostVisible = positions.reduce((a, b) {
      final aVisible = a.itemTrailingEdge.clamp(0.0, 1.0) - a.itemLeadingEdge.clamp(0.0, 1.0);
      final bVisible = b.itemTrailingEdge.clamp(0.0, 1.0) - b.itemLeadingEdge.clamp(0.0, 1.0);
      return aVisible >= bVisible ? a : b;
    });
    final sidebarIndex = _flatIndexToSidebarIndex[mostVisible.index] ?? 0;
    if (sidebarIndex != _activeYearIndex) {
      setState(() {
        _activeYearIndex = sidebarIndex;
      });
    }
  }

  void _scrollToYear(int year) {
    final index = _yearFlatIndex[year];
    if (index != null) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToEvent(String eventId) {
    final index = _eventFlatIndex[eventId];
    if (index != null) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  List<SportEvent> _filterEvents(List<SportEvent> events) {
    return events.where((e) {
      if (_selectedCategory != null && e.category != _selectedCategory) return false;
      if (_selectedCountry != null && e.country != _selectedCountry) return false;
      return true;
    }).toList();
  }

  Map<int, List<SportEvent>> _groupByYear(List<SportEvent> events) {
    final Map<int, List<SportEvent>> result = {};
    for (final event in events) {
      result.putIfAbsent(event.year, () => []).add(event);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SelectableText(
          'Arab Sportswashing Timeline',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0B0E14),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 8,
        surfaceTintColor: const Color(0xFF2A3040),
        centerTitle: false,
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEAB308)),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load events',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Color(0xFF9CA3AF)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadEvents(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAB308),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final allEvents = provider.events;
          final filteredEvents = _filterEvents(allEvents);
          final eventsByYear = _groupByYear(filteredEvents);
          final sortedYears = eventsByYear.keys.toList()..sort();

          final List<Object> flatItems = [];
          _eventFlatIndex = {};
          _yearFlatIndex = {};
          _flatIndexToSidebarIndex = {};
          for (int yi = 0; yi < sortedYears.length; yi++) {
            final year = sortedYears[yi];
            _yearFlatIndex[year] = flatItems.length;
            _flatIndexToSidebarIndex[flatItems.length] = yi;
            flatItems.add(year);
            for (final event in eventsByYear[year]!) {
              _eventFlatIndex[event.id] = flatItems.length;
              _flatIndexToSidebarIndex[flatItems.length] = yi;
              flatItems.add(event);
            }
          }

          final categories = allEvents.map((e) => e.category).toSet().toList()..sort();
          final countries = allEvents.map((e) => e.country).toSet().toList()..sort();

          return Column(
            children: [
              // Filter bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFF0B0E14),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Filter:', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                      const SizedBox(width: 10),
                      // Category filters
                      ...categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(cat.toUpperCase(), style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? const Color(0xFF0B0E14) : const Color(0xFFD1D5DB),
                            )),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = isSelected ? null : cat;
                                _activeYearIndex = 0;
                              });
                            },
                            selectedColor: EventDetailCard.getCategoryColor(cat),
                            backgroundColor: const Color(0xFF171C26),
                            side: BorderSide(color: EventDetailCard.getCategoryColor(cat).withOpacity(0.5)),
                            showCheckmark: false,
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 24, color: const Color(0xFF2A3040)),
                      const SizedBox(width: 8),
                      // Country filters
                      ...countries.map((country) {
                        final isSelected = _selectedCountry == country;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(country, style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? const Color(0xFF0B0E14) : const Color(0xFFD1D5DB),
                            )),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedCountry = isSelected ? null : country;
                                _activeYearIndex = 0;
                              });
                            },
                            selectedColor: const Color(0xFFEAB308),
                            backgroundColor: const Color(0xFF171C26),
                            side: BorderSide(color: const Color(0xFFEAB308).withOpacity(0.3)),
                            showCheckmark: false,
                          ),
                        );
                      }),
                      // Clear all
                      if (_selectedCategory != null || _selectedCountry != null) ...[
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('Clear', style: TextStyle(fontSize: 12, color: Colors.white)),
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                              _selectedCountry = null;
                              _activeYearIndex = 0;
                            });
                          },
                          backgroundColor: Colors.red[900],
                          side: BorderSide.none,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Main content
              Expanded(
                child: Row(
                  children: [
                    // Left sidebar - year buttons
                    Container(
                      width: 80,
                      color: const Color(0xFF0B0E14),
                      child: sortedYears.isEmpty
                          ? const Center(child: Text('No\nevents', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)))
                          : ListView(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              children: sortedYears.asMap().entries.map((entry) {
                                final index = entry.key;
                                final year = entry.value;
                                final isActive = index == _activeYearIndex;

                                return Padding(
                                  // padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                   padding: const EdgeInsets.only(top: 4, bottom: 4, left: 12, right: 4),
                                  child: AnimatedScale(
                                    scale: isActive ? 1.15 : 1.0,
                                    duration: const Duration(milliseconds: 150),
                                    child: AnimatedOpacity(
                                      opacity: isActive ? 1.0 : 0.5,
                                      duration: const Duration(milliseconds: 150),
                                      child: Container(
                                        decoration: isActive
                                            ? BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFFEAB308).withOpacity(0.6),
                                                    blurRadius: 12,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              )
                                            : null,
                                        child: ElevatedButton(
                                          onPressed: () => _scrollToYear(year),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF171C26),
                                            foregroundColor: isActive ? const Color(0xFFEAB308) : Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              side: BorderSide(
                                                color: isActive ? const Color(0xFFEAB308) : const Color(0xFF2A3040),
                                                width: isActive ? 2 : 1,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            year.toString(),
                                            style: TextStyle(
                                              fontSize: isActive ? 14 : 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    // Main content - all events
                    Expanded(
                      child: sortedYears.isEmpty
                          ? const Center(child: Text('No events match the filter', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16)))
                          : ScrollablePositionedList.builder(
                              itemScrollController: _itemScrollController,
                              itemPositionsListener: _itemPositionsListener,
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 40),
                              itemCount: flatItems.length,
                              itemBuilder: (context, index) {
                                final item = flatItems[index];
                                if (item is int) {
                                  return Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 1200),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEAB308),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                item.toString(),
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0B0E14),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Container(
                                                height: 2,
                                                color: const Color(0xFF2A3040),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final event = item as SportEvent;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 1200),
                                      child: EventDetailCard.buildSingleEvent(
                                        event,
                                        onRelatedEventTap: (eventId) {
                                          setState(() {
                                            _selectedCategory = null;
                                            _selectedCountry = null;
                                          });
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            _scrollToEvent(eventId);
                                          });
                                        },
                                        onImpactTap: (tapEvent) {
                                          setState(() {
                                            if (_isImpactPanelOpen == true && _selectedImpactEvent?.id == tapEvent.id) {
                                              _isImpactPanelOpen = false;
                                              Future.delayed(const Duration(milliseconds: 300), () {
                                                if (mounted && _isImpactPanelOpen != true) {
                                                  setState(() {
                                                    _selectedImpactEvent = null;
                                                  });
                                                }
                                              });
                                            } else {
                                              _selectedImpactEvent = tapEvent;
                                              _isImpactPanelOpen = true;
                                            }
                                          });
                                        },
                                        isImpactSelected: _isImpactPanelOpen == true && _selectedImpactEvent?.id == event.id,
                                        allEvents: allEvents,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    // Right sidebar - Impact Analysis
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: _isImpactPanelOpen == true ? 400 : 0,
                      color: const Color(0xFF171C26),
                      child: _selectedImpactEvent != null
                          ? SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SelectableText(
                                    'Impact Analysis',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SelectableText(
                                    _selectedImpactEvent!.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEAB308),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: Colors.white24,
                                  ),
                                  const SizedBox(height: 12),
                                  SelectableText(
                                    _selectedImpactEvent!.impactAnalysis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.6,
                                      fontWeight: FontWeight.w300,
                                      color: Color(0xFFD1D5DB),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
