import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Grad {
  final double x, y, z;

  Grad(this.x, this.y, this.z);

  double dot2(double x, double y) {
    return this.x * x + this.y * y;
  }
}

class NoiseGenerator {
  late List<Grad> grad3;
  late List<int> p;
  late List<int> perm;
  late List<Grad> gradP;

  NoiseGenerator([double seed = 0]) {
    grad3 = [
      Grad(1, 1, 0),
      Grad(-1, 1, 0),
      Grad(1, -1, 0),
      Grad(-1, -1, 0),
      Grad(1, 0, 1),
      Grad(-1, 0, 1),
      Grad(1, 0, -1),
      Grad(-1, 0, -1),
      Grad(0, 1, 1),
      Grad(0, -1, 1),
      Grad(0, 1, -1),
      Grad(0, -1, -1)
    ];

    p = [
      151,
      160,
      137,
      91,
      90,
      15,
      131,
      13,
      201,
      95,
      96,
      53,
      194,
      233,
      7,
      225,
      140,
      36,
      103,
      30,
      69,
      142,
      8,
      99,
      37,
      240,
      21,
      10,
      23,
      190,
      6,
      148,
      247,
      120,
      234,
      75,
      0,
      26,
      197,
      62,
      94,
      252,
      219,
      203,
      117,
      35,
      11,
      32,
      57,
      177,
      33,
      88,
      237,
      149,
      56,
      87,
      174,
      20,
      125,
      136,
      171,
      168,
      68,
      175,
      74,
      165,
      71,
      134,
      139,
      48,
      27,
      166,
      77,
      146,
      158,
      231,
      83,
      111,
      229,
      122,
      60,
      211,
      133,
      230,
      220,
      105,
      92,
      41,
      55,
      46,
      245,
      40,
      244,
      102,
      143,
      54,
      65,
      25,
      63,
      161,
      1,
      216,
      80,
      73,
      209,
      76,
      132,
      187,
      208,
      89,
      18,
      169,
      200,
      196,
      135,
      130,
      116,
      188,
      159,
      86,
      164,
      100,
      109,
      198,
      173,
      186,
      3,
      64,
      52,
      217,
      226,
      250,
      124,
      123,
      5,
      202,
      38,
      147,
      118,
      126,
      255,
      82,
      85,
      212,
      207,
      206,
      59,
      227,
      47,
      16,
      58,
      17,
      182,
      189,
      28,
      42,
      223,
      183,
      170,
      213,
      119,
      248,
      152,
      2,
      44,
      154,
      163,
      70,
      221,
      153,
      101,
      155,
      167,
      43,
      172,
      9,
      129,
      22,
      39,
      253,
      19,
      98,
      108,
      110,
      79,
      113,
      224,
      232,
      178,
      185,
      112,
      104,
      218,
      246,
      97,
      228,
      251,
      34,
      242,
      193,
      238,
      210,
      144,
      12,
      191,
      179,
      162,
      241,
      81,
      51,
      145,
      235,
      249,
      14,
      239,
      107,
      49,
      192,
      214,
      31,
      181,
      199,
      106,
      157,
      184,
      84,
      204,
      176,
      115,
      121,
      50,
      45,
      127,
      4,
      150,
      254,
      138,
      236,
      205,
      93,
      222,
      114,
      67,
      29,
      24,
      72,
      243,
      141,
      128,
      195,
      78,
      66,
      215,
      61,
      156,
      180
    ];

    perm = List<int>.filled(512, 0);
    gradP = List<Grad>.filled(512, Grad(0, 0, 0));

    _seed(seed);
  }

  void _seed(double seed) {
    if (seed > 0 && seed < 1) seed *= 65536;
    int seedInt = seed.floor();
    if (seedInt < 256) seedInt |= seedInt << 8;

    for (int i = 0; i < 256; i++) {
      int v = (i & 1) == 1
          ? (p[i] ^ (seedInt & 255))
          : (p[i] ^ ((seedInt >> 8) & 255));
      perm[i] = perm[i + 256] = v;
      gradP[i] = gradP[i + 256] = grad3[v % 12];
    }
  }

