import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class VoiceNavigationService {
  final FlutterTts flutterTts = FlutterTts();
  bool _isInitialized = false;

  VoiceNavigationService() {
    init();
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await flutterTts.setLanguage("pt-BR");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      if (GetPlatform.isIOS) {
        await flutterTts.setSharedInstance(true);
        await flutterTts
            .setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
              IosTextToSpeechAudioCategoryOptions.duckOthers,
              IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            ]);
      }

      _setupHandlers();

      _isInitialized = true;
      debugPrint('TTS: Inicializado com sucesso em pt-BR');
    } catch (e) {
      debugPrint('TTS ERROR: Falha ao incializar: $e');
      _isInitialized = false;
    }
  }

  void _setupHandlers() {
    flutterTts.setStartHandler(() => debugPrint('TTS: Iniciou a fala'));
    flutterTts.setCompletionHandler(() => debugPrint('TTS: Concluiu a fala'));
    flutterTts.setErrorHandler((msg) {
      debugPrint('TTS ERROR: $msg');
      _isInitialized = false;
    });
  }

  Future<void> speak(String text) async {
    if (_isInitialized) {
      await flutterTts.stop();
      await flutterTts.speak(text);
    } else {
      debugPrint('TTS not initialized. Cannot speak: $text');
    }
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await flutterTts.stop();
      // await flutterTts.shutdown();
      _isInitialized = false;
      debugPrint('TTS Service shutdown.');
    }
  }
}
