import 'dart:io';
import 'package:path/path.dart' as path;

import '../models/skill.dart';
import '../utils/vibe_paths.dart';

class SkillLoader {
  static Future<List<Skill>> loadAllSkills() async {
    final skills = <Skill>[];
    
    // Load global skills from ~/.vibe/skills/
    skills.addAll(await _loadSkillsFromDirectory(VibePaths.skillsDirectory));
    
    // Load project-local skills from ./.vibe/skills/
    skills.addAll(await _loadSkillsFromDirectory(VibePaths.projectSkillsDirectory));

    // Sort by name
    skills.sort((a, b) => a.frontmatter.name.compareTo(b.frontmatter.name));
    return skills;
  }

  static Future<List<Skill>> _loadSkillsFromDirectory(String directoryPath) async {
    final dir = Directory(directoryPath);

    if (!await dir.exists()) {
      // Only log for global skills directory, not project-local (which is optional)
      if (directoryPath == VibePaths.skillsDirectory) {
        print('SkillLoader: Global skills directory does not exist: $directoryPath');
      }
      return [];
    }

    try {
      final entries = await dir.list().toList();
      final skills = <Skill>[];

      for (final entry in entries) {
        if (entry is! Directory) continue;

        final skillFile = File(path.join(entry.path, VibePaths.skillFile));
        if (!await skillFile.exists()) continue;

        try {
          final content = await skillFile.readAsString();
          final skill = Skill.parse(
            content,
            entry.path.split(path.separator).last,
            entry.path,
          );
          skills.add(skill);
        } catch (e) {
          print('Failed to parse ${skillFile.path}: $e');
        }
      }

      return skills;
    } catch (e) {
      print('Error loading skills from $directoryPath: $e');
      return [];
    }
  }

  static Future<Skill?> loadSkill(String skillId) async {
    final skills = await loadAllSkills();
    return skills.cast<Skill?>().firstWhere(
          (s) => s?.id == skillId,
          orElse: () => null,
        );
  }
}
