import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app_state.dart';

class ProjectFilter extends StatefulWidget {
  const ProjectFilter({super.key});

  @override
  State<ProjectFilter> createState() => _ProjectFilterState();
}

class _ProjectFilterState extends State<ProjectFilter> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<String> _filteredProjects = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_isDropdownOpen) {
      _showOverlay();
    } else if (!_focusNode.hasFocus && _isDropdownOpen) {
      // Delay to allow tap on overlay item
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _showOverlay() {
    final appState = context.read<AppState>();
    _filteredProjects = appState.projects;

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlay(),
    );
    Overlay.of(context).insert(_overlayEntry!);
    _isDropdownOpen = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
  }

  void _filterProjects(String query) {
    final appState = context.read<AppState>();
    setState(() {
      _filteredProjects = appState.projects
          .where((p) => p.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _selectProject(String? project) {
    final appState = context.read<AppState>();
    appState.selectedProject = project;
    _controller.text = project ?? '';
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    _removeOverlay();
    _focusNode.unfocus();
  }

  Widget _buildOverlay() {
    return Positioned(
      width: _overlayWidth,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 48),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _filteredProjects.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    dense: true,
                    title: const Text('All Projects',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () => _selectProject(null),
                  );
                }
                final project = _filteredProjects[index - 1];
                return ListTile(
                  dense: true,
                  title: Text(project),
                  onTap: () => _selectProject(project),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  final LayerLink _layerLink = LayerLink();
  double get _overlayWidth => 200;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Sync controller with external state changes
    if (appState.selectedProject != null &&
        _controller.text != appState.selectedProject) {
      _controller.text = appState.selectedProject!;
    } else if (appState.selectedProject == null && _controller.text.isNotEmpty) {
      _controller.clear();
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _filterProjects,
        decoration: InputDecoration(
          labelText: 'Project',
          hintText: 'All Projects',
          suffixIcon: appState.selectedProject != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _selectProject(null),
                )
              : const Icon(Icons.search, size: 18),
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
