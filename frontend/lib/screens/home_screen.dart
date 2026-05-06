import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/event_detail_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const SelectableText(
            'Arab Sportswashing Timeline',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        backgroundColor: const Color(0xFF0A0E27),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
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
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadEvents(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final eventsByYear = provider.getEventsByYear();

          return Stack(
            children: [
              // Main content area (event blocks)
              _selectedYear != null && eventsByYear[_selectedYear] != null
                  ? EventDetailCard(
                      events: eventsByYear[_selectedYear]!,
                      onClose: () {
                        setState(() {
                          _selectedYear = null;
                        });
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.0,
                          colors: [
                            const Color(0xFF0F1429),
                            const Color(0xFF0A0E27),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timeline,
                              size: 80,
                              color: Colors.grey[800],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select a year from the timeline below',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              // Timeline at bottom (floating on top)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: TimelineWidget(
                  eventsByYear: eventsByYear,
                  onYearTap: (year) {
                    setState(() {
                      _selectedYear = year;
                    });
                  },
                  selectedYear: _selectedYear,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
