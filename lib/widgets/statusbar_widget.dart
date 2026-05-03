import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/mock_service.dart';

class StatusBarWidget extends StatelessWidget {
  final SensorData data;
  const StatusBarWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<MockSensorService>();
    return Container(
      height: 34,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(bottom: BorderSide(color: Color(0xFF1C69D4), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Text('SMART TRAILER V4', style: GoogleFonts.rajdhani(
          color: Colors.white, fontSize: 14,
          fontWeight: FontWeight.w700, letterSpacing: 3)),
        const Spacer(),
        GestureDetector(
          onTap: () {
            if (svc.liveMode) { svc.disableLiveMode(); }
            else { svc.enableLiveMode(); }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: svc.liveMode ? Colors.green : const Color(0xFF555555), width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(children: [
              Container(width: 5, height: 5,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: svc.liveMode ? Colors.green : const Color(0xFF555555))),
              const SizedBox(width: 5),
              Text(svc.liveMode ? 'LIVE' : 'DEMO',
                style: GoogleFonts.rajdhani(
                  color: svc.liveMode ? Colors.green : const Color(0xFF555555),
                  fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
            ]),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(
              color: data.connected ? const Color(0xFF1C69D4) : Colors.red, width: 1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(children: [
            Container(width: 5, height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: data.connected ? const Color(0xFF1C69D4) : Colors.red)),
            const SizedBox(width: 5),
            Text(data.connected ? 'VERBUNDEN' : 'GETRENNT',
              style: GoogleFonts.rajdhani(
                color: data.connected ? const Color(0xFF1C69D4) : Colors.red,
                fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          ]),
        ),
      ]),
    );
  }
}
