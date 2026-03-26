import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/mock_service.dart';

class DebugPanelButton extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  const DebugPanelButton({super.key, required this.isOpen, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isOpen ? const Color(0xFFE96B0C) : const Color(0xFF111111),
          border: Border.all(
            color: isOpen ? const Color(0xFFE96B0C) : const Color(0xFF333333)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text('DEBUG', style: GoogleFonts.rajdhani(
          color: Colors.white, fontSize: 15,
          fontWeight: FontWeight.w700, letterSpacing: 2)),
      ),
    );
  }
}

class DebugOverlayPanel extends StatelessWidget {
  const DebugOverlayPanel({super.key});

  Color _inclColor(double v) {
    if (v.abs() > 8) return const Color(0xFFCC0000);
    if (v.abs() > 4) return const Color(0xFFE96B0C);
    return const Color(0xFF00A550);
  }

  SliderThemeData _theme(BuildContext ctx, {Color? active}) =>
    SliderTheme.of(ctx).copyWith(
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      activeTrackColor: active ?? const Color(0xFFE96B0C),
      inactiveTrackColor: const Color(0xFF252525),
      thumbColor: active ?? const Color(0xFFE96B0C),
      overlayShape: SliderComponentShape.noOverlay,
    );

  Widget _sectionHeader(String t) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 2),
    child: Row(children: [
      Container(width: 2, height: 10,
        color: const Color(0xFF333333),
        margin: const EdgeInsets.only(right: 6)),
      Text(t, style: GoogleFonts.rajdhani(
        color: const Color(0xFF555555), fontSize: 15, letterSpacing: 2)),
    ]),
  );

  Widget _divider() => Container(
    height: 1, color: const Color(0xFF1A1A1A),
    margin: const EdgeInsets.symmetric(vertical: 6));

  Widget _sliderLine(BuildContext ctx, String label, double value,
      double min, double max, String display,
      ValueChanged<double> onChanged, {Color? trackColor}) {
    return Row(children: [
      SizedBox(width: 42, child: Text(label, style: GoogleFonts.rajdhani(
        color: const Color(0xFF555555), fontSize: 15, letterSpacing: 1))),
      Expanded(child: SliderTheme(
        data: _theme(ctx, active: trackColor),
        child: Slider(
          value: value.clamp(min, max),
          min: min, max: max, onChanged: onChanged),
      )),
      SizedBox(width: 52, child: Text(display,
        textAlign: TextAlign.right,
        style: GoogleFonts.rajdhani(
          color: trackColor ?? const Color(0xFFE96B0C),
          fontSize: 15, fontWeight: FontWeight.w700))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<MockSensorService>();

    return Align(
      alignment: Alignment.topLeft,
      child: FractionallySizedBox(
        widthFactor: 0.52,
        heightFactor: 1.0,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xEA0A0A0A),
            border: Border(right:
              BorderSide(color: Color(0xFF222222), width: 1)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ───────────────────────────────────
                Row(children: [
                  Container(width: 3, height: 13,
                    color: const Color(0xFFE96B0C),
                    margin: const EdgeInsets.only(right: 7)),
                  Text('DEBUG MODE', style: GoogleFonts.rajdhani(
                    color: const Color(0xFFE96B0C), fontSize: 15,
                    fontWeight: FontWeight.w700, letterSpacing: 2)),
                  const SizedBox(width: 8),
                  Text('Sim. pausiert', style: GoogleFonts.rajdhani(
                    color: const Color(0xFF333333), fontSize: 15)),
                ]),

                // ── VL ───────────────────────────────────────
                _sectionHeader('VL'),
                _sliderLine(context, 'DRUCK',
                  svc.dbgFL_p, 1.0, 4.0,
                  '${svc.dbgFL_p.toStringAsFixed(1)} bar',
                  (v) => svc.setDbg('FL_p', v)),
                _sliderLine(context, 'TEMP',
                  svc.dbgFL_t, 10, 100,
                  '${svc.dbgFL_t.toStringAsFixed(0)} °C',
                  (v) => svc.setDbg('FL_t', v)),

                _divider(),

                // ── VR ───────────────────────────────────────
                _sectionHeader('VR'),
                _sliderLine(context, 'DRUCK',
                  svc.dbgFR_p, 1.0, 4.0,
                  '${svc.dbgFR_p.toStringAsFixed(1)} bar',
                  (v) => svc.setDbg('FR_p', v)),
                _sliderLine(context, 'TEMP',
                  svc.dbgFR_t, 10, 100,
                  '${svc.dbgFR_t.toStringAsFixed(0)} °C',
                  (v) => svc.setDbg('FR_t', v)),

                _divider(),

                // ── HL ───────────────────────────────────────
                _sectionHeader('HL'),
                _sliderLine(context, 'DRUCK',
                  svc.dbgRL_p, 1.0, 4.0,
                  '${svc.dbgRL_p.toStringAsFixed(1)} bar',
                  (v) => svc.setDbg('RL_p', v)),
                _sliderLine(context, 'TEMP',
                  svc.dbgRL_t, 10, 100,
                  '${svc.dbgRL_t.toStringAsFixed(0)} °C',
                  (v) => svc.setDbg('RL_t', v)),

                _divider(),

                // ── HR ───────────────────────────────────────
                _sectionHeader('HR'),
                _sliderLine(context, 'DRUCK',
                  svc.dbgRR_p, 1.0, 4.0,
                  '${svc.dbgRR_p.toStringAsFixed(1)} bar',
                  (v) => svc.setDbg('RR_p', v)),
                _sliderLine(context, 'TEMP',
                  svc.dbgRR_t, 10, 100,
                  '${svc.dbgRR_t.toStringAsFixed(0)} °C',
                  (v) => svc.setDbg('RR_t', v)),

                _divider(),

                // ── ULTRASCHALL ──────────────────────────────
                _sectionHeader('ULTRASCHALL'),
                _sliderLine(context, 'DIST.',
                  svc.dbgDist, 0, 200,
                  '${svc.dbgDist.toStringAsFixed(0)} cm',
                  (v) => svc.setDbg('dist', v)),

                _divider(),

                // ── GESCHWINDIGKEIT ───────────────────────────
                _sectionHeader('GESCHWINDIGKEIT'),
                _sliderLine(context, 'km/h',
                  svc.dbgSpeed, 0, 40,
                  '${svc.dbgSpeed.toStringAsFixed(0)} km/h',
                  (v) => svc.setDbg('speed', v)),
                if (svc.dbgSpeed > 15)
                  Padding(
                    padding: const EdgeInsets.only(left: 42, top: 2),
                    child: Row(children: [
                      const Icon(Icons.volume_off,
                        color: Color(0xFF555555), size: 10),
                      const SizedBox(width: 4),
                      Text('Ton deaktiviert (> 15 km/h)',
                        style: GoogleFonts.rajdhani(
                          color: const Color(0xFF555555), fontSize: 15)),
                    ]),
                  ),

                _divider(),

                // ── NEIGUNG ───────────────────────────────────
                _sectionHeader('NEIGUNG'),
                _sliderLine(context, '°',
                  svc.dbgInclination, -15, 15,
                  '${svc.dbgInclination.toStringAsFixed(1)}°',
                  (v) => svc.setDbg('incl', v),
                  trackColor: _inclColor(svc.dbgInclination)),

              ],
            ),
          ),
        ),
      ),
    );
  }
}