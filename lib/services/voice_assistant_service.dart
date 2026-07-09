import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class VoiceAssistantService {
  static final VoiceAssistantService _instance = VoiceAssistantService._internal();
  factory VoiceAssistantService() => _instance;
  VoiceAssistantService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final List<String> _queue = [];
  bool _isSpeaking = false;

  final _speakingController = StreamController<bool>.broadcast();
  Stream<bool> get speakingStream => _speakingController.stream;

  Future<void> init() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setLanguage("ta-IN");
    
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _speakingController.add(true);
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _speakingController.add(false);
      _processQueue();
    });

    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
      _speakingController.add(false);
    });
  }

  // Compatibility method
  void updateLocale(String locale) {}

  Future<void> speak(String text) async {
    _queue.add(text);
    if (!_isSpeaking) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_queue.isEmpty) return;

    _isSpeaking = true;
    final text = _queue.removeAt(0);
    await _flutterTts.setLanguage("ta-IN");
    await _flutterTts.speak(text);
  }

  Future<void> playWorkDetailsTamil() async {
    if (_isSpeaking) return;
    const String tamilAnnouncement = "வணக்கம். உங்களுக்கு ஒரு புதிய தூய்மை பணி ஒதுக்கப்பட்டுள்ளது. தயவுசெய்து ஒதுக்கப்பட்ட இடத்திற்கு சென்று பணியை தொடங்குங்கள்.";
    await _flutterTts.setLanguage("ta-IN");
    await _flutterTts.speak(tamilAnnouncement);
  }

  Future<void> announceNewTask(String location, String wasteType) async {
    const String prefix = "உங்களுக்கு ஒரு புதிய தூய்மை பணி ஒதுக்கப்பட்டுள்ளது.";
    final String locLabel = "இடம்: $location.";
    final String typeLabel = "கழிவு வகை: $wasteType.";
    const String prompt = "வழிகாட்டுதலை தொடங்குகிறோம்.";

    await speak(prefix);
    await speak(locLabel);
    await speak(typeLabel);
    await speak(prompt);
  }

  Future<void> announceCompletion() async {
    const String msg = "பணி வெற்றிகரமாக முடிக்கப்பட்டது. நன்று.";
    await speak(msg);
  }

  Future<void> announceSOS() async {
    const String alert = "அவசர உதவி கோரிக்கை அனுப்பப்பட்டுள்ளது.";
    const String loc = "உங்கள் இருப்பிடம் நிர்வாகத்திற்கு அனுப்பப்பட்டுள்ளது.";
    await speak(alert);
    await speak(loc);
  }

  Future<void> stop() async {
    _queue.clear();
    await _flutterTts.stop();
    _isSpeaking = false;
    _speakingController.add(false);
  }
}
