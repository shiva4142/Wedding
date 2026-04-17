import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLang { en, te, kn }

extension AppLangX on AppLang {
  String get code => switch (this) {
        AppLang.en => 'en',
        AppLang.te => 'te',
        AppLang.kn => 'kn',
      };

  /// Short label shown inside the language pill button.
  String get pill => switch (this) {
        AppLang.en => 'EN',
        AppLang.te => 'తె',
        AppLang.kn => 'ಕ',
      };

  String get displayName => switch (this) {
        AppLang.en => 'English',
        AppLang.te => 'తెలుగు',
        AppLang.kn => 'ಕನ್ನಡ',
      };

  AppLang get next => switch (this) {
        AppLang.en => AppLang.te,
        AppLang.te => AppLang.kn,
        AppLang.kn => AppLang.en,
      };

  static AppLang fromCode(String? c) => switch (c) {
        'te' => AppLang.te,
        'kn' => AppLang.kn,
        _ => AppLang.en,
      };
}

const _t = <AppLang, Map<String, String>>{
  AppLang.en: {
    'save_the_date': 'Save the Date',
    'countdown': 'Counting the moments',
    'days': 'Days',
    'hours': 'Hours',
    'minutes': 'Minutes',
    'seconds': 'Seconds',
    'our_story': 'Our Families',
    'how_we_met': 'With the Blessings of',
    'events': 'Events',
    'join_us': 'Join us in celebration',
    'gallery': 'Memories',
    'gallery_sub': 'A few of our favourite moments',
    'rsvp': 'RSVP',
    'will_you_join': 'Will you celebrate with us?',
    'name': 'Your Name',
    'phone': 'Phone Number',
    'attending': 'Will you be attending?',
    'yes': 'Yes, with joy',
    'no': 'Unfortunately no',
    'guests': 'Number of guests',
    'message': 'Message for the couple',
    'submit': 'Send RSVP',
    'success': 'Thank you! Your RSVP is received.',
    'wishes': 'Wishes Wall',
    'wishes_sub': 'Leave a blessing for the couple',
    'your_wish': 'Your wish...',
    'send_wish': 'Send Wish',
    'attending_now': 'guests attending',
    'share_whatsapp': 'Share on WhatsApp',
    'made_with_love': 'Made with love',
    'home': 'Home',
    'story': 'Story',
    'directions': 'Directions',
    'add_to_calendar': 'Add to Calendar',
    'view_invite': 'RSVP Now',
    'view_events': 'View Events',
    'welcome_guest': 'Welcome,',
    'we_are_excited':
        'We\'re so excited to have you celebrate this moment with us.',
  },
  AppLang.te: {
    'save_the_date': 'తేదీని గుర్తుంచుకోండి',
    'countdown': 'క్షణాలను లెక్కిస్తూ',
    'days': 'రోజులు',
    'hours': 'గంటలు',
    'minutes': 'నిమిషాలు',
    'seconds': 'సెకన్లు',
    'our_story': 'మా కుటుంబాలు',
    'how_we_met': 'పెద్దల ఆశీర్వాదాలతో',
    'events': 'కార్యక్రమాలు',
    'join_us': 'మా వేడుకలో చేరండి',
    'gallery': 'జ్ఞాపకాలు',
    'gallery_sub': 'మా ఇష్టమైన కొన్ని క్షణాలు',
    'rsvp': 'ఆహ్వాన ధృవీకరణ',
    'will_you_join': 'మీరు మాతో వేడుక చేస్తారా?',
    'name': 'మీ పేరు',
    'phone': 'ఫోన్ నంబర్',
    'attending': 'మీరు హాజరవుతారా?',
    'yes': 'అవును, ఆనందంగా',
    'no': 'క్షమించండి, లేదు',
    'guests': 'అతిథుల సంఖ్య',
    'message': 'జంటకు సందేశం',
    'submit': 'RSVP పంపండి',
    'success': 'ధన్యవాదాలు! మీ RSVP అందింది.',
    'wishes': 'శుభాకాంక్షలు',
    'wishes_sub': 'జంటకు ఆశీస్సులు ఇవ్వండి',
    'your_wish': 'మీ శుభాకాంక్ష...',
    'send_wish': 'శుభాకాంక్ష పంపండి',
    'attending_now': 'అతిథులు వస్తున్నారు',
    'share_whatsapp': 'WhatsAppలో పంచుకోండి',
    'made_with_love': 'ప్రేమతో తయారు చేయబడింది',
    'home': 'హోమ్',
    'story': 'కథ',
    'directions': 'దిశలు',
    'add_to_calendar': 'క్యాలెండర్‌కి జోడించండి',
    'view_invite': 'ఇప్పుడు RSVP చేయండి',
    'view_events': 'కార్యక్రమాలు చూడండి',
    'welcome_guest': 'స్వాగతం,',
    'we_are_excited': 'మీరు మాతో ఈ క్షణాన్ని వేడుక చేసుకోవడం ఆనందంగా ఉంది.',
  },
  AppLang.kn: {
    'save_the_date': 'ದಿನಾಂಕವನ್ನು ನೆನಪಿಡಿ',
    'countdown': 'ಕ್ಷಣಗಳನ್ನು ಎಣಿಸುತ್ತಾ',
    'days': 'ದಿನಗಳು',
    'hours': 'ಗಂಟೆಗಳು',
    'minutes': 'ನಿಮಿಷಗಳು',
    'seconds': 'ಸೆಕೆಂಡುಗಳು',
    'our_story': 'ನಮ್ಮ ಕುಟುಂಬಗಳು',
    'how_we_met': 'ಹಿರಿಯರ ಆಶೀರ್ವಾದದೊಂದಿಗೆ',
    'events': 'ಕಾರ್ಯಕ್ರಮಗಳು',
    'join_us': 'ನಮ್ಮ ಆಚರಣೆಯಲ್ಲಿ ಸೇರಿ',
    'gallery': 'ನೆನಪುಗಳು',
    'gallery_sub': 'ನಮ್ಮ ನೆಚ್ಚಿನ ಕೆಲವು ಕ್ಷಣಗಳು',
    'rsvp': 'ಆರ್‌ಎಸ್‌ವಿಪಿ',
    'will_you_join': 'ನಮ್ಮೊಂದಿಗೆ ಆಚರಿಸುತ್ತೀರಾ?',
    'name': 'ನಿಮ್ಮ ಹೆಸರು',
    'phone': 'ಫೋನ್ ಸಂಖ್ಯೆ',
    'attending': 'ನೀವು ಭಾಗವಹಿಸುತ್ತೀರಾ?',
    'yes': 'ಹೌದು, ಸಂತೋಷದಿಂದ',
    'no': 'ಕ್ಷಮಿಸಿ, ಇಲ್ಲ',
    'guests': 'ಅತಿಥಿಗಳ ಸಂಖ್ಯೆ',
    'message': 'ದಂಪತಿಗಳಿಗೆ ಸಂದೇಶ',
    'submit': 'ಆರ್‌ಎಸ್‌ವಿಪಿ ಕಳುಹಿಸಿ',
    'success': 'ಧನ್ಯವಾದಗಳು! ನಿಮ್ಮ ಆರ್‌ಎಸ್‌ವಿಪಿ ಸ್ವೀಕರಿಸಲಾಗಿದೆ.',
    'wishes': 'ಶುಭ ಹಾರೈಕೆಗಳು',
    'wishes_sub': 'ದಂಪತಿಗಳಿಗೆ ಆಶೀರ್ವಾದ ನೀಡಿ',
    'your_wish': 'ನಿಮ್ಮ ಹಾರೈಕೆ...',
    'send_wish': 'ಹಾರೈಕೆ ಕಳುಹಿಸಿ',
    'attending_now': 'ಅತಿಥಿಗಳು ಭಾಗವಹಿಸುತ್ತಿದ್ದಾರೆ',
    'share_whatsapp': 'ವಾಟ್ಸಾಪ್‌ನಲ್ಲಿ ಹಂಚಿಕೊಳ್ಳಿ',
    'made_with_love': 'ಪ್ರೀತಿಯಿಂದ ರಚಿಸಲಾಗಿದೆ',
    'home': 'ಮುಖಪುಟ',
    'story': 'ಕಥೆ',
    'directions': 'ದಾರಿ',
    'add_to_calendar': 'ಕ್ಯಾಲೆಂಡರ್‌ಗೆ ಸೇರಿಸಿ',
    'view_invite': 'ಈಗ ಆರ್‌ಎಸ್‌ವಿಪಿ ಮಾಡಿ',
    'view_events': 'ಕಾರ್ಯಕ್ರಮಗಳನ್ನು ನೋಡಿ',
    'welcome_guest': 'ಸ್ವಾಗತ,',
    'we_are_excited':
        'ನೀವು ಈ ಕ್ಷಣವನ್ನು ನಮ್ಮೊಂದಿಗೆ ಆಚರಿಸಲಿದ್ದೀರಿ ಎಂಬುದು ನಮಗೆ ಬಹಳ ಸಂತೋಷ.',
  },
};

class LocaleController extends StateNotifier<AppLang> {
  LocaleController() : super(AppLang.en) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppLangX.fromCode(prefs.getString('lang'));
  }

  Future<void> toggle() async => setLang(state.next);

  Future<void> setLang(AppLang lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', lang.code);
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, AppLang>(
  (ref) => LocaleController(),
);

String tr(AppLang lang, String key) =>
    _t[lang]?[key] ?? _t[AppLang.en]?[key] ?? key;
