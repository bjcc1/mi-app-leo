import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Estados disponibles para el personaje Leo
enum LeoEstado {
  saludando,
  asintiendo,
  escuchando,
  desconcertado,
  celebrando,
}

/// Widget principal del personaje Leo
/// Recibe un [estado] que define la animación actual
class LeoCharacter extends StatefulWidget {
  final LeoEstado estado;
  final double size;

  const LeoCharacter({
    super.key,
    required this.estado,
    this.size = 200,
  });

  @override
  State<LeoCharacter> createState() => _LeoCharacterState();
}

class _LeoCharacterState extends State<LeoCharacter>
    with TickerProviderStateMixin {
  // Controlador principal para transiciones entre estados
  late AnimationController _transitionController;

  // Controlador para animaciones continuas (movimiento de mano, etc.)
  late AnimationController _loopController;

  // Valores animados para cada parte del cuerpo
  late Animation<double> _brazoDerecho;
  late Animation<double> _brazoIzquierdo;
  late Animation<double> _rotacionCabeza;
  late Animation<double> _inclinacionCabeza;
  late Animation<double> _tamanoOjos;
  late Animation<double> _tipoBoca; // 0=sonrisa, 0.5=neutra, 1=O pequeña

  // Valores objetivo según el estado
  double _brazoDereChoTarget = 0;
  double _brazoIzquierdoTarget = 0;
  double _rotacionCabezaTarget = 0;
  double _inclinacionCabezaTarget = 0;
  double _tamanoOjosTarget = 1;
  double _tipoBocaTarget = 0.5;

  // Valores actuales (para interpolación suave)
  double _brazoDerecho_ = 0;
  double _brazoIzquierdo_ = 0;
  double _rotacionCabeza_ = 0;
  double _inclinacionCabeza_ = 0;
  double _tamanoOjos_ = 1;
  double _tipoBoca_ = 0.5;

  @override
  void initState() {
    super.initState();

    // Controlador para transiciones suaves entre estados (500ms)
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Controlador para animaciones en loop (movimiento continuo)
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _setupAnimations();
    _updateTargetsForState(widget.estado);
    _transitionController.forward();
  }

  /// Configura las animaciones con curvas suaves
  void _setupAnimations() {
    final curvedAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    );

    _brazoDerecho = Tween<double>(begin: _brazoDerecho_, end: _brazoDereChoTarget)
        .animate(curvedAnimation);
    _brazoIzquierdo = Tween<double>(begin: _brazoIzquierdo_, end: _brazoIzquierdoTarget)
        .animate(curvedAnimation);
    _rotacionCabeza = Tween<double>(begin: _rotacionCabeza_, end: _rotacionCabezaTarget)
        .animate(curvedAnimation);
    _inclinacionCabeza = Tween<double>(begin: _inclinacionCabeza_, end: _inclinacionCabezaTarget)
        .animate(curvedAnimation);
    _tamanoOjos = Tween<double>(begin: _tamanoOjos_, end: _tamanoOjosTarget)
        .animate(curvedAnimation);
    _tipoBoca = Tween<double>(begin: _tipoBoca_, end: _tipoBocaTarget)
        .animate(curvedAnimation);
  }

  /// Define los valores objetivo según el estado
  void _updateTargetsForState(LeoEstado estado) {
    // Guardamos los valores actuales como punto de inicio
    _brazoDerecho_ = _brazoDerecho.value;
    _brazoIzquierdo_ = _brazoIzquierdo.value;
    _rotacionCabeza_ = _rotacionCabeza.value;
    _inclinacionCabeza_ = _inclinacionCabeza.value;
    _tamanoOjos_ = _tamanoOjos.value;
    _tipoBoca_ = _tipoBoca.value;

    switch (estado) {
      case LeoEstado.saludando:
        // Brazo derecho levantado 45°, boca sonriente
        _brazoDereChoTarget = -45 * math.pi / 180;
        _brazoIzquierdoTarget = 0;
        _rotacionCabezaTarget = 0;
        _inclinacionCabezaTarget = 0;
        _tamanoOjosTarget = 1;
        _tipoBocaTarget = 0; // Sonrisa
        break;

      case LeoEstado.asintiendo:
        // Cabeza bajando/subiendo (usa loopController), boca neutra
        _brazoDereChoTarget = 0;
        _brazoIzquierdoTarget = 0;
        _rotacionCabezaTarget = 0;
        _inclinacionCabezaTarget = 0; // Se anima con loopController
        _tamanoOjosTarget = 1;
        _tipoBocaTarget = 0.5; // Neutra
        break;

      case LeoEstado.escuchando:
        // Cabeza inclinada 15°, mano izquierda cerca de oreja, ojos grandes, boca O
        _brazoDereChoTarget = 0;
        _brazoIzquierdoTarget = -60 * math.pi / 180;
        _rotacionCabezaTarget = 15 * math.pi / 180;
        _inclinacionCabezaTarget = 0;
        _tamanoOjosTarget = 1.3; // Ojos más grandes
        _tipoBocaTarget = 1; // Boca O pequeña
        break;

      case LeoEstado.desconcertado:
        // Cabeza ladeada 30°, mano rascando cabeza, boca O, ojos confusos
        _brazoDereChoTarget = -80 * math.pi / 180;
        _brazoIzquierdoTarget = 0;
        _rotacionCabezaTarget = -30 * math.pi / 180;
        _inclinacionCabezaTarget = 0;
        _tamanoOjosTarget = 0.8; // Ojos más pequeños (confusos)
        _tipoBocaTarget = 1; // Boca O pequeña
        break;

      case LeoEstado.celebrando:
        // Brazos arriba, sonrisa grande, ojos brillantes
        _brazoDereChoTarget = -120 * math.pi / 180; // Brazo derecho muy arriba
        _brazoIzquierdoTarget = -120 * math.pi / 180; // Brazo izquierdo muy arriba
        _rotacionCabezaTarget = 0;
        _inclinacionCabezaTarget = 0;
        _tamanoOjosTarget = 1.4; // Ojos muy grandes (brillantes)
        _tipoBocaTarget = 0; // Sonrisa grande
        break;
    }

    _setupAnimations();
  }

  @override
  void didUpdateWidget(LeoCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambia el estado, animar suavemente hacia el nuevo
    if (oldWidget.estado != widget.estado) {
      _updateTargetsForState(widget.estado);
      _transitionController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_transitionController, _loopController]),
      builder: (context, child) {
        // Calcular valores adicionales para animaciones en loop
        double extraInclinacion = 0;
        double extraMano = 0;

        if (widget.estado == LeoEstado.asintiendo) {
          // Movimiento de cabeza arriba/abajo
          extraInclinacion = math.sin(_loopController.value * math.pi) * 0.15;
        }

        if (widget.estado == LeoEstado.saludando) {
          // Movimiento de mano saludando
          extraMano = math.sin(_loopController.value * math.pi * 2) * 0.2;
        }

        double extraBrazos = 0;
        if (widget.estado == LeoEstado.celebrando) {
          // Movimiento de brazos arriba/abajo celebrando
          extraBrazos = math.sin(_loopController.value * math.pi * 2) * 0.15;
        }

        return CustomPaint(
          size: Size(widget.size, widget.size * 1.5),
          painter: LeoPainter(
            brazoDerecho: _brazoDerecho.value + extraMano + extraBrazos,
            brazoIzquierdo: _brazoIzquierdo.value + extraBrazos,
            rotacionCabeza: _rotacionCabeza.value,
            inclinacionCabeza: _inclinacionCabeza.value + extraInclinacion,
            tamanoOjos: _tamanoOjos.value,
            tipoBoca: _tipoBoca.value,
            estado: widget.estado,
          ),
        );
      },
    );
  }
}

