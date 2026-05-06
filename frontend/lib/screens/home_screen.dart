import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../providers/event_provider.dart';
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
    if (mostVisible.index != _activeYearIndex) {
      setState(() {
        _activeYearIndex = mostVisible.index;
      });
    }
  }

  void _scrollToYear(int year, List<int> sortedYears) {
    final index = sortedYears.indexOf(year);
    if (index != -1) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
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

          final eventsByYear = provider.getEventsByYear();
          final sortedYears = eventsByYear.keys.toList()..sort();

          return Row(
            children: [
              // Left sidebar - year buttons
              Container(
                width: 80,
                color: const Color(0xFF0B0E14),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: sortedYears.asMap().entries.map((entry) {
                    final index = entry.key;
                    final year = entry.value;
                    final isActive = index == _activeYearIndex;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                              onPressed: () => _scrollToYear(year, sortedYears),
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
                child: ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 40),
                  itemCount: sortedYears.length,
                  itemBuilder: (context, index) {
                    final year = sortedYears[index];
                    final events = eventsByYear[year]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Year title
                        Center(
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
                                      year.toString(),
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
                        ),
                        // Event cards for this year
                        ...events.map((event) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1200),
                              child: EventDetailCard.buildSingleEvent(event),
                            ),
                          ),
                        )),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
