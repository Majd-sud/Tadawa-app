import 'package:flutter/material.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Aspirin'),
            subtitle: const Text('Dosage: 100mg'),
            trailing: const Icon(Icons.edit),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
