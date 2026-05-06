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
            child: _buildEventBlock(event),
          ),
        );
      },
    );
  }

  Widget _buildEventBlock(SportEvent event) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
                    fontSize: 12,
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
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              SelectableText(
                event.date,
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              SelectableText(
                event.country,
                style: TextStyle(color: Colors.grey[400]),
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
                  color: Colors.grey[800],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 400,
                  color: Colors.grey[800],
                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Description
          SelectableText(
            event.description,
            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[300]),
          ),
          const SizedBox(height: 12),
          // Impact analysis
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[900]?.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[800]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  'Impact Analysis',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blue[300],
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  event.impactAnalysis,
                  style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey[300]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
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
      default:
        return Colors.grey;
    }
  }
}
