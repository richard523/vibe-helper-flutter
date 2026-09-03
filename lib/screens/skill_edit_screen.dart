import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/skill.dart';
import '../viewmodels/app_state.dart';
import '../utils/vibe_paths.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class SkillEditScreen extends StatefulWidget {
  final Skill? skill;

  const SkillEditScreen({super.key, this.skill});

  @override
  State<SkillEditScreen> createState() => _SkillEditScreenState();
}

class _SkillEditScreenState extends State<SkillEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _bodyController;
  late bool _userInvocable;
  late List<String> _tools;
  late TextEditingController _toolsController;

  @override
  void initState() {
    super.initState();
    if (widget.skill != null) {
      _nameController = TextEditingController(text: widget.skill!.frontmatter.name);
      _descriptionController = TextEditingController(text: widget.skill!.frontmatter.description);
      _bodyController = TextEditingController(text: widget.skill!.body);
      _userInvocable = widget.skill!.frontmatter.userInvocable;
      _tools = List.from(widget.skill!.frontmatter.tools);
      _toolsController = TextEditingController(text: _tools.join(', '));
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _bodyController = TextEditingController();
      _userInvocable = true;
      _tools = [];
      _toolsController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _bodyController.dispose();
    _toolsController.dispose();
    super.dispose();
  }

  Future<void> _saveSkill() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final description = _descriptionController.text;
    final body = _bodyController.text;
    final tools = _toolsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final frontmatter = SkillFrontmatter(
      name: name,
      description: description,
      userInvocable: _userInvocable,
      tools: tools,
    );

    final skillContent = '---\n${frontmatter.toYaml()}\n---\n\n$body';

    try {
      // Determine the directory for the skill
      final skillsDir = VibePaths.skillsDirectory;
      final dir = Directory(skillsDir);
      
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Create skill directory
      final skillId = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9-]'), '-');
      final skillDir = Directory(path.join(skillsDir, skillId));
      
      if (!await skillDir.exists()) {
        await skillDir.create();
      }

      // Write SKILL.md file
      final skillFile = File(path.join(skillDir.path, VibePaths.skillFile));
      await skillFile.writeAsString(skillContent);

      // Reload skills
      final appState = context.read<AppState>();
      await appState.loadAll();

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save skill: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skill == null ? 'Create Skill' : 'Edit Skill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSkill,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _toolsController,
                  decoration: const InputDecoration(
                    labelText: 'Tools (comma-separated)',
                    border: OutlineInputBorder(),
                    hintText: 'bash, read_file, write_file',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _userInvocable,
                      onChanged: (value) => setState(() => _userInvocable = value ?? false),
                    ),
                    const Text('User Invocable'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Body',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter skill instructions here...',
                  ),
                  maxLines: 10,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveSkill,
                  child: const Text('Save Skill'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
