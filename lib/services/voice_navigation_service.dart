import 'package:flutter_tts/flutter_tts.dart';

class VoiceNavigationService {
  final FlutterTts flutterTts = FlutterTts();
  bool _isInitialized = false;

  VoiceNavigationService(){
    init();
  }

  Future<void> init() async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);

    flutterTts.setStartHandler((){
      print('TTS SPEAKING START');
    });

    flutterTts.setCompletionHandler((){
      print('TTS SPEAKING COMPLETE');
    });

    _isInitialized = true;
    print('TTS initialized successfully');
  }

  Future<void> speak(String text) async {
    if(_isInitialized){
      await flutterTts.stop();
      await flutterTts.speak(text);
    }else{
      print('TTS not initialized. Cannot speak: $text');
    }
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }
}