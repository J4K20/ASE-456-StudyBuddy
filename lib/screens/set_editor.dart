import 'package:flutter/material.dart';

import '../set_service.dart';

class _CardFields {
  final question = TextEditingController();
  final answer = TextEditingController();

  void dispose() {
    question.dispose();
    answer.dispose();
  }
}

class SetEditorPage extends StatefulWidget {
  const SetEditorPage({super.key});

  @override
  State<SetEditorPage> createState() => _SetEditorPageState();
}

class _SetEditorPageState extends State<SetEditorPage> {
  final _titleController = TextEditingController();

  final List<_CardFields> _cards = [_CardFields()];
  bool _saving = false;
  bool _isPublic = false;

  @override
  void dispose() {
    _titleController.dispose();
    for (final card in _cards) {
      card.dispose();
    }
    super.dispose();
  }

  void _addCard() {
    setState(() => _cards.add(_CardFields()));
  }

  void _removeCard(int index) {
    final card = _cards[index];
    setState(() => _cards.removeAt(index));
    WidgetsBinding.instance.addPostFrameCallback((_) => card.dispose());
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('Give your set a title');
      return;
    }

    final cards = _cards
        .where(
          (c) =>
              c.question.text.trim().isNotEmpty &&
              c.answer.text.trim().isNotEmpty,
        )
        .map(
          (c) => {
            'question': c.question.text.trim(),
            'answer': c.answer.text.trim(),
          },
        )
        .toList();
    if (cards.isEmpty) {
      _showMessage('Add at least one card with a question and answer');
      return;
    }

    setState(() => _saving = true);
    await SetService.createSet(title, _isPublic, cards);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New study set'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Set title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<bool>(
            value: _isPublic,
            decoration: const InputDecoration(
              labelText: 'Visibility',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: false,
                child: Row(
                  children: [
                    Icon(Icons.lock, size: 18),
                    SizedBox(width: 8),
                    Text('Private'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: true,
                child: Row(
                  children: [
                    Icon(Icons.public, size: 18),
                    SizedBox(width: 8),
                    Text('Public'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _isPublic = value);
            },
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          for (var i = 0; i < _cards.length; i++)
            Card(
              key: ObjectKey(_cards[i]),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Card ${i + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (_cards.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeCard(i),
                          ),
                      ],
                    ),
                    TextField(
                      controller: _cards[i].question,
                      decoration: const InputDecoration(labelText: 'Question'),
                      minLines: 1,
                      maxLines: null,
                    ),
                    TextField(
                      controller: _cards[i].answer,
                      decoration: const InputDecoration(labelText: 'Answer'),
                      minLines: 1,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: _addCard,
            icon: const Icon(Icons.add),
            label: const Text('Add card'),
          ),
        ],
      ),
    );
  }
}
