/// Category model matching Almared GraphQL schema
/// Derived from: nextjs-commerce/src/graphql/catelog/queries/Category.ts
///               nextjs-commerce/src/graphql/catelog/queries/HomeCategories.ts
class CategoryModel {
  final String id;
  final int? numericId; // _id field from API
  final int? position;
  final String? logoPath;
  final String? logoUrl;
  final String? bannerUrl;
  final String? status;
  final CategoryTranslation? translation;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    this.numericId,
    this.position,
    this.logoPath,
    this.logoUrl,
    this.bannerUrl,
    this.status,
    this.translation,
    this.children = const [],
  });

  String get name => translation?.name ?? '';
  String get slug => translation?.slug ?? '';
  String get urlPath => translation?.urlPath ?? '';
  String? get imageUrl => logoUrl ?? logoPath;
  bool get isActive => status == '1';

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final text = value.toString();
    return int.tryParse(text) ?? int.tryParse(text.split('/').last);
  }

  static String? _toString(dynamic value) => value?.toString();

  /// Factory for treeCategories response
  factory CategoryModel.fromTreeJson(Map<String, dynamic> json) {
    // Parse children from cursor connection format: { edges: [{ node: {...} }] }
    List<CategoryModel> childrenList = [];
    final childrenData = json['children'];
    if (childrenData != null && childrenData is Map<String, dynamic>) {
      final edges = childrenData['edges'] as List<dynamic>?;
      if (edges != null) {
        childrenList = edges
            .where((e) => e['node'] != null)
            .map((e) =>
                CategoryModel.fromTreeJson(e['node'] as Map<String, dynamic>))
            .toList();
      }
    }

    return CategoryModel(
      id: json['id']?.toString() ?? '',
      numericId: _toInt(json['_id'] ?? json['id']),
      position: _toInt(json['position']),
      logoPath: _toString(json['logoPath']),
      logoUrl: _toString(json['logoUrl']),
      bannerUrl: _toString(json['bannerUrl']),
      status: json['status']?.toString(),
      translation: json['translation'] != null
          ? CategoryTranslation.fromJson(
              json['translation'] as Map<String, dynamic>)
          : null,
      children: childrenList,
    );
  }

  /// Factory for categories (home) cursor connection response
  factory CategoryModel.fromHomeCategoryJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      numericId: _toInt(json['_id'] ?? json['id']),
      logoUrl: _toString(json['logoUrl']),
      position: _toInt(json['position']),
      translation: json['translation'] != null
          ? CategoryTranslation.fromJson(
              json['translation'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CategoryTranslation {
  final String? id;
  final String? name;
  final String? slug;
  final String? description;
  final String? urlPath;
  final String? metaTitle;

  const CategoryTranslation({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.urlPath,
    this.metaTitle,
  });

  factory CategoryTranslation.fromJson(Map<String, dynamic> json) {
    return CategoryTranslation(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
      urlPath: json['urlPath']?.toString(),
      metaTitle: json['metaTitle']?.toString(),
    );
  }
}

