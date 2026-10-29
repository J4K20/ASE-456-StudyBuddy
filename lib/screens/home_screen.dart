import 'package:flutter/material.dart';
import 'package:study_buddy/set_service.dart';

import 'set_page.dart';
import '../widgets/set_list.dart';
import 'set_editor.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  late Future<List<dynamic>> _sets;

  @override
  void initState() {
    super.initState();
    _sets = SetService.getSets();
  }

  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadSets() {
    setState(() {
      _sets = SetService.getSets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'StudyBuddy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search study sets, notes, or tags...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: <String>['All', 'Recent', 'Popular', 'Public'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedFilter = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            Card(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'AI PDF Converter',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Convert lecture notes & PDFs into flashcards automatically.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/pdf-convert');
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Convert'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Study Tools',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildFeatureCard(
                  context,
                  title: 'Notes',
                  icon: Icons.note_alt_outlined,
                  color: Colors.blue,
                  route: '/notes',
                ),
                _buildFeatureCard(
                  context,
                  title: 'Flashcards',
                  icon: Icons.style_outlined,
                  color: Colors.orange,
                  route: '/flashcards',
                ),
                _buildFeatureCard(
                  context,
                  title: 'Quizzes',
                  icon: Icons.quiz_outlined,
                  color: Colors.green,
                  route: '/quizzes',
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Study Sets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SetPage()),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            SetList(sets: _sets),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateOptionsModal(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create New',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.note_add, color: Colors.blue),
                title: const Text('Text Note (Markdown)'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/notes/create');
                },
              ),
              ListTile(
                leading: const Icon(Icons.style, color: Colors.orange),
                title: const Text('Flashcard Deck'),
                onTap: () async {
                  Navigator.pop(context);
                  final created = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SetEditorPage(),
                    ),
                  );
                  _reloadSets();
                },
              ),
              ListTile(
                leading: const Icon(Icons.quiz, color: Colors.green),
                title: const Text('Interactive Quiz'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/quizzes/create');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
