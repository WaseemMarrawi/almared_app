import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/graphql/queries.dart';
import '../models/home_models.dart';

/// Repository that fetches all data needed for the homepage.
///
/// Uses:
///   • `ThemeQueries.getThemeCustomization` → homepage section layout
///   • `CategoryQueries.getHomeCategories` → category carousel
///   • `ProductQueries.getProducts` → product carousels (Featured, Hot Deals, New, etc.)
class HomeRepository {
  final GraphQLClient _client;

  HomeRepository({required GraphQLClient client}) : _client = client;

  /// Fetches the theme customization entries that define homepage sections.
  Future<List<ThemeCustomization>> fetchThemeCustomization({
    List<String> ids = homeThemeCustomizationIds,
  }) async {
    // Read the user's preferred locale for selecting the right translation
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString(LocaleCubit.localeKey) ?? 'en';

    final results = await Future.wait(
      ids.map((id) => _fetchThemeCustomizationById(id, locale)),
    );

    return results
        .whereType<ThemeCustomization>()
        .where((tc) => tc.status)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<ThemeCustomization?> _fetchThemeCustomizationById(
    String id,
    String locale,
  ) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(ThemeQueries.getThemeCustomization),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      final message = ErrorMapper.fromQueryResult(
        result,
        context: 'loading theme customization $id',
      );
      final raw = result.exception.toString();
      if (raw.contains('not found') || raw.contains('does not exist')) {
        return null;
      }
      throw Exception(message);
    }

    final node = result.data?['themeCustomization'] as Map<String, dynamic>?;
    if (node == null) return null;

    return ThemeCustomization.fromJson(node, preferredLocale: locale);
  }

  /// Fetches categories for the horizontal category carousel.
  Future<List<HomeCategory>> fetchHomeCategories() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(CategoryQueries.getHomeCategories),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw Exception(
        ErrorMapper.fromQueryResult(result, context: 'loading categories'),
      );
    }

    final edges = result.data?['categories']?['edges'] as List? ?? [];
    return edges
        .map((e) => HomeCategory.fromJson(e['node'] as Map<String, dynamic>))
        .where((c) => c.numericId != 1) // exclude root category
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  /// Fetches products with optional filter JSON and sorting.
  ///
  /// Used by product_carousel sections: Featured Products, Hot Deals,
  /// New Products, etc.
  /// Sort key options per Almared API: PRICE, TITLE, NEWEST, BEST_SELLING
  Future<List<HomeProduct>> fetchProducts({
    int first = 8,
    String? filter,
    String sortKey = 'NEWEST',
    bool reverse = true,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(ProductQueries.getProducts),
        variables: {
          'first': first,
          'sortKey': sortKey,
          'reverse': reverse,
          if (filter != null) 'filter': filter,
        },
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw Exception(
        ErrorMapper.fromQueryResult(result, context: 'loading products'),
      );
    }

    final edges = result.data?['products']?['edges'] as List? ?? [];
    return edges
        .map((e) => HomeProduct.fromJson(e['node'] as Map<String, dynamic>))
        .toList();
  }
}
