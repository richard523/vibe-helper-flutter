import 'package:flutter/material.dart';
import '../models/config.dart';

class ProviderCard extends StatelessWidget {
  final VibeProvider provider;

  const ProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'API Base: ${provider.apiBase}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Backend: ${provider.backend}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Style: ${provider.apiStyle}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (provider.apiKeyEnvVar.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Key Env: ${provider.apiKeyEnvVar}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
