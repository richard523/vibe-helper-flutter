class SkillFrontmatter {
  final String name;
  final String description;
  final bool userInvocable;
  final List<String> tools;

  SkillFrontmatter({
    required this.name,
    required this.description,
    required this.userInvocable,
    required this.tools,
  });

  factory SkillFrontmatter.fromYaml(String yaml) {
    String name = '';
    String description = '';
    bool userInvocable = false;
    List<String> tools = [];
    bool inToolsList = false;

    for (final line in yaml.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Check if we're in tools list
      if (inToolsList) {
        if (trimmed.startsWith('- ')) {
          tools.add(trimmed.substring(2).trim());
          continue;
        }
        inToolsList = false;
      }

      final colonIndex = trimmed.indexOf(':');
      if (colonIndex < 0) continue;

      final key = trimmed.substring(0, colonIndex).trim().toLowerCase();
      var value = trimmed.substring(colonIndex + 1).trim();

      // Remove quotes if present
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }

      switch (key) {
        case 'name':
          name = value;
          break;
        case 'description':
          description = value;
          break;
        case 'user-invocable':
          userInvocable = value.toLowerCase() == 'true';
          break;
        case 'tools':
          if (value.isEmpty) {
            inToolsList = true;
          } else {
            // Inline tools like: tools: [bash, read_file]
            if (value.startsWith('[') && value.endsWith(']')) {
              tools = value
                  .substring(1, value.length - 1)
                  .split(',')
                  .map((s) => s.trim().replaceAll('"', '').replaceAll("'", ''))
                  .where((s) => s.isNotEmpty)
                  .toList();
            }
          }
          break;
      }
    }

    if (name.isEmpty) {
      throw Exception('Missing required field: name');
    }

    return SkillFrontmatter(
      name: name,
      description: description,
      userInvocable: userInvocable,
      tools: tools,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'user-invocable': userInvocable,
    'tools': tools,
  };
}

class Skill {
  final String id;
  final SkillFrontmatter frontmatter;
  final String body;
  final String directoryPath;

  Skill({
    required this.id,
    required this.frontmatter,
    required this.body,
    required this.directoryPath,
  });

  String get skillFilePath => '${directoryPath}/SKILL.md';

  static Skill parse(String fileContent, String directoryName, String directoryPath) {
    final content = fileContent.trim();
    
    if (!content.startsWith('---')) {
      throw Exception('No frontmatter found in SKILL.md');
    }

    // Find the end of frontmatter
    final afterFirstDelimiter = content.substring(3);
    final endIndex = afterFirstDelimiter.indexOf('\n---');
    
    if (endIndex < 0) {
      throw Exception('No closing frontmatter delimiter (---)');
    }

    final yaml = afterFirstDelimiter.substring(0, endIndex);
    final bodyStart = endIndex + 4; // '\n---' is 4 chars
    final body = afterFirstDelimiter.substring(bodyStart).trim();

    final frontmatter = SkillFrontmatter.fromYaml(yaml);

    return Skill(
      id: directoryName,
      frontmatter: frontmatter,
      body: body,
      directoryPath: directoryPath,
    );
  }

  String serialize() {
    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.writeln('name: ${frontmatter.name}');
    buffer.writeln('description: ${frontmatter.description}');
    buffer.writeln('user-invocable: ${frontmatter.userInvocable}');
    if (frontmatter.tools.isNotEmpty) {
      buffer.writeln('tools:');
      for (final tool in frontmatter.tools) {
        buffer.writeln('  - $tool');
      }
    }
    buffer.writeln('---');
    buffer.writeln();
    buffer.write(body);
    return buffer.toString();
  }
}