  double _fade(double t) {
    return t * t * t * (t * (t * 6 - 15) + 10);
  }

  double _lerp(double a, double b, double t) {
    return (1 - t) * a + t * b;
  }

  double perlin2(double x, double y) {
    int X = x.floor();
    int Y = y.floor();
    x -= X;
    y -= Y;
    X &= 255;
    Y &= 255;

    double n00 = gradP[X + perm[Y]].dot2(x, y);
    double n01 = gradP[X + perm[Y + 1]].dot2(x, y - 1);
    double n10 = gradP[X + 1 + perm[Y]].dot2(x - 1, y);
    double n11 = gradP[X + 1 + perm[Y + 1]].dot2(x - 1, y - 1);

    double u = _fade(x);

    return _lerp(_lerp(n00, n10, u), _lerp(n01, n11, u), _fade(y));
  }
}

class WavePoint {
  double x, y;
  Offset wave = Offset.zero;
  Offset cursor = Offset.zero;
  Offset cursorVelocity = Offset.zero;

  WavePoint(this.x, this.y);
}

class MouseState {
  double x = -10, y = 0, lx = 0, ly = 0, sx = 0, sy = 0;
  double v = 0, vs = 0, a = 0;
  bool set = false;
}

class WavesPainter extends CustomPainter {
  final List<List<WavePoint>> lines;
  final Color lineColor;
  final double time;

