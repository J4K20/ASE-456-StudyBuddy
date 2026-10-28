import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'set_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<List<dynamic>> _sets;

  @override
  void initState() {
    super.initState();
    _sets = SetService.getSets();
  }

  void _reload() {
    setState(() {
      _sets = SetService.getSets();
    });
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.library_add),
              title: const Text('New Study Set'),
              onTap: () {
                Navigator.pop(context);
                _newSet();
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Set from PDF'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('Make a Note'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _newSet() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New study set'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (title == null || title.trim().isEmpty) return;
    await SetService.createSet(title.trim());
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMenu,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AuthService.currentUsername}',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Your Sets', style: TextStyle(fontSize: 20)),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _sets,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Text('Could not load sets');
                  }
                  final sets = snapshot.data!;
                  if (sets.isEmpty) {
                    return const Text('No sets yet. Tap + to make one.');
                  }
                  return ListView.builder(
                    itemCount: sets.length,
                    itemBuilder: (context, i) =>
                        Card(child: ListTile(title: Text(sets[i]['title']))),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
