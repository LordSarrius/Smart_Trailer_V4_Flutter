import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});
  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late final Player _player;
  late final VideoController _videoController;
  bool _isConnected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);

    _player.stream.playing.listen((playing) {
      if (mounted) setState(() { _isConnected = playing; _isLoading = false; });
    });
    _player.stream.buffering.listen((buffering) {
      if (mounted) setState(() => _isLoading = buffering);
    });
    _player.open(Media('rtsp://192.168.178.192:8554/stream'));
  }

  @override
  void dispose() { _player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080808),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF1E1E1E)),
      ),
      child: Stack(children: [
        if (_isConnected)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Video(controller: _videoController, controls: NoVideoControls),
          )
        else
          Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const SizedBox(width: 32, height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1C69D4)))
              else
                const Icon(Icons.videocam_off, color: Color(0xFF1A1A1A), size: 52),
              const SizedBox(height: 8),
              Text(_isLoading ? 'VERBINDE...' : 'KEIN SIGNAL',
                style: GoogleFonts.rajdhani(color: const Color(0xFF2A2A2A), fontSize: 12, letterSpacing: 2)),
            ],
          )),
        Positioned(top: 10, left: 10, child: _Corner(true, true)),
        Positioned(top: 10, right: 10, child: _Corner(true, false)),
        Positioned(bottom: 10, left: 10, child: _Corner(false, true)),
        Positioned(bottom: 10, right: 10, child: _Corner(false, false)),
        Positioned(top: 10, left: 12,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 6, height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: _isConnected ? Colors.green : Colors.red)),
            const SizedBox(width: 6),
            Text('RUECKFAHRKAMERA', style: GoogleFonts.rajdhani(
              color: const Color(0xFF1C69D4), fontSize: 9,
              fontWeight: FontWeight.w600, letterSpacing: 2)),
          ])),
      ]),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool top, left;
  const _Corner(this.top, this.left);
  @override
  Widget build(BuildContext context) =>
    SizedBox(width: 16, height: 16, child: CustomPaint(painter: _CornerP(top, left)));
}

class _CornerP extends CustomPainter {
  final bool top, left;
  _CornerP(this.top, this.left);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = const Color(0xFF1C69D4)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final path = Path();
    if (top && left) { path.moveTo(0,s.height);path.lineTo(0,0);path.lineTo(s.width,0); }
    else if (top && !left) { path.moveTo(0,0);path.lineTo(s.width,0);path.lineTo(s.width,s.height); }
    else if (!top && left) { path.moveTo(0,0);path.lineTo(0,s.height);path.lineTo(s.width,s.height); }
    else { path.moveTo(0,s.height);path.lineTo(s.width,s.height);path.lineTo(s.width,0); }
    canvas.drawPath(path, p);
  }
  @override
  bool shouldRepaint(_) => false;
}
