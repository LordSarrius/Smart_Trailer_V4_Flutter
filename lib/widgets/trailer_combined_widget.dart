import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../services/mock_service.dart';
import '../services/beep_service.dart';

Color _tireColor(double p, double t) {
  if (p < 1.8 || p > 3.2 || t > 85) return const Color(0xFFCC0000);
  if (p < 2.1 || p > 2.9 || t > 65) return const Color(0xFFE96B0C);
  return const Color(0xFF00A550);
}
bool _isCritical(double p, double t) => p < 1.8 || p > 3.2 || t > 85;
Color _distColor(double cm) {
  if (cm < 20)  return const Color(0xFFCC0000);   // rot
  if (cm < 40)  return const Color(0xFFE63900);   // dunkelorange
  if (cm < 60)  return const Color(0xFFFF7700);   // orange
  if (cm < 100) return const Color(0xFFFFCC00);   // gelb
  return        const Color(0xFF00A550);           // grün
}

class TrailerCombinedWidget extends StatefulWidget {
  final SensorData data;
  const TrailerCombinedWidget({super.key, required this.data});
  @override
  State<TrailerCombinedWidget> createState() => _State();
}

class _State extends State<TrailerCombinedWidget> {
  final _beep = BeepService();
  @override void initState() { super.initState(); _beep.init(); }
  @override void didUpdateWidget(TrailerCombinedWidget old) {
    super.didUpdateWidget(old);
    final minCm = math.min(widget.data.ultraS1, widget.data.ultraS2) / 10;
    _beep.update(widget.data.gpsSpeed > 15.0 ? 999.0 : minCm);
  }
  @override void dispose() { _beep.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return GestureDetector(
      onTap: () => _beep.unlockAudio(),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF1E1E1E)),
        ),
        child: LayoutBuilder(builder: (ctx, c) {
          final w = c.maxWidth, h = c.maxHeight;

          // ── Trailer: smaller, more top room for deichsel ──
          final tW = w * 0.33,  tH = h * 0.43;
          final tL = (w - tW) / 2;
          final tT = h * 0.13;   // generous top margin
          final tR = tL + tW,    tB = tT + tH;

          // Tire dims
          final trW = w * 0.052, trH = h * 0.095;
          final axF = tT + tH * 0.27;
          final axR = tT + tH * 0.73;

          // Fan origins at trailer rear corners
          final fLX = tL, fRX = tR;
          final fOriginY = tB;
          final fMaxR = (h - tB - h * 0.02) * 0.60;

          final s1cm = d.ultraS1 / 10;
          final s2cm = d.ultraS2 / 10;
          final flC = _tireColor(d.tpmsFL_p, d.tpmsFL_t);
          final frC = _tireColor(d.tpmsFR_p, d.tpmsFR_t);
          final rlC = _tireColor(d.tpmsRL_p, d.tpmsRL_t);
          final rrC = _tireColor(d.tpmsRR_p, d.tpmsRR_t);

          // Reifen-Details für Warnung
          String _tireDetail(String pos, double p, double t) {
            final r = <String>[];
            if (p < 1.8 || p > 3.2) r.add('DRUCK ${p.toStringAsFixed(1)} bar');
            if (t > 85)              r.add('TEMP  ${t.toStringAsFixed(0)}°C');
            return '$pos   ${r.join('   ')}';
          }
          final criticals = <String>[];
          if (_isCritical(d.tpmsFL_p, d.tpmsFL_t)) criticals.add(_tireDetail('VL', d.tpmsFL_p, d.tpmsFL_t));
          if (_isCritical(d.tpmsFR_p, d.tpmsFR_t)) criticals.add(_tireDetail('VR', d.tpmsFR_p, d.tpmsFR_t));
          if (_isCritical(d.tpmsRL_p, d.tpmsRL_t)) criticals.add(_tireDetail('HL', d.tpmsRL_p, d.tpmsRL_t));
          if (_isCritical(d.tpmsRR_p, d.tpmsRR_t)) criticals.add(_tireDetail('HR', d.tpmsRR_p, d.tpmsRR_t));

          return Stack(children: [
            SizedBox.expand(child: CustomPaint(
              painter: _TrailerPainter(
                tL: tL, tT: tT, tW: tW, tH: tH,
                trW: trW, trH: trH, axF: axF, axR: axR,
                fLX: fLX, fRX: fRX, fOriginY: fOriginY, fMaxR: fMaxR,
                s1cm: s1cm, s2cm: s2cm,
                flC: flC, frC: frC, rlC: rlC, rrC: rrC,
              ),
            )),

            // Tire labels – außen neben den Reifen
            Positioned(left: tL - trW - 58, top: axF - trH / 2,
              child: _TireLabel('VL', d.tpmsFL_p, d.tpmsFL_t, flC, true)),
            Positioned(left: tR + trW + 5, top: axF - trH / 2,
              child: _TireLabel('VR', d.tpmsFR_p, d.tpmsFR_t, frC, false)),
            Positioned(left: tL - trW - 58, top: axR - trH / 2,
              child: _TireLabel('HL', d.tpmsRL_p, d.tpmsRL_t, rlC, true)),
            Positioned(left: tR + trW + 5, top: axR - trH / 2,
              child: _TireLabel('HR', d.tpmsRR_p, d.tpmsRR_t, rrC, false)),

            // Distanzlabel RECHTS vom linken Sensor (zwischen Anhänger und Linksrand)
            Positioned(
              right: w - fLX - 80,   // weit links außerhalb des Fächers
              top: fOriginY + 6,
              child: _SensorLabel('S1', s1cm),
            ),
            // Distanzlabel LINKS vom rechten Sensor
            Positioned(
              left: fRX - 58,        // weit rechts außerhalb des Fächers
              top: fOriginY + 6,
              child: _SensorLabel('       S2', s2cm),
            ),

            // Neigungs-Warnung (oben)
            if (d.inclination.abs() > 8)
              Positioned(
                left: tL + 4, right: w - tR + 4,
                top: tT + tH * 0.35,
                child: _NeigungsWarning(d.inclination),
              ),

            // Reifen-Warnung (darunter)
            if (criticals.isNotEmpty)
              Positioned(
                left: tL + 4, right: w - tR + 4,
                top: tT + tH * 0.35 + (d.inclination.abs() > 8 ? 24 : 0),
                child: _WarningBadge(criticals),
              ),

            Positioned(bottom: 2, left: 0, right: 0,
              child: Text('Tippen → Ton aktivieren',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFF1E1E1E), fontSize: 7))),
            // ── Bottom info panel ─────────────────────────────────────
            Builder(builder: (ctx) {
              final fanBottom = fOriginY + (h - tB - h * 0.02) * 0.60;
              final panelTop = fanBottom + 6;
              final panelH = h - panelTop - 4;
              if (panelH < 30) return const SizedBox.shrink();
              return Positioned(
                left: 4, right: 4,
                top: panelTop,
                height: panelH,
                child: Row(children: [
                  Expanded(flex: 60,
                    child: _InclinationPanel(inclination: d.inclination)),
                  Container(width: 1, color: const Color(0xFF1E1E1E)),
                  Expanded(flex: 40,
                    child: _GpsPanel(data: d)),
                ]),
              );
            }),            
          ]);
        }),
      ),
    );
  }
}

