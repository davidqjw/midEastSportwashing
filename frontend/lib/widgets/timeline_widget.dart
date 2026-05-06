import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import '../models/sport_event.dart';

class TimelineWidget extends StatefulWidget {
  final Map<int, List<SportEvent>> eventsByYear;
  final Function(int) onYearTap;
  final int? selectedYear;

  const TimelineWidget({
    Key? key,
    required this.eventsByYear,
    required this.onYearTap,
    this.selectedYear,
  }) : super(key: key);

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  int? _hoveredYear;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate all years from 2008 to 2026
    final allYears = List.generate(19, (index) => 2008 + index);

    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          try {
            if (_scrollController.hasClients) {
              final currentOffset = _scrollController.offset;
              final maxOffset = _scrollController.position.maxScrollExtent;
              
              if (maxOffset > 0) {
                final delta = pointerSignal.scrollDelta.dy;
                final newOffset = (currentOffset + delta).clamp(0.0, maxOffset);
                
                _scrollController.jumpTo(newOffset);
              }
            }
          } catch (e) {
            // Ignore scroll errors
          }
        }
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F3A).withOpacity(0.7),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.grey[700]!.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Timeline line
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 35,
                    child: Container(
                      height: 3,
                      color: Colors.grey[700],
                    ),
                  ),
                  // Year nodes
                  ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: allYears.length,
                    itemBuilder: (context, index) {
                      final year = allYears[index];
                      final hasEvents = widget.eventsByYear.containsKey(year);
                      final isSelected = year == widget.selectedYear;
                      final isHovered = year == _hoveredYear;

                      return MouseRegion(
                        onEnter: (_) {
                          if (hasEvents) {
                            setState(() {
                              _hoveredYear = year;
                            });
                          }
                        },
                        onExit: (_) {
                          setState(() {
                            _hoveredYear = null;
                          });
                        },
                        cursor: hasEvents ? SystemMouseCursors.click : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: hasEvents ? () => widget.onYearTap(year) : null,
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Center(
                              child: Transform.rotate(
                                angle: -0.785398, // -45 degrees in radians
                                child: Container(
                                  width: 60,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue[600]
                                        : isHovered
                                            ? Colors.blue[400]
                                            : hasEvents
                                                ? Colors.grey[700]
                                                : Colors.grey[850],
                                    borderRadius: BorderRadius.circular(18), // Oval shape
                                    border: Border.all(
                                      color: isSelected 
                                          ? Colors.blue[400]! 
                                          : hasEvents 
                                              ? Colors.grey[600]! 
                                              : Colors.grey[800]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      year.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected || isHovered
                                            ? Colors.white
                                            : hasEvents
                                                ? Colors.grey[300]
                                                : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
