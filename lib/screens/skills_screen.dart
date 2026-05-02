import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app_state.dart';
import '../widgets/skill_card.dart';
import 'skill_edit_screen.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/vibe_paths.dart';

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});

  Future<void> _deleteSkill(BuildContext context, String skillId, String skillPath) async {
    final appState = context.read<AppState>();
    
    try {
      final skillDir = Directory(skillPath);
      if (await skillDir.exists()) {
        await skillDir.delete(recursive: true);
        await appState.loadAll();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Skill deleted successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete skill: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SkillEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: appState.skills.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No skills found. Create one to get started.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SkillEditScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Skill'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => appState.loadAll(),
              child: ListView.builder(
                itemCount: appState.skills.length,
                itemBuilder: (context, index) {
                  final skill = appState.skills[index];
                  return SkillCard(
                    skill: skill,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SkillEditScreen(skill: skill),
                        ),
                      );
                    },
                    onDelete: () => _deleteSkill(context, skill.id, skill.directoryPath),
                  );
                },
              ),
            ),
    );
  }
}
