import 'package:flutter/material.dart';
import 'leo_character.dart';

/// Pantalla de demostración para probar el personaje Leo
/// y sus transiciones suaves entre estados
class LeoDemoScreen extends StatefulWidget {
  const LeoDemoScreen({super.key});

  @override
  State<LeoDemoScreen> createState() => _LeoDemoScreenState();
}

class _LeoDemoScreenState extends State<LeoDemoScreen> {
  LeoEstado _estadoActual = LeoEstado.saludando;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Leo - Demo'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Área del personaje
          Expanded(
            flex: 3,
            child: Center(
              child: LeoCharacter(
                estado: _estadoActual,
                size: 200,
              ),
            ),
          ),

          // Indicador del estado actual
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Estado: ${_estadoActual.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),

          // Botones para cambiar de estado
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _botonEstado(
                    'Saludando',
                    LeoEstado.saludando,
                    Icons.waving_hand,
                  ),
                  _botonEstado(
                    'Asintiendo',
                    LeoEstado.asintiendo,
                    Icons.check_circle_outline,
                  ),
                  _botonEstado(
                    'Escuchando',
                    LeoEstado.escuchando,
                    Icons.hearing,
                  ),
                  _botonEstado(
                    'Desconcertado',
                    LeoEstado.desconcertado,
                    Icons.help_outline,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Crea un botón para cambiar al estado indicado
  Widget _botonEstado(String texto, LeoEstado estado, IconData icono) {
    final bool seleccionado = _estadoActual == estado;

    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _estadoActual = estado;
        });
      },
      icon: Icon(icono, size: 20),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: seleccionado
            ? const Color(0xFF4A90E2)
            : Colors.white,
        foregroundColor: seleccionado
            ? Colors.white
            : const Color(0xFF4A90E2),
        elevation: seleccionado ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF4A90E2),
            width: 2,
          ),
        ),
      ),
    );
  }
}
