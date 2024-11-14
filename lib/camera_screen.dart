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
  double _circleOpacity = 1.0;

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
                        _circleOpacity = 1.0; // 초기 불투명도 설정
                      });

                      // 3초 동안 점차 사라지게 설정
                      _timer?.cancel(); // 이전 타이머 취소
                      _timer = Timer(Duration(seconds: 3), () {
                        setState(() {
                          _tapPosition = null;
                        });
                      });

                      // 애니메이션을 통해 서서히 사라짐
                      Future.delayed(Duration(milliseconds: 500), () {
                        setState(() {
                          _circleOpacity = 0.0;
                        });
                      });
                    },
                  ),
                ),
              ),
              if (_tapPosition != null)
                AnimatedOpacity(
                  opacity: _circleOpacity,
                  duration: Duration(seconds: 3), // 애니메이션 지속 시간
                  child: CustomPaint(
                    painter: CirclePainter(_tapPosition!),
                    child: Container(),
                  ),
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
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 20, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
