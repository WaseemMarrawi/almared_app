// Filter attribute model for product filtering.
//
// Supports both the legacy single-attribute API (`attribute(id:)`)
// and the dynamic `categoryAttributeFilters` API which returns
// all filterable attributes for a category, including price range.

class FilterAttribute {
  final String id;
  final int? numericId; // _id from API
  final String code;
  final String adminName;
  final String? type; // e.g. "select", "price", "text", "boolean"
  final String? swatchType; // e.g. "dropdown", "color", "image", "text"
  final String? validation;
  final int? position;
  final bool isFilterable;
  final bool isConfigurable;
  final double? maxPrice;
  final double? minPrice;
  final String? translatedName; // from translations
  final List<FilterOption> options;

  const FilterAttribute({
    required this.id,
    this.numericId,
    required this.code,
    required this.adminName,
    this.type,
    this.swatchType,
    this.validation,
    this.position,
    this.isFilterable = false,
    this.isConfigurable = false,
    this.maxPrice,
    this.minPrice,
    this.translatedName,
    this.options = const [],
  });

  /// Whether this attribute represents a price range filter
  bool get isPriceFilter => code == 'price' || type == 'price';

  /// Display name: translated name → adminName → capitalized code
  String get displayName {
    if (translatedName != null && translatedName!.isNotEmpty) {
      return translatedName!;
    }
    if (adminName.isNotEmpty) return adminName;
    if (code.isEmpty) return code;
    return '${code[0].toUpperCase()}${code.substring(1)}';
  }

  /// Parse from the legacy `attribute(id:)` response
  factory FilterAttribute.fromJson(Map<String, dynamic> json) {
    final optionEdges =
        json['options']?['edges'] as List<dynamic>? ?? [];

    return FilterAttribute(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      adminName: (json['code']?.toString() ?? '').toUpperCase(),
      options: optionEdges.map((edge) {
        final node = edge['node'] as Map<String, dynamic>;
        return FilterOption.fromJson(node);
      }).toList(),
    );
  }

  /// Parse from the `categoryAttributeFilters` API response node
  factory FilterAttribute.fromCategoryFilterJson(Map<String, dynamic> json) {
    final optionEdges =
        json['options']?['edges'] as List<dynamic>? ?? [];

    // Extract translated name
    String? translatedName;
    final translationEdges =
        json['translations']?['edges'] as List<dynamic>?;
    if (translationEdges != null && translationEdges.isNotEmpty) {
      final firstTranslation =
          translationEdges.first['node'] as Map<String, dynamic>?;
      translatedName = firstTranslation?['name']?.toString();
    }

    return FilterAttribute(
      id: json['id']?.toString() ?? '',
      numericId: _parseInt(json['_id'] ?? json['id']),
      code: json['code']?.toString() ?? '',
      adminName: json['adminName']?.toString() ?? '',
      type: json['type']?.toString(),
      swatchType: json['swatchType']?.toString(),
      validation: json['validation']?.toString(),
      position: _parseInt(json['position']),
      isFilterable: _parseBool(json['isFilterable']),
      isConfigurable: _parseBool(json['isConfigurable']),
      maxPrice: _parseDouble(json['maxPrice']),
      minPrice: _parseDouble(json['minPrice']),
      translatedName: translatedName,
      options: optionEdges.map((edge) {
        final node = edge['node'] as Map<String, dynamic>;
        return FilterOption.fromCategoryFilterJson(node);
      }).toList(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final text = value.toString();
    return int.tryParse(text) ?? int.tryParse(text.split('/').last);
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return false;
  }
}

class FilterOption {
  final String id;
  final int? numericId; // _id from API
  final String adminName;
  final String? label;
  final int? sortOrder;
  final String? swatchValue;
  final String? swatchValueUrl;

  const FilterOption({
    required this.id,
    this.numericId,
    required this.adminName,
    this.label,
    this.sortOrder,
    this.swatchValue,
    this.swatchValueUrl,
  });

  /// Parse from the legacy `attribute(id:)` response
  factory FilterOption.fromJson(Map<String, dynamic> json) {
    String? label;
    final translations = json['translations']?['edges'] as List<dynamic>?;
    if (translations != null && translations.isNotEmpty) {
      final firstTranslation =
          translations.first['node'] as Map<String, dynamic>?;
      label = firstTranslation?['label']?.toString();
    }

    return FilterOption(
      id: json['id']?.toString() ?? '',
      adminName: json['adminName']?.toString() ?? '',
      label: label,
    );
  }

  /// Parse from the `categoryAttributeFilters` option node
  factory FilterOption.fromCategoryFilterJson(Map<String, dynamic> json) {
    // Try direct translation first, then translations edges
    String? label;
    final directTranslation = json['translation'] as Map<String, dynamic>?;
    if (directTranslation != null) {
      label = directTranslation['label']?.toString();
    }
    if (label == null || label.isEmpty) {
      final translationEdges =
          json['translations']?['edges'] as List<dynamic>?;
      if (translationEdges != null && translationEdges.isNotEmpty) {
        final firstTranslation =
            translationEdges.first['node'] as Map<String, dynamic>?;
        label = firstTranslation?['label']?.toString();
      }
    }

    return FilterOption(
      id: json['id']?.toString() ?? '',
      numericId: FilterAttribute._parseInt(json['_id'] ?? json['id']),
      adminName: json['adminName']?.toString() ?? '',
      label: label,
      sortOrder: FilterAttribute._parseInt(json['sortOrder']),
      swatchValue: json['swatchValue']?.toString(),
      swatchValueUrl: json['swatchValueUrl']?.toString(),
    );
  }

  /// Extract numeric ID from IRI like "/api/admin/attribute-options/6"
  String? get numericIdFromIri {
    final match = RegExp(r'/(\d+)$').firstMatch(id);
    return match?.group(1);
  }

  /// Resolved numeric ID: use _id field if available, else extract from IRI
  String get resolvedId {
    if (numericId != null) return numericId.toString();
    return numericIdFromIri ?? id;
  }

  /// Display name: use label (translated) if available, else adminName
  String get displayName =>
      (label != null && label!.isNotEmpty) ? label! : adminName;

  /// Whether this option has a color swatch
  bool get hasColorSwatch =>
      swatchValue != null && swatchValue!.isNotEmpty;

  /// Whether this option has an image swatch
  bool get hasImageSwatch =>
      swatchValueUrl != null && swatchValueUrl!.isNotEmpty;
}

/// Sort option model
/// Maps to: SortByFields from nextjs-commerce/src/utils/constants.ts
class SortOption {
  final String key;
  final String sortKey;
  final bool reverse;

  const SortOption({
    required this.key,
    required this.sortKey,
    required this.reverse,
  });
}

/// Predefined sort options matching Almared API docs
/// Sort key options: PRICE, TITLE, NEWEST, BEST_SELLING
const List<SortOption> sortByFields = [
  SortOption(
    key: 'name-asc',
    sortKey: 'TITLE',
    reverse: false,
  ),
  SortOption(
    key: 'name-desc',
    sortKey: 'TITLE',
    reverse: true,
  ),
  SortOption(
    key: 'newest',
    sortKey: 'NEWEST',
    reverse: true,
  ),
  SortOption(
    key: 'oldest',
    sortKey: 'NEWEST',
    reverse: false,
  ),
  SortOption(
    key: 'price-asc',
    sortKey: 'PRICE',
    reverse: false,
  ),
  SortOption(
    key: 'price-desc',
    sortKey: 'PRICE',
    reverse: true,
  ),
];
