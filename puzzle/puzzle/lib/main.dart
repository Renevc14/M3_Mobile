import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

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
  final List<String> original = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'X'];
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
    int emptyIndex = shuffled.indexOf('X');
    List<int> validMoves = [
      if (index - 3 >= 0) index - 3,
      if (index + 3 < 9) index + 3,
      if (index % 3 != 0) index - 1,
      if (index % 3 != 2) index + 1,
    ];

    if (validMoves.contains(emptyIndex)) {
      setState(() {
        shuffled[emptyIndex] = shuffled[index];
        shuffled[index] = 'X';
        _controller.forward(from: 0);
        checkVictory();
      });
    }
  }

  bool isVictory() {
    for (int i = 0; i < original.length; i++) {
      if (shuffled[i] != original[i]) return false;
    }
    return true;
  }

  void checkVictory() async {
    if (isVictory()) {
      if (!kIsWeb) {
        await _audioPlayer.play(AssetSource('assets/success.mp3'));
      }
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "¡Victoria!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              content: const Text(
                "Has resuelto el rompecabezas",
                style: TextStyle(fontSize: 18),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Aceptar",
                    style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
      );
    }
  }

  final Map<String, Color> tileColors = {
    'A': Colors.red,
    'B': Colors.orange,
    'C': Colors.yellow,
    'D': Colors.green,
    'E': Colors.blue,
    'F': Colors.indigo,
    'G': Colors.purple,
    'H': Colors.teal,
    'X': Colors.grey[300]!,
  };

  Widget buildTile(String letter) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: tileColors[letter] ?? Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (letter != 'X')
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
        ],
        border: Border.all(color: Colors.black, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        letter != 'X' ? letter : '',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget buildGrid(List<String> tiles, bool interactive, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: GridView.builder(
        itemCount: tiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap:
                interactive && tiles[index] != 'X'
                    ? () => moveTile(index)
                    : null,
            child: buildTile(tiles[index]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final boardSize = isSmallScreen ? screenWidth * 0.9 : 360.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Rompecabezas",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF7FF), Color(0xFFE5E5FF)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Modelo a copiar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  buildGrid(original, false, boardSize * 0.6),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: mixTiles,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Mezclar",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 30),
                  buildGrid(shuffled, true, boardSize),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
