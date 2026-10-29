import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import '../set_service.dart';

class SetViewerPage extends StatefulWidget {
  final String setId;
  final String title;

  const SetViewerPage({super.key, required this.setId, required this.title});

  @override
  State<SetViewerPage> createState() => _SetViewerPageState();
}

class _SetViewerPageState extends State<SetViewerPage> {
  late Future<Map<String, dynamic>> _set;
  int _page = 0;

  Widget _side(String label, String text) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _set = SetService.getSet(widget.setId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _set,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load set'));
          }

          final cards = snapshot.data!['cards'] as List<dynamic>;
          if (cards.isEmpty) {
            return const Center(child: Text('This set has no cards'));
          }

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: cards.length,
                  onPageChanged: (i) {
                    setState(() {
                      _page = i;
                    });
                  },
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: FlipCard(
                      front: _side('Question', cards[i]['question']),
                      back: _side('Answer', cards[i]['answer']),
                    ),
                  ),
                ),
              ),
              Text('${_page + 1} / ${cards.length}'),
              const SizedBox(height: 8),
              const Text(
                'Tap to flip · Swipe for next',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
