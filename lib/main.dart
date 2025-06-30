import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'waves.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Waves Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WavesDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WavesDemo extends StatelessWidget {
  const WavesDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Enable edge-to-edge display
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Waves background - optimized for mobile
          const Positioned.fill(
            child: Waves(
              lineColor: Colors.white,
              backgroundColor: Color.fromRGBO(255, 255, 255, 0.1),
              waveSpeedX: 0.025, // Slightly faster for mobile
              waveSpeedY: 0.015, // Slightly faster for mobile
              waveAmpX: 50, // Larger amplitude for visibility
              waveAmpY: 30, // Larger amplitude for visibility
              friction: 0.82, // Lower friction for more movement
              tension: 0.04, // Higher tension for better response
              maxCursorMove: 250, // Much larger movement range
              xGap: 15, // Slightly larger gaps for performance
              yGap: 40, // Slightly larger gaps for performance
            ),
          ),
          // Content overlay
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Flutter Waves',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Touch and drag to interact',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Text(
                      'Tap anywhere to create waves',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
