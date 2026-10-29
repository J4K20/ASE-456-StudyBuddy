import 'package:flutter/material.dart';

import '../screens/set_viewer.dart';

class SetList extends StatelessWidget {
  final Future<List<dynamic>> sets;

  const SetList({super.key, required this.sets});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: sets,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Could not load sets');
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Text('No study sets yet');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final set = data[index];
            final title = set['title'] as String;
            final isPublic = set['public'] as bool? ?? false;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    index == 0
                        ? Icons.note
                        : (index == 1 ? Icons.style : Icons.quiz),
                    color: Colors.blue.shade800,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPublic ? Icons.public : Icons.lock,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SetViewerPage(setId: set['id'], title: title),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
