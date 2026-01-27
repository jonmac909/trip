/// Ticket type enum
enum TicketType { flight, hotel, activity, train, bus }

/// Ticket model for bookings and confirmations
class Ticket {
  const Ticket({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    this.time,
    this.confirmationCode,
    required this.details,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      type: TicketType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TicketType.activity,
      ),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String?,
      confirmationCode: json['confirmation_code'] as String?,
      details: Map<String, dynamic>.from(json['details'] as Map? ?? {}),
    );
  }

  final String id;
  final TicketType type;
  final String title;
  final String subtitle;
  final DateTime date;
  final String? time;
  final String? confirmationCode;
  final Map<String, dynamic> details;

  Ticket copyWith({
    String? id,
    TicketType? type,
    String? title,
    String? subtitle,
    DateTime? date,
    String? time,
    String? confirmationCode,
    Map<String, dynamic>? details,
  }) {
    return Ticket(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      date: date ?? this.date,
      time: time ?? this.time,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'date': date.toIso8601String(),
      'time': time,
      'confirmation_code': confirmationCode,
      'details': details,
    };
  }
}

/// Extension for ticket type display names and icons
extension TicketTypeExtension on TicketType {
  String get displayName {
    switch (this) {
      case TicketType.flight:
        return 'Flight';
      case TicketType.hotel:
        return 'Hotel';
      case TicketType.activity:
        return 'Activity';
      case TicketType.train:
        return 'Train';
      case TicketType.bus:
        return 'Bus';
    }
  }
}