  WavesPainter({
    required this.lines,
    required this.lineColor,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (final points in lines) {
      if (points.isEmpty) continue;

      final firstPoint = _getMovedPoint(points[0], false);
      path.moveTo(firstPoint.dx, firstPoint.dy);

      for (int i = 0; i < points.length; i++) {
        final isLast = i == points.length - 1;
        final p1 = _getMovedPoint(points[i], !isLast);
        path.lineTo(p1.dx, p1.dy);

        if (isLast && i + 1 < points.length) {
          final p2 = _getMovedPoint(points[points.length - 1], !isLast);
          path.moveTo(p2.dx, p2.dy);
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  Offset _getMovedPoint(WavePoint point, bool withCursor) {
    final x = point.x + point.wave.dx + (withCursor ? point.cursor.dx : 0);
    final y = point.y + point.wave.dy + (withCursor ? point.cursor.dy : 0);
    return Offset((x * 10).round() / 10, (y * 10).round() / 10);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Waves extends StatefulWidget {
  final Color lineColor;
  final Color backgroundColor;
  final double waveSpeedX;
  final double waveSpeedY;
  final double waveAmpX;
  final double waveAmpY;
  final double friction;
  final double tension;
  final double maxCursorMove;
  final double xGap;
  final double yGap;

  const Waves({
    Key? key,
    this.lineColor = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.waveSpeedX = 0.0125,
    this.waveSpeedY = 0.005,
    this.waveAmpX = 32,
    this.waveAmpY = 16,
    this.friction = 0.925,
    this.tension = 0.005,
    this.maxCursorMove = 100,
    this.xGap = 10,
    this.yGap = 32,
  }) : super(key: key);

  @override
  State<Waves> createState() => _WavesState();
}

class _WavesState extends State<Waves> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late NoiseGenerator _noise;
  List<List<WavePoint>> _lines = [];
  final MouseState _mouse = MouseState();
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _noise = NoiseGenerator(math.Random().nextDouble());
    _animationController = AnimationController(
      duration: const Duration(days: 1),
      vsync: this,
    )..repeat();

    _animationController.addListener(_updateAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    if (_size != Size.zero) {
      _movePoints(_animationController.value * 1000000);
      setState(() {});
    }
  }

  void _initializeLines(Size size) {
    _size = size;
    _lines.clear();

    final oWidth = size.width + 200;
    final oHeight = size.height + 30;

    final totalLines = (oWidth / widget.xGap).ceil();
    final totalPoints = (oHeight / widget.yGap).ceil();

    final xStart = (size.width - widget.xGap * totalLines) / 2;
    final yStart = (size.height - widget.yGap * totalPoints) / 2;

    for (int i = 0; i <= totalLines; i++) {
      final points = <WavePoint>[];
      for (int j = 0; j <= totalPoints; j++) {
        points.add(WavePoint(
          xStart + widget.xGap * i,
          yStart + widget.yGap * j,
        ));
      }
      _lines.add(points);
    }
  }

  void _movePoints(double time) {
    for (final points in _lines) {
      for (final p in points) {
        // Wave movement
        final move = _noise.perlin2(
              (p.x + time * widget.waveSpeedX) * 0.002,
              (p.y + time * widget.waveSpeedY) * 0.0015,
            ) *
            12;

        p.wave = Offset(
          math.cos(move) * widget.waveAmpX,
          math.sin(move) * widget.waveAmpY,
        );

        // Mouse interaction
        final dx = p.x - _mouse.sx;
        final dy = p.y - _mouse.sy;
        final dist = math.sqrt(dx * dx + dy * dy);
        final l = math.max(250, _mouse.vs);

        if (dist < l) {
          final s = 1 - dist / l;
          final f = math.cos(dist * 0.001) * s;
          p.cursorVelocity = Offset(
            p.cursorVelocity.dx +
                math.cos(_mouse.a) * f * l * _mouse.vs * 0.002,
            p.cursorVelocity.dy +
                math.sin(_mouse.a) * f * l * _mouse.vs * 0.002,
          );
        }

        // Spring physics
        p.cursorVelocity = Offset(
          p.cursorVelocity.dx + (0 - p.cursor.dx) * widget.tension,
          p.cursorVelocity.dy + (0 - p.cursor.dy) * widget.tension,
        );

        p.cursorVelocity = Offset(
          p.cursorVelocity.dx * widget.friction,
          p.cursorVelocity.dy * widget.friction,
        );

        p.cursor = Offset(
          p.cursor.dx + p.cursorVelocity.dx * 2,
          p.cursor.dy + p.cursorVelocity.dy * 2,
        );

        // Clamp cursor movement
        p.cursor = Offset(
          p.cursor.dx.clamp(-widget.maxCursorMove, widget.maxCursorMove),
          p.cursor.dy.clamp(-widget.maxCursorMove, widget.maxCursorMove),
        );
      }
    }
  }

  void _updateMouse(Offset position) {
    _mouse.x = position.dx;
    _mouse.y = position.dy;

    if (!_mouse.set) {
      _mouse.sx = _mouse.x;
      _mouse.sy = _mouse.y;
      _mouse.lx = _mouse.x;
      _mouse.ly = _mouse.y;
      _mouse.set = true;
    }

    // Update mouse physics
    _mouse.sx += (_mouse.x - _mouse.sx) * 0.3;
    _mouse.sy += (_mouse.y - _mouse.sy) * 0.3;

    final dx = _mouse.x - _mouse.lx;
    final dy = _mouse.y - _mouse.ly;
    final d = math.sqrt(dx * dx + dy * dy);

    _mouse.v = d;
    _mouse.vs += (d - _mouse.vs) * 0.1;
    _mouse.vs = math.min(100, _mouse.vs);

    _mouse.lx = _mouse.x;
    _mouse.ly = _mouse.y;
    _mouse.a = math.atan2(dy, dx);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (_size != size) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeLines(size);
            });
          }

          return GestureDetector(
            onPanUpdate: (details) => _updateMouse(details.localPosition),
            onTapDown: (details) => _updateMouse(details.localPosition),
            child: MouseRegion(
              onHover: (event) => _updateMouse(event.localPosition),
              child: CustomPaint(
                painter: WavesPainter(
                  lines: _lines,
                  lineColor: widget.lineColor,
                  time: _animationController.value,
                ),
                size: size,
              ),
            ),
          );
        },
      ),
    );
  }
}
