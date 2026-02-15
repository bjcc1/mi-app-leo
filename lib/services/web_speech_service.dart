import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'speech_service.dart';

@JS('webkitSpeechRecognition')
extension type SpeechRecognition._(JSObject _) implements JSObject {
  external SpeechRecognition();
  external set continuous(bool value);
  external set interimResults(bool value);
  external set lang(String value);
  external void start();
  external void stop();
  external void abort();
  external set onresult(JSFunction? callback);
  external set onerror(JSFunction? callback);
  external set onend(JSFunction? callback);
}

@JS()
extension type SpeechRecognitionEvent._(JSObject _) implements JSObject {
  external SpeechRecognitionResultList get results;
}

@JS()
extension type SpeechRecognitionResultList._(JSObject _) implements JSObject {
  external int get length;
  external SpeechRecognitionResult item(int index);
}

@JS()
extension type SpeechRecognitionResult._(JSObject _) implements JSObject {
  external SpeechRecognitionAlternative item(int index);
  external bool get isFinal;
}

@JS()
extension type SpeechRecognitionAlternative._(JSObject _) implements JSObject {
  external String get transcript;
  external num get confidence;
}

@JS()
extension type SpeechRecognitionErrorEvent._(JSObject _) implements JSObject {
  external String get error;
  external String get message;
}

class WebSpeechService implements SpeechService {
  static final WebSpeechService _instance = WebSpeechService._internal();
  factory WebSpeechService() => _instance;
  WebSpeechService._internal();

  SpeechRecognition? _recognition;
  StreamController<String>? _speechController;
  bool _isListening = false;

  @override
  bool get isListening => _isListening;

  @override
  Future<void> hablar(String texto) async {
    final completer = Completer<void>();

    // Esperar a que las voces estén disponibles
    await _esperarVoces();

    final utterance = web.SpeechSynthesisUtterance(texto);

    // Buscar una voz en español
    final voices = web.window.speechSynthesis.getVoices().toDart;
    web.SpeechSynthesisVoice? vozEspanol;

    for (final voice in voices) {
      if (voice.lang.startsWith('es')) {
        vozEspanol = voice;
        break;
      }
    }

    if (vozEspanol != null) {
      utterance.voice = vozEspanol;
    }

    utterance.lang = 'es-ES';
    utterance.rate = 0.9;
    utterance.pitch = 1.2;
    utterance.volume = 1.0;

    utterance.onend = ((web.Event event) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }).toJS;

    utterance.onerror = ((web.Event event) {
      // Completar sin error para no bloquear el flujo
      if (!completer.isCompleted) {
        completer.complete();
      }
    }).toJS;

    // Cancelar cualquier síntesis en curso
    web.window.speechSynthesis.cancel();
    web.window.speechSynthesis.speak(utterance);

    return completer.future;
  }

  Future<void> _esperarVoces() async {
    final voices = web.window.speechSynthesis.getVoices().toDart;
    if (voices.isNotEmpty) return;

    // Esperar hasta 2 segundos para que carguen las voces
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (web.window.speechSynthesis.getVoices().toDart.isNotEmpty) {
        return;
      }
    }
  }

  @override
  Stream<String> escuchar() {
    _speechController?.close();
    _speechController = StreamController<String>.broadcast();

    try {
      _recognition = SpeechRecognition();
    } catch (e) {
      _speechController!.addError('SpeechRecognition no soportado en este navegador');
      return _speechController!.stream;
    }

    _recognition!.continuous = false;
    _recognition!.interimResults = true;
    _recognition!.lang = 'es-ES';

    _recognition!.onresult = ((JSAny event) {
      final speechEvent = event as SpeechRecognitionEvent;
      final results = speechEvent.results;

      if (results.length > 0) {
        final result = results.item(results.length - 1);
        final transcript = result.item(0).transcript;

        if (result.isFinal) {
          _speechController?.add(transcript);
        }
      }
    }).toJS;

    _recognition!.onerror = ((JSAny event) {
      final errorEvent = event as SpeechRecognitionErrorEvent;
      if (errorEvent.error != 'no-speech' && errorEvent.error != 'aborted') {
        _speechController?.addError('Error: ${errorEvent.error}');
      }
    }).toJS;

    _recognition!.onend = ((JSAny event) {
      _isListening = false;
    }).toJS;

    _isListening = true;
    _recognition!.start();

    return _speechController!.stream;
  }

  @override
  void detenerEscucha() {
    if (_recognition != null && _isListening) {
      _recognition!.stop();
      _isListening = false;
    }
  }

  @override
  void dispose() {
    detenerEscucha();
    _speechController?.close();
  }
}
