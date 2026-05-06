class SportEvent {
  final String id;
  final String title;
  final String date;
  final String category;
  final String country;
  final String description;
  final String impactAnalysis;
  final String imageUrl;
  final List<String> relatedEvents;

  SportEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.country,
    required this.description,
    required this.impactAnalysis,
    required this.imageUrl,
    required this.relatedEvents,
  });

  factory SportEvent.fromJson(Map<String, dynamic> json) {
    return SportEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      category: json['category'] as String,
      country: json['country'] as String,
      description: json['description'] as String,
      impactAnalysis: json['impact_analysis'] as String,
      imageUrl: json['image_url'] as String,
      relatedEvents: List<String>.from(json['related_events'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'category': category,
      'country': country,
      'description': description,
      'impact_analysis': impactAnalysis,
      'image_url': imageUrl,
      'related_events': relatedEvents,
    };
  }

  int get year => int.parse(date.substring(0, 4));
}
