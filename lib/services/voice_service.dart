import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();

  VoiceService() {
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("ta-IN");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> announceNewTask() async {
    // Tamil for "You have a new task assigned. Please check the dashboard."
    String text = "உங்களுக்கு ஒரு புதிய பணி ஒதுக்கப்பட்டுள்ளது. தயவுசெய்து டேஷ்போர்டைச் சரிபார்க்கவும்.";
    await _flutterTts.speak(text);
  }

  Future<void> announceEmergency() async {
    // Tamil for "Emergency signal sent. Help is on the way."
    String text = "அவசர சமிக்ஞை அனுப்பப்பட்டது. உதவி வந்து கொண்டிருக்கிறது.";
    await _flutterTts.speak(text);
  }
}
