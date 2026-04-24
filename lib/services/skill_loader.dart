import 'dart:io';
import 'package:path/path.dart' as path;

import '../models/skill.dart';
import '../utils/vibe_paths.dart';

class SkillLoader {
  static final String _skillsDir = VibePaths.skillsDirectory;

  static Future<List<Skill>> loadAllSkills() async {
    final dir = Directory(_skillsDir);

    if (!await dir.exists()) {
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
            entry.path.split('/').last,
            entry.path,
          );
          skills.add(skill);
        } catch (e) {
          print('Failed to parse ${skillFile.path}: $e');
        }
      }

      // Sort by name
      skills.sort((a, b) => a.frontmatter.name.compareTo(b.frontmatter.name));
      return skills;
    } catch (e) {
      print('Error loading skills: $e');
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