/// CustomPainter que dibuja el personaje Leo
class LeoPainter extends CustomPainter {
  final double brazoDerecho;
  final double brazoIzquierdo;
  final double rotacionCabeza;
  final double inclinacionCabeza;
  final double tamanoOjos;
  final double tipoBoca; // 0=sonrisa, 0.5=neutra, 1=boca O
  final LeoEstado estado;

  // Color principal de Leo
  static const Color colorPrincipal = Color(0xFF4A90E2);
  static const Color colorOjos = Colors.black;
  static const Color colorBoca = Color(0xFF2C5282);

  LeoPainter({
    required this.brazoDerecho,
    required this.brazoIzquierdo,
    required this.rotacionCabeza,
    required this.inclinacionCabeza,
    required this.tamanoOjos,
    required this.tipoBoca,
    required this.estado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final cuerpoY = size.height * 0.65;
    final radioCuerpo = size.width * 0.35;
    final radioCabeza = size.width * 0.25;
    final cabezaY = size.height * 0.3;

    final paintCuerpo = Paint()
      ..color = colorPrincipal
      ..style = PaintingStyle.fill;

    final paintOjos = Paint()
      ..color = colorOjos
      ..style = PaintingStyle.fill;

    final paintBoca = Paint()
      ..color = colorBoca
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // ===== DIBUJAR CUERPO =====
    // Cuerpo: círculo grande azul claro
    canvas.drawCircle(
      Offset(centerX, cuerpoY),
      radioCuerpo,
      paintCuerpo,
    );

    // ===== DIBUJAR BRAZOS =====
    _dibujarBrazo(
      canvas,
      centerX + radioCuerpo * 0.8, // Posición X del brazo derecho
      cuerpoY - radioCuerpo * 0.3,
      radioCuerpo * 0.6,
      brazoDerecho,
      true, // Es brazo derecho
      paintCuerpo,
    );

    _dibujarBrazo(
      canvas,
      centerX - radioCuerpo * 0.8, // Posición X del brazo izquierdo
      cuerpoY - radioCuerpo * 0.3,
      radioCuerpo * 0.6,
      brazoIzquierdo,
      false, // Es brazo izquierdo
      paintCuerpo,
    );

    // ===== DIBUJAR CABEZA =====
    canvas.save();
    // Aplicar rotación e inclinación a la cabeza
    canvas.translate(centerX, cabezaY);
    canvas.rotate(rotacionCabeza);
    canvas.translate(0, inclinacionCabeza * radioCabeza);
    canvas.translate(-centerX, -cabezaY);

    // Cabeza: círculo mediano
    canvas.drawCircle(
      Offset(centerX, cabezaY),
      radioCabeza,
      paintCuerpo,
    );

    // ===== DIBUJAR OJOS =====
    final radioOjo = radioCabeza * 0.12 * tamanoOjos;
    final separacionOjos = radioCabeza * 0.4;
    final alturaOjos = cabezaY - radioCabeza * 0.1;

    // Ojo izquierdo
    canvas.drawCircle(
      Offset(centerX - separacionOjos, alturaOjos),
      radioOjo,
      paintOjos,
    );

    // Ojo derecho
    canvas.drawCircle(
      Offset(centerX + separacionOjos, alturaOjos),
      radioOjo,
      paintOjos,
    );

    // Si está desconcertado, dibujar cejas confusas
    if (estado == LeoEstado.desconcertado) {
      final paintCeja = Paint()
        ..color = colorBoca
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Ceja izquierda (levantada)
      canvas.drawLine(
        Offset(centerX - separacionOjos - radioOjo, alturaOjos - radioOjo * 2),
        Offset(centerX - separacionOjos + radioOjo, alturaOjos - radioOjo * 1.5),
        paintCeja,
      );

      // Ceja derecha (bajada)
      canvas.drawLine(
        Offset(centerX + separacionOjos - radioOjo, alturaOjos - radioOjo * 1.5),
        Offset(centerX + separacionOjos + radioOjo, alturaOjos - radioOjo * 2),
        paintCeja,
      );
    }

    // ===== DIBUJAR BOCA =====
    final bocaY = cabezaY + radioCabeza * 0.35;

    if (tipoBoca < 0.3) {
      // Sonrisa
      final path = Path();
      path.moveTo(centerX - radioCabeza * 0.3, bocaY);
      path.quadraticBezierTo(
        centerX,
        bocaY + radioCabeza * 0.25,
        centerX + radioCabeza * 0.3,
        bocaY,
      );
      canvas.drawPath(path, paintBoca);
    } else if (tipoBoca < 0.7) {
      // Boca neutra (línea recta)
      canvas.drawLine(
        Offset(centerX - radioCabeza * 0.2, bocaY),
        Offset(centerX + radioCabeza * 0.2, bocaY),
        paintBoca,
      );
    } else {
      // Boca O pequeña
      canvas.drawCircle(
        Offset(centerX, bocaY),
        radioCabeza * 0.1,
        paintBoca,
      );
    }

    canvas.restore();
  }

  /// Dibuja un brazo (óvalo) con rotación
  void _dibujarBrazo(
    Canvas canvas,
    double x,
    double y,
    double largo,
    double angulo,
    bool esDerecho,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(x, y);

    // Rotar el brazo
    if (esDerecho) {
      canvas.rotate(angulo);
    } else {
      canvas.rotate(-angulo);
    }

    // Dibujar óvalo (brazo)
    final rect = Rect.fromCenter(
      center: Offset(esDerecho ? largo / 2 : -largo / 2, 0),
      width: largo,
      height: largo * 0.35,
    );
    canvas.drawOval(rect, paint);

    // Dibujar mano (círculo pequeño al final del brazo)
    final manoX = esDerecho ? largo : -largo;
    canvas.drawCircle(
      Offset(manoX * 0.9, 0),
      largo * 0.2,
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(LeoPainter oldDelegate) {
    return brazoDerecho != oldDelegate.brazoDerecho ||
        brazoIzquierdo != oldDelegate.brazoIzquierdo ||
        rotacionCabeza != oldDelegate.rotacionCabeza ||
        inclinacionCabeza != oldDelegate.inclinacionCabeza ||
        tamanoOjos != oldDelegate.tamanoOjos ||
        tipoBoca != oldDelegate.tipoBoca ||
        estado != oldDelegate.estado;
  }
}
