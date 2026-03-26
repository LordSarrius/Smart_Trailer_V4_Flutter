import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_service.dart';
import '../widgets/camera_widget.dart';
import '../widgets/trailer_combined_widget.dart';
import '../widgets/statusbar_widget.dart';
import '../widgets/debug_panel_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardScreen> {
  bool _debugOpen = false;

  void _toggleDebug() {
    final svc = context.read<MockSensorService>();
    setState(() { _debugOpen = !_debugOpen; });
    svc.setDebugMode(_debugOpen);
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MockSensorService>().data;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Column(children: [
        // ── Statusbar + DEBUG button ──────────────────────────
        Stack(children: [
          StatusBarWidget(data: data),
          Positioned(left: 0, right: 0, top: 0, bottom: 0,
            child: Center(
              child: DebugPanelButton(
                isOpen: _debugOpen, onToggle: _toggleDebug),
            )),
        ]),

        // ── Main content ──────────────────────────────────────
        Expanded(child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Row(children: [
            Expanded(
              flex: 60,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraWidget(),
                  if (_debugOpen)
                    const DebugOverlayPanel(),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(flex: 40, child: TrailerCombinedWidget(data: data)),
          ]),
        )),
      ]),
    );
  }
}
