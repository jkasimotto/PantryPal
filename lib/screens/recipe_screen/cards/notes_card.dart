import 'package:flutter/material.dart';

class NotesInfoCard extends StatelessWidget {
  const NotesInfoCard({
    super.key,
    required TextEditingController notesController,
  }) : _notesController = notesController;

  final TextEditingController _notesController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.note),
        title: TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
          ),
        ),
      ),
    );
  }
}