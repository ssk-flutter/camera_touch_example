import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'global.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController cameraController;
  Offset? _tapPosition;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.max,
    );
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    _timer?.cancel(); // 타이머가 있을 경우 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Camera Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              CameraPreview(
                cameraController,
                child: LayoutBuilder(
                  builder: (context, constraints) => GestureDetector(
                    onTapDown: (details) {
                      final offset = Offset(
                        details.localPosition.dx / constraints.maxWidth,
                        details.localPosition.dy / constraints.maxHeight,
                      );
                      cameraController.setExposurePoint(offset);
                      cameraController.setFocusPoint(offset);

                      setState(() {
                        _tapPosition = details.localPosition;
                      });

                      // 3초 뒤에 동그라미를 사라지게 함
                      _timer?.cancel(); // 이전 타이머 취소
                      _timer = Timer(Duration(seconds: 3), () {
                        setState(() {
                          _tapPosition = null;
                        });
                      });
                    },
                  ),
                ),
              ),
              if (_tapPosition != null)
                CustomPaint(
                  painter: CirclePainter(_tapPosition!),
                  child: Container(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Offset position;

  CirclePainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(position, 20, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