// ── Sensor distance label ─────────────────────────────────────
class _SensorLabel extends StatelessWidget {
  final String id;
  final double cm;
  const _SensorLabel(this.id, this.cm);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(id, style: GoogleFonts.rajdhani(
          color: const Color(0xFF555555), fontSize: 12,
          letterSpacing: 2, fontWeight: FontWeight.w600)),
        SizedBox(
          width: 76,
          child: Text('${cm.toStringAsFixed(0)} cm',
            style: GoogleFonts.rajdhani(
              color: _distColor(cm),   // ← nutzt jetzt _distColor direkt
              fontSize: 18, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ── Warning Badge ─────────────────────────────────────────────
class _WarningBadge extends StatelessWidget {
  final List<String> tires;
  const _WarningBadge(this.tires);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0000),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFCC0000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titelzeile
          Row(children: [
                        Padding(
              padding: const EdgeInsets.only(left: 30),
              child: const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFCC0000), size: 20),
            ),
            const SizedBox(width: 4),
            Text('REIFEN KRITISCH', style: GoogleFonts.rajdhani(
              color: const Color(0xFFCC0000), fontSize: 15,
              fontWeight: FontWeight.w700, letterSpacing: 1)),
          ]),
          // Eine Zeile pro Reifen
          ...tires.map((line) => Padding(
            padding: const EdgeInsets.only(left: 15, top: 1),
            child: Text(line, style: GoogleFonts.rajdhani(
              color: const Color(0xFFFF4444), fontSize: 14,
              fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          )),
        ],
      ),
    );
  }
}

