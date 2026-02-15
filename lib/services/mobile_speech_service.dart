import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'speech_service.dart';

class MobileSpeechService implements SpeechService {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  StreamController<String>? _speechController;
  bool _isListening = false;
  bool _sttInitialized = false;

  MobileSpeechService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.2);
    await _tts.setVolume(1.0);
  }

  Future<void> _initStt() async {
    if (_sttInitialized) return;
    _sttInitialized = await _stt.initialize(
      onError: (error) {
        _speechController?.addError('Error: ${error.errorMsg}');
        _isListening = false;
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
    );
  }

  @override
  bool get isListening => _isListening;

  @override
  Future<void> hablar(String texto) async {
    final completer = Completer<void>();

    _tts.setCompletionHandler(() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _tts.setErrorHandler((error) {
      if (!completer.isCompleted) {
        completer.complete(); // Complete anyway to not block the flow
      }
    });

    await _tts.speak(texto);

    return completer.future;
  }

  @override
  Stream<String> escuchar() {
    _speechController?.close();
    _speechController = StreamController<String>.broadcast();

    _startListening();

    return _speechController!.stream;
  }

  Future<void> _startListening() async {
    await _initStt();

    if (!_sttInitialized) {
      _speechController?.addError('Reconocimiento de voz no disponible');
      return;
    }

    _isListening = true;

    await _stt.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _speechController?.add(result.recognizedWords);
        }
      },
      localeId: 'es_ES',
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      partialResults: false,
    );
  }

  @override
  void detenerEscucha() {
    if (_isListening) {
      _stt.stop();
      _isListening = false;
    }
  }

  @override
  void dispose() {
    detenerEscucha();
    _speechController?.close();
    _tts.stop();
  }
}
