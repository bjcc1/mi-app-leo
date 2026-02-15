import 'speech_service.dart';
import 'mobile_speech_service.dart';

SpeechService createSpeechService() {
  return MobileSpeechService();
}
