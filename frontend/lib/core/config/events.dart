import 'package:flutter/material.dart';

class WeddingEvent {
  const WeddingEvent({
    required this.id,
    required this.title,
    required this.emoji,
    required this.date,
    required this.location,
    required this.mapQuery,
    required this.description,
    required this.dressCode,
    required this.gradient,
  });

  final String id;
  final String title;
  final String emoji;
  final DateTime date;
  final String location;
  final String mapQuery;
  final String description;
  final String dressCode;
  final List<Color> gradient;
}

final weddingEvents = <WeddingEvent>[
  WeddingEvent(
    id: 'haldi',
    title: 'Haldi Ceremony',
    emoji: '🌼',
    date: DateTime(2026, 4, 30, 10, 0),
    location: 'Shiva\'s Residence, Kodumur',
    mapQuery: 'Kodumur, Kurnool, Andhra Pradesh',
    description:
        'A joyful morning of turmeric, laughter, and blessings as we prepare for the big day.',
    dressCode: 'Sunshine yellow',
    gradient: const [Color(0xFFFFE082), Color(0xFFFFB74D)],
  ),
  WeddingEvent(
    id: 'mehendi',
    title: 'Mehendi Night',
    emoji: '🌿',
    date: DateTime(2026, 4, 29, 17, 0),
    location: 'Pooja\'s Residence, Kandagal',
    mapQuery: 'kandagal, ilkal, bagalkot, karnataka',
    description:
        'Music, dance, and intricate henna designs that tell stories of love.',
    dressCode: 'Emerald & teal',
    gradient: const [Color(0xFFA5D6A7), Color(0xFF66BB6A)],
  ),
  WeddingEvent(
    id: 'wedding',
    title: 'The Wedding',
    emoji: '💍',
    date: DateTime(2026, 5, 1, 9, 25, 0),
    location: 'Sri Ramulavari Temple, Kodumur',
    mapQuery: 'Sri Ramulavari Temple, Kodumur, Kurnool, Andhra Pradesh',
    description:
        'Seven vows, a sacred fire, and the beginning of forever under starlit skies.',
    dressCode: 'Traditional finery',
    gradient: const [Color(0xFFFFB6C1), Color(0xFFE91E63)],
  ),
  WeddingEvent(
    id: 'reception',
    title: 'Reception',
    emoji: '🎉',
    date: DateTime(2026, 4, 30, 19, 30),
    location: 'Sri Ramulavari Temple, Kodumur',
    mapQuery: 'Sri Ramulavari Temple, Kodumur, Kurnool, Andhra Pradesh',
    description:
        'Dinner, dancing, and a celebration of our new chapter — with you.',
    dressCode: 'Traditional attire',
    gradient: const [Color(0xFFCE93D8), Color(0xFFAB47BC)],
  ),
];
