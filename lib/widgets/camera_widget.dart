import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraWidget extends StatelessWidget {
  const CameraWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080808),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF1E1E1E)),
      ),
      child: Stack(children: [
        Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, color: const Color(0xFF1A1A1A), size: 52),
            const SizedBox(height: 8),
            Text('RTSP :8554', style: GoogleFonts.rajdhani(
              color: const Color(0xFF2A2A2A), fontSize: 12, letterSpacing: 2)),
          ],
        )),
        Positioned(top: 10, left: 10, child: _Corner(true, true)),
        Positioned(top: 10, right: 10, child: _Corner(true, false)),
        Positioned(bottom: 10, left: 10, child: _Corner(false, true)),
        Positioned(bottom: 10, right: 10, child: _Corner(false, false)),
        Positioned(top: 10, left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            color: Colors.transparent,
            child: Text('RÜCKFAHRKAMERA', style: GoogleFonts.rajdhani(
              color: const Color(0xFF1C69D4), fontSize: 9,
              fontWeight: FontWeight.w600, letterSpacing: 2)),
          )),
      ]),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool top, left;
  const _Corner(this.top, this.left);
  @override
  Widget build(BuildContext context) =>
    SizedBox(width: 16, height: 16,
      child: CustomPaint(painter: _CornerP(top, left)));
}

class _CornerP extends CustomPainter {
  final bool top, left;
  _CornerP(this.top, this.left);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = const Color(0xFF1C69D4)
      ..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final path = Path();
    if (top && left)        { path.moveTo(0,s.height);path.lineTo(0,0);path.lineTo(s.width,0); }
    else if (top && !left)  { path.moveTo(0,0);path.lineTo(s.width,0);path.lineTo(s.width,s.height); }
    else if (!top && left)  { path.moveTo(0,0);path.lineTo(0,s.height);path.lineTo(s.width,s.height); }
    else                    { path.moveTo(0,s.height);path.lineTo(s.width,s.height);path.lineTo(s.width,0); }
    canvas.drawPath(path, p);
  }
  @override bool shouldRepaint(_) => false;
}
