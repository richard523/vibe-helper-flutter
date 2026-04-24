class VibeModel {
  final String name;
  final String provider;
  final String alias;
  final double temperature;
  final double inputPrice;
  final double outputPrice;

  VibeModel({
    required this.name,
    required this.provider,
    required this.alias,
    required this.temperature,
    required this.inputPrice,
    required this.outputPrice,
  });

  String get id => name;

  factory VibeModel.fromTomlMap(Map<String, dynamic> map) {
    return VibeModel(
      name: map['name'] as String? ?? '',
      provider: map['provider'] as String? ?? '',
      alias: map['alias'] as String? ?? '',
      temperature: (map['temperature'] as num? ?? 0).toDouble(),
      inputPrice: (map['input_price'] as num? ?? 0).toDouble(),
      outputPrice: (map['output_price'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'provider': provider,
    'alias': alias,
    'temperature': temperature,
    'input_price': inputPrice,
    'output_price': outputPrice,
  };
}

class VibeProvider {
  final String name;
  final String apiBase;
  final String apiKeyEnvVar;
  final String apiStyle;
  final String backend;
  final String reasoningFieldName;

  VibeProvider({
    required this.name,
    required this.apiBase,
    required this.apiKeyEnvVar,
    required this.apiStyle,
    required this.backend,
    required this.reasoningFieldName,
  });

  String get id => name;

  factory VibeProvider.fromTomlMap(Map<String, dynamic> map) {
    return VibeProvider(
      name: map['name'] as String? ?? '',
      apiBase: map['api_base'] as String? ?? '',
      apiKeyEnvVar: map['api_key_env_var'] as String? ?? '',
      apiStyle: map['api_style'] as String? ?? '',
      backend: map['backend'] as String? ?? '',
      reasoningFieldName: map['reasoning_field_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'api_base': apiBase,
    'api_key_env_var': apiKeyEnvVar,
    'api_style': apiStyle,
    'backend': backend,
    'reasoning_field_name': reasoningFieldName,
  };
}

class VibeConfig {
  final String activeModel;
  final List<VibeModel> models;
  final List<VibeProvider> providers;

  VibeConfig({
    required this.activeModel,
    required this.models,
    required this.providers,
  });

  factory VibeConfig.fromToml(String tomlContent) {
    String activeModel = '';
    final List<Map<String, dynamic>> modelMaps = [];
    final List<Map<String, dynamic>> providerMaps = [];

    Map<String, dynamic>? currentModel;
    Map<String, dynamic>? currentProvider;
    String? currentSection;

    for (final line in tomlContent.split('\n')) {
      final trimmed = line.trim();

      // Skip comments and empty lines
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      // Section headers
      if (trimmed == '[[models]]') {
        currentSection = 'model';
        currentModel = {};
        continue;
      }
      if (trimmed == '[[providers]]') {
        currentSection = 'provider';
        currentProvider = {};
        continue;
      }

      // Other section headers end current block
      if (trimmed.startsWith('[') && currentSection != null) {
        if (currentSection == 'model' && currentModel != null && currentModel.isNotEmpty) {
          modelMaps.add(currentModel);
          currentModel = null;
        }
        if (currentSection == 'provider' && currentProvider != null && currentProvider.isNotEmpty) {
          providerMaps.add(currentProvider);
          currentProvider = null;
        }
        continue;
      }

      // Simple key = value parsing
      final eqIndex = trimmed.indexOf('=');
      if (eqIndex > 0) {
        final key = trimmed.substring(0, eqIndex).trim();
        var value = trimmed.substring(eqIndex + 1).trim();

        // Remove quotes
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.substring(1, value.length - 1);
        }

        // Parse numeric values
        final numValue = num.tryParse(value);
        final boolValue = value.toLowerCase() == 'true';
        final parsedValue = numValue ?? (value.toLowerCase() == 'false' ? false : boolValue ? true : value);

        if (currentModel != null) {
          currentModel[key] = parsedValue;
        } else if (currentProvider != null) {
          currentProvider[key] = parsedValue;
        } else if (key == 'active_model') {
          activeModel = value;
        }
      }
    }

    // Don't forget the last block
    if (currentModel != null && currentModel.isNotEmpty) {
      modelMaps.add(currentModel);
    }
    if (currentProvider != null && currentProvider.isNotEmpty) {
      providerMaps.add(currentProvider);
    }

    return VibeConfig(
      activeModel: activeModel,
      models: modelMaps.map((m) => VibeModel.fromTomlMap(m)).toList(),
      providers: providerMaps.map((p) => VibeProvider.fromTomlMap(p)).toList(),
    );
  }
}
