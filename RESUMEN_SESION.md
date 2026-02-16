# Resumen de Sesión - App Leo

## Estado Actual
La app funciona en Android y Web con reconocimiento de voz.

## Lo que se implementó

### 1. Personaje Leo (`lib/leo_character.dart`)
- Estados: `saludando`, `asintiendo`, `escuchando`, `desconcertado`, `celebrando`
- Animaciones suaves entre estados
- Brazos, ojos y boca animados según el estado

### 2. Flujo Interactivo (`lib/screens/leo_interaction_screen.dart`)
- Leo aparece grande (scale 3.0) y se aleja con animación
- Pregunta: "Hola, yo soy Leo, ¿cómo te llamas tú?"
- Escucha respuesta por micrófono
- Responde: "¡Hola [nombre]!"
- Pregunta: "Yo tengo 5 años, ¿cuántos años tienes tú?"
- Escucha edad
- Si no entiende → estado desconcertado, repite pregunta
- Si entiende → estado celebrando: "¡Ohhh, [nombre] tú tienes [edad] años!"
- Botón "Volver a empezar" al final

### 3. Servicios de Voz
- **Web** (`lib/services/web_speech_service.dart`): Web Speech API para Chrome
- **Mobile** (`lib/services/mobile_speech_service.dart`): speech_to_text + flutter_tts
- **Factory** (`lib/services/speech_service_factory.dart`): Detecta plataforma automáticamente

### 4. Permisos Android (`android/app/src/main/AndroidManifest.xml`)
- RECORD_AUDIO, INTERNET, BLUETOOTH permisos agregados

## Repositorio
- GitHub: https://github.com/bjcc1/mi-app-leo
- Para sincronizar cambios: `git add . && git commit -m "mensaje" && git push`

## Comandos útiles
```bash
flutter pub get          # Instalar dependencias
flutter run               # Correr en dispositivo conectado
flutter run -d chrome     # Correr en Chrome
flutter build apk         # Generar APK
```

## Pendiente por mejorar (según el usuario)
- El usuario mencionó que quiere mejoras pero no especificó cuáles aún

## Notas técnicas
- Web Speech API solo funciona en Chrome/Edge
- En Android usa speech_to_text (requiere conexión a internet)
- Primera compilación Android es lenta, las siguientes son rápidas
