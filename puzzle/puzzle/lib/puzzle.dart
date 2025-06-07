import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const PuzzleApp());
}

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PuzzleHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PuzzleHome extends StatefulWidget {
  const PuzzleHome({super.key});

  @override
  State<PuzzleHome> createState() => _PuzzleHomeState();
}

class _PuzzleHomeState extends State<PuzzleHome>
    with SingleTickerProviderStateMixin {
  List<String> original = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', ''];
  late List<String> shuffled;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    shuffled = List.from(original);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void mixTiles() {
    setState(() {
      shuffled.shuffle(Random());
    });
  }

  void moveTile(int index) {
    int emptyIndex = shuffled.indexOf('');
    List<int> validMoves = [
      if (index - 3 >= 0) index - 3,
      if (index + 3 < 9) index + 3,
      if (index % 3 != 0) index - 1,
      if (index % 3 != 2) index + 1,
    ];

    if (validMoves.contains(emptyIndex)) {
      setState(() {
        shuffled[emptyIndex] = shuffled[index];
        shuffled[index] = '';
        _controller.forward(from: 0);
        checkVictory();
      });
    }
  }

  void checkVictory() async {
    if (shuffled.join() == original.join()) {
      await _audioPlayer.play(AssetSource('assets/success.mp3'));
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("¡Victoria!"),
              content: const Text("Has resuelto el rompecabezas."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Aceptar"),
                ),
              ],
            ),
      );
    }
  }

  Widget buildTile(String letter, double size) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.red[300],
          border: Border.all(color: Colors.black, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildGrid(List<String> tiles, bool interactive, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(tiles.length, (index) {
          return GestureDetector(
            onTap:
                interactive && tiles[index] != ''
                    ? () => moveTile(index)
                    : null,
            child: buildTile(tiles[index], size / 3),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final boardSize = isSmallScreen ? screenWidth * 0.9 : 360.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      appBar: AppBar(title: const Text("Rompecabezas")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Text("Modelo a copiar", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                buildGrid(original, false, boardSize * 0.6),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: mixTiles, child: const Text("Mix")),
                const SizedBox(height: 30),
                buildGrid(shuffled, true, boardSize),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
