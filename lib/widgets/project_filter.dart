import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app_state.dart';

class ProjectFilter extends StatelessWidget {
  const ProjectFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return DropdownButtonFormField<String>(
      value: appState.selectedProject,
      isDense: true,
      decoration: InputDecoration(
        labelText: 'Project',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      hint: const Text('All Projects'),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All Projects'),
        ),
        ...appState.projects.map((project) => DropdownMenuItem<String>(
              value: project,
              child: Text(project),
            )).toList(),
      ],
      onChanged: (value) {
        appState.selectedProject = value;
      },
    );
  }
}