// ── Tire label ────────────────────────────────────────────────
class _TireLabel extends StatelessWidget {
  final String pos;
  final double p, t;
  final Color color;
  final bool alignRight;
  const _TireLabel(this.pos, this.p, this.t, this.color, this.alignRight);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('BAR', style: GoogleFonts.rajdhani(
          color: const Color(0xFF555555), fontSize: 15, letterSpacing: 1.5)),
        Text(p.toStringAsFixed(1), style: GoogleFonts.rajdhani(
          color: color, fontSize: 19, fontWeight: FontWeight.w700, height: 1.0)),
        Text('°C', style: GoogleFonts.rajdhani(
          color: const Color(0xFF555555), fontSize: 15, letterSpacing: 1.5)),
        Text(t.toStringAsFixed(0), style: GoogleFonts.rajdhani(
          color: color, fontSize: 15, fontWeight: FontWeight.w600, height: 1.0)),
      ],
    );
  }
}

// ── CustomPainter ─────────────────────────────────────────────
class _TrailerPainter extends CustomPainter {
  final double tL, tT, tW, tH, trW, trH, axF, axR;
  final double fLX, fRX, fOriginY, fMaxR;
  final double s1cm, s2cm;
  final Color flC, frC, rlC, rrC;

  const _TrailerPainter({
    required this.tL, required this.tT, required this.tW, required this.tH,
    required this.trW, required this.trH, required this.axF, required this.axR,
    required this.fLX, required this.fRX, required this.fOriginY, required this.fMaxR,
    required this.s1cm, required this.s2cm,
    required this.flC, required this.frC, required this.rlC, required this.rrC,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tR = tL + tW, tB = tT + tH;
    final fillP = Paint()..color = const Color(0xFF1C69D4).withOpacity(0.07)
      ..style = PaintingStyle.fill;
    final borderP = Paint()..color = const Color(0xFF1C69D4).withOpacity(0.30)
      ..style = PaintingStyle.stroke..strokeWidth = 1;

    // Body
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(tL, tT, tW, tH), const Radius.circular(4)), fillP);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(tL, tT, tW, tH), const Radius.circular(4)), borderP);

    // ── Deichsel: A-Rahmen realistisch ──
    final cx = tL + tW * 0.5;
    final coupleY = tT - tH * 0.16;  // weiter oben = mehr Platz
    final armP = Paint()
      ..color = const Color(0xFF1C69D4).withOpacity(0.40)
      ..style = PaintingStyle.stroke..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    // A-Arme
    canvas.drawLine(Offset(cx, coupleY), Offset(tL + tW * 0.20, tT), armP);
    canvas.drawLine(Offset(cx, coupleY), Offset(tR - tW * 0.20, tT), armP);
    // Querstrebe (realistisch: 1/3 der Armlänge vom Anhänger)
    final braceY = coupleY + (tT - coupleY) * 0.60;
    final bw = tW * 0.18;
    final braceP = Paint()..color = const Color(0xFF1C69D4).withOpacity(0.25)
      ..style = PaintingStyle.stroke..strokeWidth = 1.2;
    canvas.drawLine(Offset(cx - bw, braceY), Offset(cx + bw, braceY), braceP);
    // Kugelkopf
    canvas.drawCircle(Offset(cx, coupleY), 3.5,
      Paint()..color = const Color(0xFF1C69D4).withOpacity(0.55)
        ..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, coupleY), 3.5,
      Paint()..color = const Color(0xFF1C69D4).withOpacity(0.80)
        ..style = PaintingStyle.stroke..strokeWidth = 0.8);

    // Axles
    final axleP = Paint()..color = const Color(0xFF1C69D4).withOpacity(0.18)..strokeWidth = 1;
    canvas.drawLine(Offset(tL, axF), Offset(tR, axF), axleP);
    canvas.drawLine(Offset(tL, axR), Offset(tR, axR), axleP);

    // Rear light strip (red)
    final lp = Paint()..color = const Color(0xFF550000)..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(tL + 3, tB - 1.5), Offset(tL + tW * 0.28, tB - 1.5), lp);
    canvas.drawLine(Offset(tR - 3, tB - 1.5), Offset(tR - tW * 0.28, tB - 1.5), lp);

    // Tires (direkt am Anhänger)
    _tire(canvas, tL - trW, axF - trH / 2, trW, trH, flC, 'VL');
    _tire(canvas, tR,       axF - trH / 2, trW, trH, frC, 'VR');
    _tire(canvas, tL - trW, axR - trH / 2, trW, trH, rlC, 'HL');
    _tire(canvas, tR,       axR - trH / 2, trW, trH, rrC, 'HR');

    // Fans
    _fan(canvas, fLX, fOriginY, fMaxR, s1cm, isLeft: true);
    _fan(canvas, fRX, fOriginY, fMaxR, s2cm, isLeft: false);
  }

  void _tire(Canvas canvas, double x, double y, double w, double h,
      Color c, String label) {
    final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(4));
    canvas.drawRRect(r, Paint()..color = c.withOpacity(0.12)..style = PaintingStyle.fill);
    canvas.drawRRect(r, Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = 1.5);
    final cx = x + w / 2, cy = y + h / 2;
    final r2 = math.min(w, h) * 0.32;
    canvas.drawCircle(Offset(cx, cy), r2,
      Paint()..color = c..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), r2,
      Paint()..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.stroke..strokeWidth = 0.8);
    final tp = TextPainter(
      text: TextSpan(text: label,
        style: TextStyle(color: Colors.white, fontSize: r2 * 0.88, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _fan(Canvas canvas, double cx, double originY, double maxR,
      double distCm, {required bool isLeft}) {
    const half = math.pi * 0.10;
    final centerA = isLeft
      ? math.pi * 0.5 + math.pi * 0.10
      : math.pi * 0.5 - math.pi * 0.10;
    final startA = centerA - half;

    // Background fan
    canvas.drawPath(
      Path()
        ..moveTo(cx, originY)
        ..arcTo(Rect.fromCircle(center: Offset(cx, originY), radius: maxR),
            startA, half * 2, false)
        ..close(),
      Paint()..color = const Color(0xFF191919)..style = PaintingStyle.fill);

    // Scale rings at 50 / 100 / 150 cm
    final sp = Paint()..color = Colors.white10
      ..style = PaintingStyle.stroke..strokeWidth = 0.5;
    for (final d in [50.0, 100.0, 150.0]) {
      final r = maxR * (d / 150.0);
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, originY), radius: r),
          startA, half * 2, false, sp);
    }

    // ── Aktiver Fächer: KORREKTE Logik ──────────────────────
    // Objekt weit weg (150cm) → Fächer voll / grün
    // Objekt nah (0cm)        → Fächer leer / winzig
    // Kein Objekt (>150cm)    → nichts anzeigen
    if (distCm >= 150.0) return;

    final fraction = (distCm / 150.0).clamp(0.0, 1.0);
    if (fraction < 0.01) return;

    final c = _distColor(distCm);
    final r = maxR * fraction;

    for (int i = 3; i >= 1; i--) {
      final ri = r * i / 3;
      final alpha = (fraction * 210 * i / 3).clamp(20, 210).toInt();
      canvas.drawPath(
        Path()
          ..moveTo(cx, originY)
          ..arcTo(Rect.fromCircle(center: Offset(cx, originY), radius: ri),
              startA, half * 2, false)
          ..close(),
        Paint()..color = c.withAlpha(alpha ~/ i)..style = PaintingStyle.fill);
    }
    canvas.drawPath(
      Path()
        ..moveTo(cx, originY)
        ..arcTo(Rect.fromCircle(center: Offset(cx, originY), radius: r),
            startA, half * 2, false)
        ..close(),
      Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_TrailerPainter o) =>
    o.s1cm != s1cm || o.s2cm != s2cm ||
    o.flC != flC || o.frC != frC || o.rlC != rlC || o.rrC != rrC;
}

