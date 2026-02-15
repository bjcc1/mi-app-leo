import 'dart:async';

abstract class SpeechService {
  Future<void> hablar(String texto);
  Stream<String> escuchar();
  void detenerEscucha();
  void dispose();
  bool get isListening;
}
