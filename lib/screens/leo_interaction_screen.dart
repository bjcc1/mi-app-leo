import 'dart:async';
import 'package:flutter/material.dart';
import '../leo_character.dart';
import '../services/speech_service.dart';
import '../services/speech_service_factory.dart';

enum FaseFlujo {
  inicio,
  alejandose,
  preguntaNombre,
  escuchandoNombre,
  respondeNombre,
  preguntaEdad,
  escuchandoEdad,
  respondeEdad,
  finalizado,
}

class LeoInteractionScreen extends StatefulWidget {
  const LeoInteractionScreen({super.key});

  @override
  State<LeoInteractionScreen> createState() => _LeoInteractionScreenState();
}

class _LeoInteractionScreenState extends State<LeoInteractionScreen> {
  final SpeechService _speechService = createSpeechService();

  FaseFlujo _fase = FaseFlujo.inicio;
  LeoEstado _estadoLeo = LeoEstado.saludando;
  double _scale = 3.0;
  String _nombreUsuario = '';
  int _edadUsuario = 0;
  String _textoActual = '';
  StreamSubscription<String>? _speechSubscription;

  @override
  void initState() {
    super.initState();
    _iniciarFlujo();
  }

  @override
  void dispose() {
    _speechSubscription?.cancel();
    _speechService.dispose();
    super.dispose();
  }

  Future<void> _iniciarFlujo() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _fase = FaseFlujo.alejandose;
      _scale = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    _preguntarNombre();
  }

  Future<void> _preguntarNombre() async {
    setState(() {
      _fase = FaseFlujo.preguntaNombre;
      _estadoLeo = LeoEstado.saludando;
      _textoActual = 'Hola, yo soy Leo, ¿cómo te llamas tú?';
    });

    await _speechService.hablar('Hola, yo soy Leo, cómo te llamas tú?');

    if (!mounted) return;
    _escucharNombre();
  }

  void _escucharNombre() {
    setState(() {
      _fase = FaseFlujo.escuchandoNombre;
      _estadoLeo = LeoEstado.escuchando;
      _textoActual = 'Escuchando...';
    });

    _speechSubscription?.cancel();
    _speechSubscription = _speechService.escuchar().listen(
      (texto) {
        if (texto.isNotEmpty) {
          _procesarNombre(texto);
        }
      },
      onError: (error) {
        _mostrarError('Error al escuchar: $error');
      },
    );
  }

  Future<void> _procesarNombre(String texto) async {
    _speechSubscription?.cancel();
    _speechService.detenerEscucha();

    final nombre = _extraerNombre(texto);
    _nombreUsuario = nombre.isNotEmpty ? nombre : texto;

    setState(() {
      _fase = FaseFlujo.respondeNombre;
      _estadoLeo = LeoEstado.saludando;
      _textoActual = '¡Hola $_nombreUsuario!';
    });

    await _speechService.hablar('Hola $_nombreUsuario!');

    if (!mounted) return;
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    _preguntarEdad();
  }

  String _extraerNombre(String texto) {
    final textoLimpio = texto.trim();

    final patrones = [
      RegExp(r'me llamo\s+(\w+)', caseSensitive: false),
      RegExp(r'soy\s+(\w+)', caseSensitive: false),
      RegExp(r'mi nombre es\s+(\w+)', caseSensitive: false),
    ];

    for (final patron in patrones) {
      final match = patron.firstMatch(textoLimpio);
      if (match != null) {
        return _capitalizarNombre(match.group(1)!);
      }
    }

    final palabras = textoLimpio.split(' ');
    if (palabras.isNotEmpty) {
      return _capitalizarNombre(palabras.first);
    }

    return textoLimpio;
  }

  String _capitalizarNombre(String nombre) {
    if (nombre.isEmpty) return nombre;
    return nombre[0].toUpperCase() + nombre.substring(1).toLowerCase();
  }

  Future<void> _preguntarEdad() async {
    setState(() {
      _fase = FaseFlujo.preguntaEdad;
      _estadoLeo = LeoEstado.asintiendo;
      _textoActual = 'Yo tengo 5 años, ¿cuántos años tienes tú?';
    });

    await _speechService.hablar('Yo tengo 5 años, cuántos años tienes tú?');

    if (!mounted) return;
    _escucharEdad();
  }

  void _escucharEdad() {
    setState(() {
      _fase = FaseFlujo.escuchandoEdad;
      _estadoLeo = LeoEstado.escuchando;
      _textoActual = 'Escuchando...';
    });

    _speechSubscription?.cancel();
    _speechSubscription = _speechService.escuchar().listen(
      (texto) {
        if (texto.isNotEmpty) {
          _procesarEdad(texto);
        }
      },
      onError: (error) {
        _mostrarError('Error al escuchar: $error');
      },
    );
  }

  Future<void> _procesarEdad(String texto) async {
    _speechSubscription?.cancel();
    _speechService.detenerEscucha();

    final edad = _extraerEdad(texto);

    if (edad == null || edad < 1 || edad > 120) {
      setState(() {
        _estadoLeo = LeoEstado.desconcertado;
        _textoActual = 'No entendí, ¿cuántos años tienes?';
      });

      await _speechService.hablar('No entendí, cuántos años tienes?');

      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      _escucharEdad();
      return;
    }

    _edadUsuario = edad;

    setState(() {
      _fase = FaseFlujo.respondeEdad;
      _estadoLeo = LeoEstado.celebrando;
      _textoActual = '¡Ohhh, $_nombreUsuario tú tienes $_edadUsuario años!';
    });

    await _speechService.hablar('Ohhh, $_nombreUsuario tú tienes $_edadUsuario años!');

    if (!mounted) return;
    setState(() {
      _fase = FaseFlujo.finalizado;
    });
  }

  int? _extraerEdad(String texto) {
    final numerosEscritos = {
      'uno': 1, 'una': 1,
      'dos': 2,
      'tres': 3,
      'cuatro': 4,
      'cinco': 5,
      'seis': 6,
      'siete': 7,
      'ocho': 8,
      'nueve': 9,
      'diez': 10,
      'once': 11,
      'doce': 12,
    };

    final textoLower = texto.toLowerCase();

    for (final entry in numerosEscritos.entries) {
      if (textoLower.contains(entry.key)) {
        return entry.value;
      }
    }

    final regexNumero = RegExp(r'\d+');
    final match = regexNumero.firstMatch(texto);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }

    return null;
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void _reiniciarFlujo() {
    setState(() {
      _fase = FaseFlujo.inicio;
      _estadoLeo = LeoEstado.saludando;
      _scale = 3.0;
      _nombreUsuario = '';
      _edadUsuario = 0;
      _textoActual = '';
    });
    _iniciarFlujo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AnimatedScale(
                  scale: _scale,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: LeoCharacter(
                    estado: _estadoLeo,
                    size: 150,
                  ),
                ),
              ),
            ),
            if (_textoActual.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_fase == FaseFlujo.escuchandoNombre ||
                        _fase == FaseFlujo.escuchandoEdad)
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.mic,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                    Flexible(
                      child: Text(
                        _textoActual,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2C5282),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            if (_fase == FaseFlujo.finalizado)
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton.icon(
                  onPressed: _reiniciarFlujo,
                  icon: const Icon(Icons.replay),
                  label: const Text('Volver a empezar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
