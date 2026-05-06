import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/sport_event.dart';
import '../services/api_service.dart';

class EventDetailCard extends StatelessWidget {
  final List<SportEvent> events;
  final VoidCallback onClose;

  const EventDetailCard({
    Key? key,
    required this.events,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = events[index];
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: EventDetailCard._buildEventBlock(event),
          ),
        );
      },
    );
  }

  static Widget buildSingleEvent(SportEvent event) => _buildEventBlock(event);

  static Widget _buildEventBlock(SportEvent event) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171C26),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and category
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  event.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(event.category),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  event.category.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Date and country
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              SelectableText(
                event.date,
                style: const TextStyle(color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 16, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              SelectableText(
                event.country,
                style: const TextStyle(color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Image
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: '${ApiService.host}${event.imageUrl}',
                height: 400,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  height: 400,
                  color: const Color(0xFF0B0E14),
                  child: const Center(child: CircularProgressIndicator(color: Color(0xFFEAB308))),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 400,
                  color: const Color(0xFF0B0E14),
                  child: const Icon(Icons.image_not_supported, size: 50, color: Color(0xFF9CA3AF)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Description
          SelectableText(
            event.description,
            style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w300, color: Color(0xFFD1D5DB)),
          ),
          const SizedBox(height: 12),
          // Impact analysis
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white24,
          ),
          const SizedBox(height: 12),
          const SelectableText(
            'Impact Analysis',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            event.impactAnalysis,
            style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w300, color: Color(0xFFD1D5DB)),
          ),
        ],
      ),
    );
  }

  static Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'soccer':
        return Colors.green;
      case 'f1':
        return Colors.red;
      case 'ufc':
        return Colors.orange;
      case 'wrestling':
        return Colors.purple;
      case 'golf':
        return Colors.teal;
      case 'world_cup':
        return Colors.blue;
      case 'athletics':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }
}
