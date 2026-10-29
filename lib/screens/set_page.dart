import 'package:flutter/material.dart';

import '../set_service.dart';
import '../widgets/set_list.dart';

class SetPage extends StatefulWidget {
  const SetPage({super.key});

  @override
  State<SetPage> createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  late Future<List<dynamic>> _sets;

  @override
  void initState() {
    super.initState();
    _sets = SetService.getSets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Study Sets')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SetList(sets: _sets),
      ),
    );
  }
}