// ── Neigungsanzeige ───────────────────────────────────────────
class _InclinationPanel extends StatelessWidget {
  final double inclination;
  const _InclinationPanel({required this.inclination});

  @override
  Widget build(BuildContext context) {
    final color = inclination.abs() > 8
      ? const Color(0xFFCC0000)
      : inclination.abs() > 4
        ? const Color(0xFFE96B0C)
        : const Color(0xFF00A550);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NEIGUNG', style: GoogleFonts.rajdhani(
            color: const Color(0xFF444444), fontSize: 15, letterSpacing: 2)),
          Expanded(
            child: Row(children: [
              // Grafik
              Expanded(
                child: CustomPaint(
                  painter: _InclinationPainter(
                    inclination: inclination, color: color),
                ),
              ),
              const SizedBox(width: 6),
              // Zahl
              Text('${inclination.toStringAsFixed(1)}°',
                style: GoogleFonts.rajdhani(
                  color: color, fontSize: 22,
                  fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _InclinationPainter extends CustomPainter {
  final double inclination;
  final Color color;
  const _InclinationPainter({required this.inclination, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;

    // Referenzlinie (Horizont)
    final refP = Paint()..color = const Color(0xFF333333)
      ..strokeWidth = 1..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(4, cy), Offset(size.width - 4, cy), refP);

    // Winkelmarkierungen
    final tickP = Paint()..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 0.5;
    for (final deg in [-8.0, -4.0, 4.0, 8.0]) {
      final tickY = cy - (deg / 12.0) * (size.height * 0.4);
      canvas.drawLine(Offset(cx - 6, tickY), Offset(cx + 6, tickY), tickP);
    }

    // Anhänger-Silhouette (rotiert)
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-inclination * math.pi / 180);

    final tW = size.width * 0.62, tH = size.height * 0.28;
    final trailerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: tW, height: tH),
      const Radius.circular(2));
    canvas.drawRRect(trailerRect,
      Paint()..color = color.withOpacity(0.12)..style = PaintingStyle.fill);
    canvas.drawRRect(trailerRect,
      Paint()..color = color.withOpacity(0.70)
        ..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Räder
    final wR = tH * 0.55;
    for (final wx in [-tW * 0.28, tW * 0.28]) {
      canvas.drawCircle(Offset(wx, tH / 2),  wR,
        Paint()..color = color.withOpacity(0.50)
          ..style = PaintingStyle.stroke..strokeWidth = 1.2);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InclinationPainter o) => o.inclination != inclination;
}

// ── GPS Panel ─────────────────────────────────────────────────
class _GpsPanel extends StatelessWidget {
  final SensorData data;
  const _GpsPanel({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('GPS', style: GoogleFonts.rajdhani(
            color: const Color(0xFF444444), fontSize: 15, letterSpacing: 2)),
          _gpsRow('LAT', '${data.gpsLat.toStringAsFixed(4)}° N'),
          _gpsRow('LON', '${data.gpsLon.toStringAsFixed(4)}° E'),
          Row(children: [
            Text('${data.gpsSpeed.toStringAsFixed(1)}',
              style: GoogleFonts.rajdhani(color: const Color(0xFF1C69D4),
                fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(width: 3),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('km/h', style: GoogleFonts.rajdhani(
                color: const Color(0xFF555555), fontSize: 10)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _gpsRow(String label, String val) {
    return Row(children: [
      SizedBox(width: 28, child: Text(label, style: GoogleFonts.rajdhani(
        color: const Color(0xFF444444), fontSize: 9, letterSpacing: 1.5))),
      Text(val, style: GoogleFonts.rajdhani(
        color: const Color(0xFF888888), fontSize: 11,
        fontWeight: FontWeight.w600)),
    ]);
  }
}

class _NeigungsWarning extends StatelessWidget {
  final double incl;
  const _NeigungsWarning(this.incl);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0008),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFCC0000)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.explore, color: Color(0xFFCC0000), size: 11),
        const SizedBox(width: 4),
        Text('NEIGUNG KRITISCH  ${incl.toStringAsFixed(1)}°',
          style: GoogleFonts.rajdhani(color: const Color(0xFFCC0000),
            fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1)),
      ]),
    );
  }
}