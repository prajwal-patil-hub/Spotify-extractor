/// Deterministic row-id builders — composite keys mean batch upserts never
/// need a read-before-write.
library;

import 'package:core_domain/core_domain.dart';

String accountRowId(ProviderId provider, AccountId account) =>
    '${provider.value}:${account.value}';

String trackRowId(ProviderId provider, ProviderTrackId track) =>
    '${provider.value}:${track.value}';

String playlistRowId(String accountRowId, ProviderPlaylistId playlist) =>
    '$accountRowId:${playlist.value}';

String mappingRowId(String srcTrackRowId, ProviderId dstProvider) =>
    '$srcTrackRowId->${dstProvider.value}';
