/// Almared API endpoint
const String almaredEndpoint = String.fromEnvironment(
  'ALMARED_GRAPHQL_ENDPOINT',
  defaultValue: 'https://almard.eidosteam.com/api/graphql',
);

/// Storefront key for Almared API
const String storefrontKey = String.fromEnvironment(
  'ALMARED_STOREFRONT_KEY',
  defaultValue: 'pk_storefront_KTJeRKSs3pOdYZqwmYuoEIf5KNIG9LHR',
);

/// Default channel code used by request headers.
const String channelCode = 'default';

/// Default Almared channel ID used during app bootstrap.
const int channelId = 1;

/// Company name
const String companyName = 'Almared';
