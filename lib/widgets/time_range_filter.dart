import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app_state.dart';

class TimeRangeFilter extends StatelessWidget {
  const TimeRangeFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return DropdownButtonFormField<TimeRangeOption>(
      value: appState.timeRange,
      isDense: true,
      decoration: InputDecoration(
        labelText: 'Time Range',
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: TimeRangeOption.presets.map((range) => DropdownMenuItem<TimeRangeOption>(
            value: range,
            child: Text(range.label),
          )).toList(),
      onChanged: (value) {
        if (value != null) {
          appState.timeRange = value;
        }
      },
    );
  }
}
