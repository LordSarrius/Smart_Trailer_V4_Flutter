import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mock_service.dart';

class StatusBarWidget extends StatelessWidget {
  final SensorData data;
  const StatusBarWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(bottom: BorderSide(color: Color(0xFF1C69D4), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        // Titel
        Text('SMART TRAILER', style: GoogleFonts.rajdhani(
          color: Colors.white, fontSize: 14,
          fontWeight: FontWeight.w700, letterSpacing: 3)),
        const Spacer(),
        // Verbindung
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF1C69D4), width: 1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(children: [
            Container(width: 5, height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFF1C69D4))),
            const SizedBox(width: 5),
            Text('VERBUNDEN', style: GoogleFonts.rajdhani(
              color: const Color(0xFF1C69D4), fontSize: 9,
              fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          ]),
        ),
      ]),
    );
  }
}