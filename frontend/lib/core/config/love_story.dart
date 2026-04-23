/// Entries shown in the "Our Families & Blessings" section on the landing page.
class FamilyEntry {
  const FamilyEntry({
    required this.badge,
    required this.title,
    required this.text,
    this.emoji,
  });

  /// Small chip shown above the title (e.g. "Groom's Side" or "Engaged").
  final String badge;

  /// Main heading of the card.
  final String title;

  /// Description / sub-text of the card.
  final String text;

  /// Optional emoji shown before the title.
  final String? emoji;
}

const familyEntries = <FamilyEntry>[
  FamilyEntry(
    badge: "Groom's Side",
    emoji: '🤵',
    title: 'Shiva',
    text: 'S/o Sri Krishna & Smt. Varalakshmi\nKodumur, Kurnool',
  ),
  FamilyEntry(
    badge: "Bride's Side",
    emoji: '👰',
    title: 'Pooja',
    text: 'D/o Sri Shyamoorthi & Smt. Saraswathi',
  ),
  FamilyEntry(
    badge: 'Engaged  •  06 Apr 2026',
    emoji: '💍',
    title: 'The Promise Was Sealed',
    text:
        'Surrounded by the blessings of our families, we exchanged rings and '
        'began our journey as one — a promise of a lifetime together.',
  ),
  FamilyEntry(
    badge: 'A Thought We Love',
    emoji: '✨',
    title: '“Where there is love, there is life.”',
    text: '— Mahatma Gandhi',
  ),
  FamilyEntry(
    badge: 'Saptapadi  •  The Seven Vows',
    emoji: '🪔',
    title: '“धर्मेच अर्थेच कामेच नातिचरामि”',
    text:
        'In dharma, in wealth, and in every desire — I shall walk beside you, '
        'and never stray from your side.',
  ),
  FamilyEntry(
    badge: 'Save the Date',
    emoji: '💐',
    title: 'Be a part of our forever',
    text:
        'With love and gratitude, we invite you to witness and bless the '
        'beginning of our new life together.',
  ),
];

/// Photos shown in the gallery. Files live in
/// `frontend/assets/images/gallery/`. Add or remove entries here if you
/// want more or fewer tiles — the grid adapts automatically.
const galleryImages = <String>[
  'assets/images/gallery/Shiva.jpeg',
  'assets/images/gallery/Pooja.jpeg',
  'assets/images/gallery/Pradya.jpeg',
  'assets/images/gallery/Brother.png',
];
