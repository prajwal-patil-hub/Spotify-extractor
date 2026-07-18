// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProviderAccountsTable extends ProviderAccounts
    with TableInfo<$ProviderAccountsTable, ProviderAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountValueMeta = const VerificationMeta(
    'accountValue',
  );
  @override
  late final GeneratedColumn<String> accountValue = GeneratedColumn<String>(
    'account_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokenRefMeta = const VerificationMeta(
    'tokenRef',
  );
  @override
  late final GeneratedColumn<String> tokenRef = GeneratedColumn<String>(
    'token_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopesMeta = const VerificationMeta('scopes');
  @override
  late final GeneratedColumn<String> scopes = GeneratedColumn<String>(
    'scopes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('connected'),
  );
  static const VerificationMeta _connectedAtMeta = const VerificationMeta(
    'connectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> connectedAt = GeneratedColumn<DateTime>(
    'connected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    accountValue,
    displayName,
    avatarUrl,
    tokenRef,
    scopes,
    status,
    connectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProviderAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('account_value')) {
      context.handle(
        _accountValueMeta,
        accountValue.isAcceptableOrUnknown(
          data['account_value']!,
          _accountValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountValueMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('token_ref')) {
      context.handle(
        _tokenRefMeta,
        tokenRef.isAcceptableOrUnknown(data['token_ref']!, _tokenRefMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenRefMeta);
    }
    if (data.containsKey('scopes')) {
      context.handle(
        _scopesMeta,
        scopes.isAcceptableOrUnknown(data['scopes']!, _scopesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('connected_at')) {
      context.handle(
        _connectedAtMeta,
        connectedAt.isAcceptableOrUnknown(
          data['connected_at']!,
          _connectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {providerId, accountValue},
  ];
  @override
  ProviderAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      accountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_value'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      tokenRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_ref'],
      )!,
      scopes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scopes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      connectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}connected_at'],
      )!,
    );
  }

  @override
  $ProviderAccountsTable createAlias(String alias) {
    return $ProviderAccountsTable(attachedDatabase, alias);
  }
}

class ProviderAccount extends DataClass implements Insertable<ProviderAccount> {
  /// `provider:accountValue`.
  final String id;
  final String providerId;
  final String accountValue;
  final String displayName;
  final String? avatarUrl;

  /// Key into secure storage — tokens themselves NEVER live in this DB.
  final String tokenRef;
  final String scopes;
  final String status;
  final DateTime connectedAt;
  const ProviderAccount({
    required this.id,
    required this.providerId,
    required this.accountValue,
    required this.displayName,
    this.avatarUrl,
    required this.tokenRef,
    required this.scopes,
    required this.status,
    required this.connectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['account_value'] = Variable<String>(accountValue);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['token_ref'] = Variable<String>(tokenRef);
    map['scopes'] = Variable<String>(scopes);
    map['status'] = Variable<String>(status);
    map['connected_at'] = Variable<DateTime>(connectedAt);
    return map;
  }

  ProviderAccountsCompanion toCompanion(bool nullToAbsent) {
    return ProviderAccountsCompanion(
      id: Value(id),
      providerId: Value(providerId),
      accountValue: Value(accountValue),
      displayName: Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      tokenRef: Value(tokenRef),
      scopes: Value(scopes),
      status: Value(status),
      connectedAt: Value(connectedAt),
    );
  }

  factory ProviderAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderAccount(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      accountValue: serializer.fromJson<String>(json['accountValue']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      tokenRef: serializer.fromJson<String>(json['tokenRef']),
      scopes: serializer.fromJson<String>(json['scopes']),
      status: serializer.fromJson<String>(json['status']),
      connectedAt: serializer.fromJson<DateTime>(json['connectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String>(providerId),
      'accountValue': serializer.toJson<String>(accountValue),
      'displayName': serializer.toJson<String>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'tokenRef': serializer.toJson<String>(tokenRef),
      'scopes': serializer.toJson<String>(scopes),
      'status': serializer.toJson<String>(status),
      'connectedAt': serializer.toJson<DateTime>(connectedAt),
    };
  }

  ProviderAccount copyWith({
    String? id,
    String? providerId,
    String? accountValue,
    String? displayName,
    Value<String?> avatarUrl = const Value.absent(),
    String? tokenRef,
    String? scopes,
    String? status,
    DateTime? connectedAt,
  }) => ProviderAccount(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    accountValue: accountValue ?? this.accountValue,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    tokenRef: tokenRef ?? this.tokenRef,
    scopes: scopes ?? this.scopes,
    status: status ?? this.status,
    connectedAt: connectedAt ?? this.connectedAt,
  );
  ProviderAccount copyWithCompanion(ProviderAccountsCompanion data) {
    return ProviderAccount(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      accountValue: data.accountValue.present
          ? data.accountValue.value
          : this.accountValue,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      tokenRef: data.tokenRef.present ? data.tokenRef.value : this.tokenRef,
      scopes: data.scopes.present ? data.scopes.value : this.scopes,
      status: data.status.present ? data.status.value : this.status,
      connectedAt: data.connectedAt.present
          ? data.connectedAt.value
          : this.connectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderAccount(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('accountValue: $accountValue, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('tokenRef: $tokenRef, ')
          ..write('scopes: $scopes, ')
          ..write('status: $status, ')
          ..write('connectedAt: $connectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerId,
    accountValue,
    displayName,
    avatarUrl,
    tokenRef,
    scopes,
    status,
    connectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderAccount &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.accountValue == this.accountValue &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.tokenRef == this.tokenRef &&
          other.scopes == this.scopes &&
          other.status == this.status &&
          other.connectedAt == this.connectedAt);
}

class ProviderAccountsCompanion extends UpdateCompanion<ProviderAccount> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> accountValue;
  final Value<String> displayName;
  final Value<String?> avatarUrl;
  final Value<String> tokenRef;
  final Value<String> scopes;
  final Value<String> status;
  final Value<DateTime> connectedAt;
  final Value<int> rowid;
  const ProviderAccountsCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.accountValue = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.tokenRef = const Value.absent(),
    this.scopes = const Value.absent(),
    this.status = const Value.absent(),
    this.connectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProviderAccountsCompanion.insert({
    required String id,
    required String providerId,
    required String accountValue,
    required String displayName,
    this.avatarUrl = const Value.absent(),
    required String tokenRef,
    this.scopes = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime connectedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerId = Value(providerId),
       accountValue = Value(accountValue),
       displayName = Value(displayName),
       tokenRef = Value(tokenRef),
       connectedAt = Value(connectedAt);
  static Insertable<ProviderAccount> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? accountValue,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<String>? tokenRef,
    Expression<String>? scopes,
    Expression<String>? status,
    Expression<DateTime>? connectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (accountValue != null) 'account_value': accountValue,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (tokenRef != null) 'token_ref': tokenRef,
      if (scopes != null) 'scopes': scopes,
      if (status != null) 'status': status,
      if (connectedAt != null) 'connected_at': connectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProviderAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? providerId,
    Value<String>? accountValue,
    Value<String>? displayName,
    Value<String?>? avatarUrl,
    Value<String>? tokenRef,
    Value<String>? scopes,
    Value<String>? status,
    Value<DateTime>? connectedAt,
    Value<int>? rowid,
  }) {
    return ProviderAccountsCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      accountValue: accountValue ?? this.accountValue,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tokenRef: tokenRef ?? this.tokenRef,
      scopes: scopes ?? this.scopes,
      status: status ?? this.status,
      connectedAt: connectedAt ?? this.connectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (accountValue.present) {
      map['account_value'] = Variable<String>(accountValue.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (tokenRef.present) {
      map['token_ref'] = Variable<String>(tokenRef.value);
    }
    if (scopes.present) {
      map['scopes'] = Variable<String>(scopes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (connectedAt.present) {
      map['connected_at'] = Variable<DateTime>(connectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderAccountsCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('accountValue: $accountValue, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('tokenRef: $tokenRef, ')
          ..write('scopes: $scopes, ')
          ..write('status: $status, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackSnapshotsTable extends TrackSnapshots
    with TableInfo<$TrackSnapshotsTable, TrackSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerTrackIdMeta = const VerificationMeta(
    'providerTrackId',
  );
  @override
  late final GeneratedColumn<String> providerTrackId = GeneratedColumn<String>(
    'provider_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isrcMeta = const VerificationMeta('isrc');
  @override
  late final GeneratedColumn<String> isrc = GeneratedColumn<String>(
    'isrc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleNormMeta = const VerificationMeta(
    'titleNorm',
  );
  @override
  late final GeneratedColumn<String> titleNorm = GeneratedColumn<String>(
    'title_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistsJsonMeta = const VerificationMeta(
    'artistsJson',
  );
  @override
  late final GeneratedColumn<String> artistsJson = GeneratedColumn<String>(
    'artists_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseYearMeta = const VerificationMeta(
    'releaseYear',
  );
  @override
  late final GeneratedColumn<int> releaseYear = GeneratedColumn<int>(
    'release_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explicitMeta = const VerificationMeta(
    'explicit',
  );
  @override
  late final GeneratedColumn<bool> explicit = GeneratedColumn<bool>(
    'explicit',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("explicit" IN (0, 1))',
    ),
  );
  static const VerificationMeta _popularityMeta = const VerificationMeta(
    'popularity',
  );
  @override
  late final GeneratedColumn<int> popularity = GeneratedColumn<int>(
    'popularity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    providerTrackId,
    isrc,
    title,
    titleNorm,
    artistsJson,
    album,
    durationMs,
    releaseYear,
    explicit,
    popularity,
    rawJson,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('provider_track_id')) {
      context.handle(
        _providerTrackIdMeta,
        providerTrackId.isAcceptableOrUnknown(
          data['provider_track_id']!,
          _providerTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerTrackIdMeta);
    }
    if (data.containsKey('isrc')) {
      context.handle(
        _isrcMeta,
        isrc.isAcceptableOrUnknown(data['isrc']!, _isrcMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('title_norm')) {
      context.handle(
        _titleNormMeta,
        titleNorm.isAcceptableOrUnknown(data['title_norm']!, _titleNormMeta),
      );
    } else if (isInserting) {
      context.missing(_titleNormMeta);
    }
    if (data.containsKey('artists_json')) {
      context.handle(
        _artistsJsonMeta,
        artistsJson.isAcceptableOrUnknown(
          data['artists_json']!,
          _artistsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_artistsJsonMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('release_year')) {
      context.handle(
        _releaseYearMeta,
        releaseYear.isAcceptableOrUnknown(
          data['release_year']!,
          _releaseYearMeta,
        ),
      );
    }
    if (data.containsKey('explicit')) {
      context.handle(
        _explicitMeta,
        explicit.isAcceptableOrUnknown(data['explicit']!, _explicitMeta),
      );
    }
    if (data.containsKey('popularity')) {
      context.handle(
        _popularityMeta,
        popularity.isAcceptableOrUnknown(data['popularity']!, _popularityMeta),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {providerId, providerTrackId},
  ];
  @override
  TrackSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      providerTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_track_id'],
      )!,
      isrc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isrc'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      titleNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_norm'],
      )!,
      artistsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artists_json'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      releaseYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}release_year'],
      ),
      explicit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}explicit'],
      ),
      popularity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}popularity'],
      ),
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $TrackSnapshotsTable createAlias(String alias) {
    return $TrackSnapshotsTable(attachedDatabase, alias);
  }
}

class TrackSnapshot extends DataClass implements Insertable<TrackSnapshot> {
  /// `provider:providerTrackId`.
  final String id;
  final String providerId;
  final String providerTrackId;
  final String? isrc;
  final String title;
  final String titleNorm;

  /// Ordered JSON array of artist names.
  final String artistsJson;
  final String? album;
  final int? durationMs;
  final int? releaseYear;
  final bool? explicit;
  final int? popularity;

  /// Provider payload for re-scoring without refetch (docs/05 §4.3).
  final String? rawJson;
  final DateTime fetchedAt;
  const TrackSnapshot({
    required this.id,
    required this.providerId,
    required this.providerTrackId,
    this.isrc,
    required this.title,
    required this.titleNorm,
    required this.artistsJson,
    this.album,
    this.durationMs,
    this.releaseYear,
    this.explicit,
    this.popularity,
    this.rawJson,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['provider_track_id'] = Variable<String>(providerTrackId);
    if (!nullToAbsent || isrc != null) {
      map['isrc'] = Variable<String>(isrc);
    }
    map['title'] = Variable<String>(title);
    map['title_norm'] = Variable<String>(titleNorm);
    map['artists_json'] = Variable<String>(artistsJson);
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || releaseYear != null) {
      map['release_year'] = Variable<int>(releaseYear);
    }
    if (!nullToAbsent || explicit != null) {
      map['explicit'] = Variable<bool>(explicit);
    }
    if (!nullToAbsent || popularity != null) {
      map['popularity'] = Variable<int>(popularity);
    }
    if (!nullToAbsent || rawJson != null) {
      map['raw_json'] = Variable<String>(rawJson);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  TrackSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return TrackSnapshotsCompanion(
      id: Value(id),
      providerId: Value(providerId),
      providerTrackId: Value(providerTrackId),
      isrc: isrc == null && nullToAbsent ? const Value.absent() : Value(isrc),
      title: Value(title),
      titleNorm: Value(titleNorm),
      artistsJson: Value(artistsJson),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      releaseYear: releaseYear == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseYear),
      explicit: explicit == null && nullToAbsent
          ? const Value.absent()
          : Value(explicit),
      popularity: popularity == null && nullToAbsent
          ? const Value.absent()
          : Value(popularity),
      rawJson: rawJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawJson),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory TrackSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackSnapshot(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      providerTrackId: serializer.fromJson<String>(json['providerTrackId']),
      isrc: serializer.fromJson<String?>(json['isrc']),
      title: serializer.fromJson<String>(json['title']),
      titleNorm: serializer.fromJson<String>(json['titleNorm']),
      artistsJson: serializer.fromJson<String>(json['artistsJson']),
      album: serializer.fromJson<String?>(json['album']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      releaseYear: serializer.fromJson<int?>(json['releaseYear']),
      explicit: serializer.fromJson<bool?>(json['explicit']),
      popularity: serializer.fromJson<int?>(json['popularity']),
      rawJson: serializer.fromJson<String?>(json['rawJson']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String>(providerId),
      'providerTrackId': serializer.toJson<String>(providerTrackId),
      'isrc': serializer.toJson<String?>(isrc),
      'title': serializer.toJson<String>(title),
      'titleNorm': serializer.toJson<String>(titleNorm),
      'artistsJson': serializer.toJson<String>(artistsJson),
      'album': serializer.toJson<String?>(album),
      'durationMs': serializer.toJson<int?>(durationMs),
      'releaseYear': serializer.toJson<int?>(releaseYear),
      'explicit': serializer.toJson<bool?>(explicit),
      'popularity': serializer.toJson<int?>(popularity),
      'rawJson': serializer.toJson<String?>(rawJson),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  TrackSnapshot copyWith({
    String? id,
    String? providerId,
    String? providerTrackId,
    Value<String?> isrc = const Value.absent(),
    String? title,
    String? titleNorm,
    String? artistsJson,
    Value<String?> album = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<int?> releaseYear = const Value.absent(),
    Value<bool?> explicit = const Value.absent(),
    Value<int?> popularity = const Value.absent(),
    Value<String?> rawJson = const Value.absent(),
    DateTime? fetchedAt,
  }) => TrackSnapshot(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    providerTrackId: providerTrackId ?? this.providerTrackId,
    isrc: isrc.present ? isrc.value : this.isrc,
    title: title ?? this.title,
    titleNorm: titleNorm ?? this.titleNorm,
    artistsJson: artistsJson ?? this.artistsJson,
    album: album.present ? album.value : this.album,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    releaseYear: releaseYear.present ? releaseYear.value : this.releaseYear,
    explicit: explicit.present ? explicit.value : this.explicit,
    popularity: popularity.present ? popularity.value : this.popularity,
    rawJson: rawJson.present ? rawJson.value : this.rawJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  TrackSnapshot copyWithCompanion(TrackSnapshotsCompanion data) {
    return TrackSnapshot(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      providerTrackId: data.providerTrackId.present
          ? data.providerTrackId.value
          : this.providerTrackId,
      isrc: data.isrc.present ? data.isrc.value : this.isrc,
      title: data.title.present ? data.title.value : this.title,
      titleNorm: data.titleNorm.present ? data.titleNorm.value : this.titleNorm,
      artistsJson: data.artistsJson.present
          ? data.artistsJson.value
          : this.artistsJson,
      album: data.album.present ? data.album.value : this.album,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      releaseYear: data.releaseYear.present
          ? data.releaseYear.value
          : this.releaseYear,
      explicit: data.explicit.present ? data.explicit.value : this.explicit,
      popularity: data.popularity.present
          ? data.popularity.value
          : this.popularity,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackSnapshot(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('providerTrackId: $providerTrackId, ')
          ..write('isrc: $isrc, ')
          ..write('title: $title, ')
          ..write('titleNorm: $titleNorm, ')
          ..write('artistsJson: $artistsJson, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('explicit: $explicit, ')
          ..write('popularity: $popularity, ')
          ..write('rawJson: $rawJson, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerId,
    providerTrackId,
    isrc,
    title,
    titleNorm,
    artistsJson,
    album,
    durationMs,
    releaseYear,
    explicit,
    popularity,
    rawJson,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackSnapshot &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.providerTrackId == this.providerTrackId &&
          other.isrc == this.isrc &&
          other.title == this.title &&
          other.titleNorm == this.titleNorm &&
          other.artistsJson == this.artistsJson &&
          other.album == this.album &&
          other.durationMs == this.durationMs &&
          other.releaseYear == this.releaseYear &&
          other.explicit == this.explicit &&
          other.popularity == this.popularity &&
          other.rawJson == this.rawJson &&
          other.fetchedAt == this.fetchedAt);
}

class TrackSnapshotsCompanion extends UpdateCompanion<TrackSnapshot> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> providerTrackId;
  final Value<String?> isrc;
  final Value<String> title;
  final Value<String> titleNorm;
  final Value<String> artistsJson;
  final Value<String?> album;
  final Value<int?> durationMs;
  final Value<int?> releaseYear;
  final Value<bool?> explicit;
  final Value<int?> popularity;
  final Value<String?> rawJson;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const TrackSnapshotsCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.providerTrackId = const Value.absent(),
    this.isrc = const Value.absent(),
    this.title = const Value.absent(),
    this.titleNorm = const Value.absent(),
    this.artistsJson = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.explicit = const Value.absent(),
    this.popularity = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackSnapshotsCompanion.insert({
    required String id,
    required String providerId,
    required String providerTrackId,
    this.isrc = const Value.absent(),
    required String title,
    required String titleNorm,
    required String artistsJson,
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.explicit = const Value.absent(),
    this.popularity = const Value.absent(),
    this.rawJson = const Value.absent(),
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerId = Value(providerId),
       providerTrackId = Value(providerTrackId),
       title = Value(title),
       titleNorm = Value(titleNorm),
       artistsJson = Value(artistsJson),
       fetchedAt = Value(fetchedAt);
  static Insertable<TrackSnapshot> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? providerTrackId,
    Expression<String>? isrc,
    Expression<String>? title,
    Expression<String>? titleNorm,
    Expression<String>? artistsJson,
    Expression<String>? album,
    Expression<int>? durationMs,
    Expression<int>? releaseYear,
    Expression<bool>? explicit,
    Expression<int>? popularity,
    Expression<String>? rawJson,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (providerTrackId != null) 'provider_track_id': providerTrackId,
      if (isrc != null) 'isrc': isrc,
      if (title != null) 'title': title,
      if (titleNorm != null) 'title_norm': titleNorm,
      if (artistsJson != null) 'artists_json': artistsJson,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (releaseYear != null) 'release_year': releaseYear,
      if (explicit != null) 'explicit': explicit,
      if (popularity != null) 'popularity': popularity,
      if (rawJson != null) 'raw_json': rawJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? providerId,
    Value<String>? providerTrackId,
    Value<String?>? isrc,
    Value<String>? title,
    Value<String>? titleNorm,
    Value<String>? artistsJson,
    Value<String?>? album,
    Value<int?>? durationMs,
    Value<int?>? releaseYear,
    Value<bool?>? explicit,
    Value<int?>? popularity,
    Value<String?>? rawJson,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return TrackSnapshotsCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerTrackId: providerTrackId ?? this.providerTrackId,
      isrc: isrc ?? this.isrc,
      title: title ?? this.title,
      titleNorm: titleNorm ?? this.titleNorm,
      artistsJson: artistsJson ?? this.artistsJson,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      releaseYear: releaseYear ?? this.releaseYear,
      explicit: explicit ?? this.explicit,
      popularity: popularity ?? this.popularity,
      rawJson: rawJson ?? this.rawJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (providerTrackId.present) {
      map['provider_track_id'] = Variable<String>(providerTrackId.value);
    }
    if (isrc.present) {
      map['isrc'] = Variable<String>(isrc.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (titleNorm.present) {
      map['title_norm'] = Variable<String>(titleNorm.value);
    }
    if (artistsJson.present) {
      map['artists_json'] = Variable<String>(artistsJson.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (releaseYear.present) {
      map['release_year'] = Variable<int>(releaseYear.value);
    }
    if (explicit.present) {
      map['explicit'] = Variable<bool>(explicit.value);
    }
    if (popularity.present) {
      map['popularity'] = Variable<int>(popularity.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('providerTrackId: $providerTrackId, ')
          ..write('isrc: $isrc, ')
          ..write('title: $title, ')
          ..write('titleNorm: $titleNorm, ')
          ..write('artistsJson: $artistsJson, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('explicit: $explicit, ')
          ..write('popularity: $popularity, ')
          ..write('rawJson: $rawJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackMappingsTable extends TrackMappings
    with TableInfo<$TrackMappingsTable, TrackMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _srcTrackIdMeta = const VerificationMeta(
    'srcTrackId',
  );
  @override
  late final GeneratedColumn<String> srcTrackId = GeneratedColumn<String>(
    'src_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES track_snapshots (id) ON DELETE CASCADE',
  );
  static const VerificationMeta _dstProviderIdMeta = const VerificationMeta(
    'dstProviderId',
  );
  @override
  late final GeneratedColumn<String> dstProviderId = GeneratedColumn<String>(
    'dst_provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dstProviderTrackIdMeta =
      const VerificationMeta('dstProviderTrackId');
  @override
  late final GeneratedColumn<String> dstProviderTrackId =
      GeneratedColumn<String>(
        'dst_provider_track_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchMethodMeta = const VerificationMeta(
    'matchMethod',
  );
  @override
  late final GeneratedColumn<String> matchMethod = GeneratedColumn<String>(
    'match_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signalsJsonMeta = const VerificationMeta(
    'signalsJson',
  );
  @override
  late final GeneratedColumn<String> signalsJson = GeneratedColumn<String>(
    'signals_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _decidedByMeta = const VerificationMeta(
    'decidedBy',
  );
  @override
  late final GeneratedColumn<String> decidedBy = GeneratedColumn<String>(
    'decided_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    srcTrackId,
    dstProviderId,
    dstProviderTrackId,
    confidence,
    matchMethod,
    signalsJson,
    decidedBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_mappings';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackMapping> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('src_track_id')) {
      context.handle(
        _srcTrackIdMeta,
        srcTrackId.isAcceptableOrUnknown(
          data['src_track_id']!,
          _srcTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_srcTrackIdMeta);
    }
    if (data.containsKey('dst_provider_id')) {
      context.handle(
        _dstProviderIdMeta,
        dstProviderId.isAcceptableOrUnknown(
          data['dst_provider_id']!,
          _dstProviderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dstProviderIdMeta);
    }
    if (data.containsKey('dst_provider_track_id')) {
      context.handle(
        _dstProviderTrackIdMeta,
        dstProviderTrackId.isAcceptableOrUnknown(
          data['dst_provider_track_id']!,
          _dstProviderTrackIdMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('match_method')) {
      context.handle(
        _matchMethodMeta,
        matchMethod.isAcceptableOrUnknown(
          data['match_method']!,
          _matchMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_matchMethodMeta);
    }
    if (data.containsKey('signals_json')) {
      context.handle(
        _signalsJsonMeta,
        signalsJson.isAcceptableOrUnknown(
          data['signals_json']!,
          _signalsJsonMeta,
        ),
      );
    }
    if (data.containsKey('decided_by')) {
      context.handle(
        _decidedByMeta,
        decidedBy.isAcceptableOrUnknown(data['decided_by']!, _decidedByMeta),
      );
    } else if (isInserting) {
      context.missing(_decidedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {srcTrackId, dstProviderId},
  ];
  @override
  TrackMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackMapping(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      srcTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}src_track_id'],
      )!,
      dstProviderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dst_provider_id'],
      )!,
      dstProviderTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dst_provider_track_id'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      matchMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_method'],
      )!,
      signalsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signals_json'],
      )!,
      decidedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decided_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TrackMappingsTable createAlias(String alias) {
    return $TrackMappingsTable(attachedDatabase, alias);
  }
}

class TrackMapping extends DataClass implements Insertable<TrackMapping> {
  /// `srcTrackRowId->dstProviderId`.
  final String id;
  final String srcTrackId;
  final String dstProviderId;

  /// Null = confirmed miss (memoized "no match exists", docs/05 §4.2).
  final String? dstProviderTrackId;
  final double confidence;
  final String matchMethod;
  final String signalsJson;
  final String decidedBy;
  final DateTime createdAt;
  const TrackMapping({
    required this.id,
    required this.srcTrackId,
    required this.dstProviderId,
    this.dstProviderTrackId,
    required this.confidence,
    required this.matchMethod,
    required this.signalsJson,
    required this.decidedBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['src_track_id'] = Variable<String>(srcTrackId);
    map['dst_provider_id'] = Variable<String>(dstProviderId);
    if (!nullToAbsent || dstProviderTrackId != null) {
      map['dst_provider_track_id'] = Variable<String>(dstProviderTrackId);
    }
    map['confidence'] = Variable<double>(confidence);
    map['match_method'] = Variable<String>(matchMethod);
    map['signals_json'] = Variable<String>(signalsJson);
    map['decided_by'] = Variable<String>(decidedBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TrackMappingsCompanion toCompanion(bool nullToAbsent) {
    return TrackMappingsCompanion(
      id: Value(id),
      srcTrackId: Value(srcTrackId),
      dstProviderId: Value(dstProviderId),
      dstProviderTrackId: dstProviderTrackId == null && nullToAbsent
          ? const Value.absent()
          : Value(dstProviderTrackId),
      confidence: Value(confidence),
      matchMethod: Value(matchMethod),
      signalsJson: Value(signalsJson),
      decidedBy: Value(decidedBy),
      createdAt: Value(createdAt),
    );
  }

  factory TrackMapping.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackMapping(
      id: serializer.fromJson<String>(json['id']),
      srcTrackId: serializer.fromJson<String>(json['srcTrackId']),
      dstProviderId: serializer.fromJson<String>(json['dstProviderId']),
      dstProviderTrackId: serializer.fromJson<String?>(
        json['dstProviderTrackId'],
      ),
      confidence: serializer.fromJson<double>(json['confidence']),
      matchMethod: serializer.fromJson<String>(json['matchMethod']),
      signalsJson: serializer.fromJson<String>(json['signalsJson']),
      decidedBy: serializer.fromJson<String>(json['decidedBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'srcTrackId': serializer.toJson<String>(srcTrackId),
      'dstProviderId': serializer.toJson<String>(dstProviderId),
      'dstProviderTrackId': serializer.toJson<String?>(dstProviderTrackId),
      'confidence': serializer.toJson<double>(confidence),
      'matchMethod': serializer.toJson<String>(matchMethod),
      'signalsJson': serializer.toJson<String>(signalsJson),
      'decidedBy': serializer.toJson<String>(decidedBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TrackMapping copyWith({
    String? id,
    String? srcTrackId,
    String? dstProviderId,
    Value<String?> dstProviderTrackId = const Value.absent(),
    double? confidence,
    String? matchMethod,
    String? signalsJson,
    String? decidedBy,
    DateTime? createdAt,
  }) => TrackMapping(
    id: id ?? this.id,
    srcTrackId: srcTrackId ?? this.srcTrackId,
    dstProviderId: dstProviderId ?? this.dstProviderId,
    dstProviderTrackId: dstProviderTrackId.present
        ? dstProviderTrackId.value
        : this.dstProviderTrackId,
    confidence: confidence ?? this.confidence,
    matchMethod: matchMethod ?? this.matchMethod,
    signalsJson: signalsJson ?? this.signalsJson,
    decidedBy: decidedBy ?? this.decidedBy,
    createdAt: createdAt ?? this.createdAt,
  );
  TrackMapping copyWithCompanion(TrackMappingsCompanion data) {
    return TrackMapping(
      id: data.id.present ? data.id.value : this.id,
      srcTrackId: data.srcTrackId.present
          ? data.srcTrackId.value
          : this.srcTrackId,
      dstProviderId: data.dstProviderId.present
          ? data.dstProviderId.value
          : this.dstProviderId,
      dstProviderTrackId: data.dstProviderTrackId.present
          ? data.dstProviderTrackId.value
          : this.dstProviderTrackId,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      matchMethod: data.matchMethod.present
          ? data.matchMethod.value
          : this.matchMethod,
      signalsJson: data.signalsJson.present
          ? data.signalsJson.value
          : this.signalsJson,
      decidedBy: data.decidedBy.present ? data.decidedBy.value : this.decidedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackMapping(')
          ..write('id: $id, ')
          ..write('srcTrackId: $srcTrackId, ')
          ..write('dstProviderId: $dstProviderId, ')
          ..write('dstProviderTrackId: $dstProviderTrackId, ')
          ..write('confidence: $confidence, ')
          ..write('matchMethod: $matchMethod, ')
          ..write('signalsJson: $signalsJson, ')
          ..write('decidedBy: $decidedBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    srcTrackId,
    dstProviderId,
    dstProviderTrackId,
    confidence,
    matchMethod,
    signalsJson,
    decidedBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackMapping &&
          other.id == this.id &&
          other.srcTrackId == this.srcTrackId &&
          other.dstProviderId == this.dstProviderId &&
          other.dstProviderTrackId == this.dstProviderTrackId &&
          other.confidence == this.confidence &&
          other.matchMethod == this.matchMethod &&
          other.signalsJson == this.signalsJson &&
          other.decidedBy == this.decidedBy &&
          other.createdAt == this.createdAt);
}

class TrackMappingsCompanion extends UpdateCompanion<TrackMapping> {
  final Value<String> id;
  final Value<String> srcTrackId;
  final Value<String> dstProviderId;
  final Value<String?> dstProviderTrackId;
  final Value<double> confidence;
  final Value<String> matchMethod;
  final Value<String> signalsJson;
  final Value<String> decidedBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TrackMappingsCompanion({
    this.id = const Value.absent(),
    this.srcTrackId = const Value.absent(),
    this.dstProviderId = const Value.absent(),
    this.dstProviderTrackId = const Value.absent(),
    this.confidence = const Value.absent(),
    this.matchMethod = const Value.absent(),
    this.signalsJson = const Value.absent(),
    this.decidedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackMappingsCompanion.insert({
    required String id,
    required String srcTrackId,
    required String dstProviderId,
    this.dstProviderTrackId = const Value.absent(),
    required double confidence,
    required String matchMethod,
    this.signalsJson = const Value.absent(),
    required String decidedBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       srcTrackId = Value(srcTrackId),
       dstProviderId = Value(dstProviderId),
       confidence = Value(confidence),
       matchMethod = Value(matchMethod),
       decidedBy = Value(decidedBy),
       createdAt = Value(createdAt);
  static Insertable<TrackMapping> custom({
    Expression<String>? id,
    Expression<String>? srcTrackId,
    Expression<String>? dstProviderId,
    Expression<String>? dstProviderTrackId,
    Expression<double>? confidence,
    Expression<String>? matchMethod,
    Expression<String>? signalsJson,
    Expression<String>? decidedBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (srcTrackId != null) 'src_track_id': srcTrackId,
      if (dstProviderId != null) 'dst_provider_id': dstProviderId,
      if (dstProviderTrackId != null)
        'dst_provider_track_id': dstProviderTrackId,
      if (confidence != null) 'confidence': confidence,
      if (matchMethod != null) 'match_method': matchMethod,
      if (signalsJson != null) 'signals_json': signalsJson,
      if (decidedBy != null) 'decided_by': decidedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackMappingsCompanion copyWith({
    Value<String>? id,
    Value<String>? srcTrackId,
    Value<String>? dstProviderId,
    Value<String?>? dstProviderTrackId,
    Value<double>? confidence,
    Value<String>? matchMethod,
    Value<String>? signalsJson,
    Value<String>? decidedBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TrackMappingsCompanion(
      id: id ?? this.id,
      srcTrackId: srcTrackId ?? this.srcTrackId,
      dstProviderId: dstProviderId ?? this.dstProviderId,
      dstProviderTrackId: dstProviderTrackId ?? this.dstProviderTrackId,
      confidence: confidence ?? this.confidence,
      matchMethod: matchMethod ?? this.matchMethod,
      signalsJson: signalsJson ?? this.signalsJson,
      decidedBy: decidedBy ?? this.decidedBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (srcTrackId.present) {
      map['src_track_id'] = Variable<String>(srcTrackId.value);
    }
    if (dstProviderId.present) {
      map['dst_provider_id'] = Variable<String>(dstProviderId.value);
    }
    if (dstProviderTrackId.present) {
      map['dst_provider_track_id'] = Variable<String>(dstProviderTrackId.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (matchMethod.present) {
      map['match_method'] = Variable<String>(matchMethod.value);
    }
    if (signalsJson.present) {
      map['signals_json'] = Variable<String>(signalsJson.value);
    }
    if (decidedBy.present) {
      map['decided_by'] = Variable<String>(decidedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackMappingsCompanion(')
          ..write('id: $id, ')
          ..write('srcTrackId: $srcTrackId, ')
          ..write('dstProviderId: $dstProviderId, ')
          ..write('dstProviderTrackId: $dstProviderTrackId, ')
          ..write('confidence: $confidence, ')
          ..write('matchMethod: $matchMethod, ')
          ..write('signalsJson: $signalsJson, ')
          ..write('decidedBy: $decidedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistSnapshotsTable extends PlaylistSnapshots
    with TableInfo<$PlaylistSnapshotsTable, PlaylistSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES provider_accounts (id) ON DELETE CASCADE',
  );
  static const VerificationMeta _providerPlaylistIdMeta =
      const VerificationMeta('providerPlaylistId');
  @override
  late final GeneratedColumn<String> providerPlaylistId =
      GeneratedColumn<String>(
        'provider_playlist_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _privacyMeta = const VerificationMeta(
    'privacy',
  );
  @override
  late final GeneratedColumn<String> privacy = GeneratedColumn<String>(
    'privacy',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collaborativeMeta = const VerificationMeta(
    'collaborative',
  );
  @override
  late final GeneratedColumn<bool> collaborative = GeneratedColumn<bool>(
    'collaborative',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("collaborative" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _artworkUrlMeta = const VerificationMeta(
    'artworkUrl',
  );
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
    'artwork_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackCountMeta = const VerificationMeta(
    'trackCount',
  );
  @override
  late final GeneratedColumn<int> trackCount = GeneratedColumn<int>(
    'track_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerEtagMeta = const VerificationMeta(
    'providerEtag',
  );
  @override
  late final GeneratedColumn<String> providerEtag = GeneratedColumn<String>(
    'provider_etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    providerPlaylistId,
    name,
    description,
    privacy,
    collaborative,
    artworkUrl,
    trackCount,
    contentHash,
    providerEtag,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('provider_playlist_id')) {
      context.handle(
        _providerPlaylistIdMeta,
        providerPlaylistId.isAcceptableOrUnknown(
          data['provider_playlist_id']!,
          _providerPlaylistIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerPlaylistIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('privacy')) {
      context.handle(
        _privacyMeta,
        privacy.isAcceptableOrUnknown(data['privacy']!, _privacyMeta),
      );
    }
    if (data.containsKey('collaborative')) {
      context.handle(
        _collaborativeMeta,
        collaborative.isAcceptableOrUnknown(
          data['collaborative']!,
          _collaborativeMeta,
        ),
      );
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
        _artworkUrlMeta,
        artworkUrl.isAcceptableOrUnknown(data['artwork_url']!, _artworkUrlMeta),
      );
    }
    if (data.containsKey('track_count')) {
      context.handle(
        _trackCountMeta,
        trackCount.isAcceptableOrUnknown(data['track_count']!, _trackCountMeta),
      );
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('provider_etag')) {
      context.handle(
        _providerEtagMeta,
        providerEtag.isAcceptableOrUnknown(
          data['provider_etag']!,
          _providerEtagMeta,
        ),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {accountId, providerPlaylistId},
  ];
  @override
  PlaylistSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      providerPlaylistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_playlist_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      privacy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy'],
      ),
      collaborative: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}collaborative'],
      )!,
      artworkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_url'],
      ),
      trackCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_count'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      providerEtag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_etag'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $PlaylistSnapshotsTable createAlias(String alias) {
    return $PlaylistSnapshotsTable(attachedDatabase, alias);
  }
}

class PlaylistSnapshot extends DataClass
    implements Insertable<PlaylistSnapshot> {
  /// `accountRowId:providerPlaylistId`.
  final String id;
  final String accountId;
  final String providerPlaylistId;
  final String name;
  final String? description;
  final String? privacy;
  final bool collaborative;
  final String? artworkUrl;
  final int trackCount;

  /// Digest of the ordered track-id list → O(1) change detection.
  final String contentHash;
  final String? providerEtag;
  final DateTime fetchedAt;
  const PlaylistSnapshot({
    required this.id,
    required this.accountId,
    required this.providerPlaylistId,
    required this.name,
    this.description,
    this.privacy,
    required this.collaborative,
    this.artworkUrl,
    required this.trackCount,
    required this.contentHash,
    this.providerEtag,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['provider_playlist_id'] = Variable<String>(providerPlaylistId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || privacy != null) {
      map['privacy'] = Variable<String>(privacy);
    }
    map['collaborative'] = Variable<bool>(collaborative);
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    map['track_count'] = Variable<int>(trackCount);
    map['content_hash'] = Variable<String>(contentHash);
    if (!nullToAbsent || providerEtag != null) {
      map['provider_etag'] = Variable<String>(providerEtag);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  PlaylistSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistSnapshotsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      providerPlaylistId: Value(providerPlaylistId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      privacy: privacy == null && nullToAbsent
          ? const Value.absent()
          : Value(privacy),
      collaborative: Value(collaborative),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      trackCount: Value(trackCount),
      contentHash: Value(contentHash),
      providerEtag: providerEtag == null && nullToAbsent
          ? const Value.absent()
          : Value(providerEtag),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory PlaylistSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistSnapshot(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      providerPlaylistId: serializer.fromJson<String>(
        json['providerPlaylistId'],
      ),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      privacy: serializer.fromJson<String?>(json['privacy']),
      collaborative: serializer.fromJson<bool>(json['collaborative']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      trackCount: serializer.fromJson<int>(json['trackCount']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      providerEtag: serializer.fromJson<String?>(json['providerEtag']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'providerPlaylistId': serializer.toJson<String>(providerPlaylistId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'privacy': serializer.toJson<String?>(privacy),
      'collaborative': serializer.toJson<bool>(collaborative),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'trackCount': serializer.toJson<int>(trackCount),
      'contentHash': serializer.toJson<String>(contentHash),
      'providerEtag': serializer.toJson<String?>(providerEtag),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  PlaylistSnapshot copyWith({
    String? id,
    String? accountId,
    String? providerPlaylistId,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> privacy = const Value.absent(),
    bool? collaborative,
    Value<String?> artworkUrl = const Value.absent(),
    int? trackCount,
    String? contentHash,
    Value<String?> providerEtag = const Value.absent(),
    DateTime? fetchedAt,
  }) => PlaylistSnapshot(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    providerPlaylistId: providerPlaylistId ?? this.providerPlaylistId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    privacy: privacy.present ? privacy.value : this.privacy,
    collaborative: collaborative ?? this.collaborative,
    artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
    trackCount: trackCount ?? this.trackCount,
    contentHash: contentHash ?? this.contentHash,
    providerEtag: providerEtag.present ? providerEtag.value : this.providerEtag,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  PlaylistSnapshot copyWithCompanion(PlaylistSnapshotsCompanion data) {
    return PlaylistSnapshot(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      providerPlaylistId: data.providerPlaylistId.present
          ? data.providerPlaylistId.value
          : this.providerPlaylistId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      privacy: data.privacy.present ? data.privacy.value : this.privacy,
      collaborative: data.collaborative.present
          ? data.collaborative.value
          : this.collaborative,
      artworkUrl: data.artworkUrl.present
          ? data.artworkUrl.value
          : this.artworkUrl,
      trackCount: data.trackCount.present
          ? data.trackCount.value
          : this.trackCount,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      providerEtag: data.providerEtag.present
          ? data.providerEtag.value
          : this.providerEtag,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSnapshot(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('providerPlaylistId: $providerPlaylistId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('privacy: $privacy, ')
          ..write('collaborative: $collaborative, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('trackCount: $trackCount, ')
          ..write('contentHash: $contentHash, ')
          ..write('providerEtag: $providerEtag, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    providerPlaylistId,
    name,
    description,
    privacy,
    collaborative,
    artworkUrl,
    trackCount,
    contentHash,
    providerEtag,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistSnapshot &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.providerPlaylistId == this.providerPlaylistId &&
          other.name == this.name &&
          other.description == this.description &&
          other.privacy == this.privacy &&
          other.collaborative == this.collaborative &&
          other.artworkUrl == this.artworkUrl &&
          other.trackCount == this.trackCount &&
          other.contentHash == this.contentHash &&
          other.providerEtag == this.providerEtag &&
          other.fetchedAt == this.fetchedAt);
}

class PlaylistSnapshotsCompanion extends UpdateCompanion<PlaylistSnapshot> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> providerPlaylistId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> privacy;
  final Value<bool> collaborative;
  final Value<String?> artworkUrl;
  final Value<int> trackCount;
  final Value<String> contentHash;
  final Value<String?> providerEtag;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const PlaylistSnapshotsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.providerPlaylistId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.privacy = const Value.absent(),
    this.collaborative = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.providerEtag = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistSnapshotsCompanion.insert({
    required String id,
    required String accountId,
    required String providerPlaylistId,
    required String name,
    this.description = const Value.absent(),
    this.privacy = const Value.absent(),
    this.collaborative = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.trackCount = const Value.absent(),
    required String contentHash,
    this.providerEtag = const Value.absent(),
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       providerPlaylistId = Value(providerPlaylistId),
       name = Value(name),
       contentHash = Value(contentHash),
       fetchedAt = Value(fetchedAt);
  static Insertable<PlaylistSnapshot> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? providerPlaylistId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? privacy,
    Expression<bool>? collaborative,
    Expression<String>? artworkUrl,
    Expression<int>? trackCount,
    Expression<String>? contentHash,
    Expression<String>? providerEtag,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (providerPlaylistId != null)
        'provider_playlist_id': providerPlaylistId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (privacy != null) 'privacy': privacy,
      if (collaborative != null) 'collaborative': collaborative,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (trackCount != null) 'track_count': trackCount,
      if (contentHash != null) 'content_hash': contentHash,
      if (providerEtag != null) 'provider_etag': providerEtag,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String>? providerPlaylistId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? privacy,
    Value<bool>? collaborative,
    Value<String?>? artworkUrl,
    Value<int>? trackCount,
    Value<String>? contentHash,
    Value<String?>? providerEtag,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return PlaylistSnapshotsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      providerPlaylistId: providerPlaylistId ?? this.providerPlaylistId,
      name: name ?? this.name,
      description: description ?? this.description,
      privacy: privacy ?? this.privacy,
      collaborative: collaborative ?? this.collaborative,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      trackCount: trackCount ?? this.trackCount,
      contentHash: contentHash ?? this.contentHash,
      providerEtag: providerEtag ?? this.providerEtag,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (providerPlaylistId.present) {
      map['provider_playlist_id'] = Variable<String>(providerPlaylistId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (privacy.present) {
      map['privacy'] = Variable<String>(privacy.value);
    }
    if (collaborative.present) {
      map['collaborative'] = Variable<bool>(collaborative.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (trackCount.present) {
      map['track_count'] = Variable<int>(trackCount.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (providerEtag.present) {
      map['provider_etag'] = Variable<String>(providerEtag.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('providerPlaylistId: $providerPlaylistId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('privacy: $privacy, ')
          ..write('collaborative: $collaborative, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('trackCount: $trackCount, ')
          ..write('contentHash: $contentHash, ')
          ..write('providerEtag: $providerEtag, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTrackSnapshotsTable extends PlaylistTrackSnapshots
    with TableInfo<$PlaylistTrackSnapshotsTable, PlaylistTrackSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTrackSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES playlist_snapshots (id) ON DELETE CASCADE',
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES track_snapshots (id)',
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playlistId,
    trackId,
    position,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_track_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistTrackSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, position};
  @override
  PlaylistTrackSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTrackSnapshot(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      ),
    );
  }

  @override
  $PlaylistTrackSnapshotsTable createAlias(String alias) {
    return $PlaylistTrackSnapshotsTable(attachedDatabase, alias);
  }
}

class PlaylistTrackSnapshot extends DataClass
    implements Insertable<PlaylistTrackSnapshot> {
  final String playlistId;
  final String trackId;
  final int position;
  final DateTime? addedAt;
  const PlaylistTrackSnapshot({
    required this.playlistId,
    required this.trackId,
    required this.position,
    this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['track_id'] = Variable<String>(trackId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<DateTime>(addedAt);
    }
    return map;
  }

  PlaylistTrackSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTrackSnapshotsCompanion(
      playlistId: Value(playlistId),
      trackId: Value(trackId),
      position: Value(position),
      addedAt: addedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAt),
    );
  }

  factory PlaylistTrackSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTrackSnapshot(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      position: serializer.fromJson<int>(json['position']),
      addedAt: serializer.fromJson<DateTime?>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'trackId': serializer.toJson<String>(trackId),
      'position': serializer.toJson<int>(position),
      'addedAt': serializer.toJson<DateTime?>(addedAt),
    };
  }

  PlaylistTrackSnapshot copyWith({
    String? playlistId,
    String? trackId,
    int? position,
    Value<DateTime?> addedAt = const Value.absent(),
  }) => PlaylistTrackSnapshot(
    playlistId: playlistId ?? this.playlistId,
    trackId: trackId ?? this.trackId,
    position: position ?? this.position,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
  );
  PlaylistTrackSnapshot copyWithCompanion(
    PlaylistTrackSnapshotsCompanion data,
  ) {
    return PlaylistTrackSnapshot(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      position: data.position.present ? data.position.value : this.position,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTrackSnapshot(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, trackId, position, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTrackSnapshot &&
          other.playlistId == this.playlistId &&
          other.trackId == this.trackId &&
          other.position == this.position &&
          other.addedAt == this.addedAt);
}

class PlaylistTrackSnapshotsCompanion
    extends UpdateCompanion<PlaylistTrackSnapshot> {
  final Value<String> playlistId;
  final Value<String> trackId;
  final Value<int> position;
  final Value<DateTime?> addedAt;
  final Value<int> rowid;
  const PlaylistTrackSnapshotsCompanion({
    this.playlistId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistTrackSnapshotsCompanion.insert({
    required String playlistId,
    required String trackId,
    required int position,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       trackId = Value(trackId),
       position = Value(position);
  static Insertable<PlaylistTrackSnapshot> custom({
    Expression<String>? playlistId,
    Expression<String>? trackId,
    Expression<int>? position,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (trackId != null) 'track_id': trackId,
      if (position != null) 'position': position,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistTrackSnapshotsCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? trackId,
    Value<int>? position,
    Value<DateTime?>? addedAt,
    Value<int>? rowid,
  }) {
    return PlaylistTrackSnapshotsCompanion(
      playlistId: playlistId ?? this.playlistId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTrackSnapshotsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransferJobsTable extends TransferJobs
    with TableInfo<$TransferJobsTable, TransferJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransferJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _srcAccountIdMeta = const VerificationMeta(
    'srcAccountId',
  );
  @override
  late final GeneratedColumn<String> srcAccountId = GeneratedColumn<String>(
    'src_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES provider_accounts (id)',
  );
  static const VerificationMeta _dstAccountIdMeta = const VerificationMeta(
    'dstAccountId',
  );
  @override
  late final GeneratedColumn<String> dstAccountId = GeneratedColumn<String>(
    'dst_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES provider_accounts (id)',
  );
  static const VerificationMeta _specJsonMeta = const VerificationMeta(
    'specJson',
  );
  @override
  late final GeneratedColumn<String> specJson = GeneratedColumn<String>(
    'spec_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressDoneMeta = const VerificationMeta(
    'progressDone',
  );
  @override
  late final GeneratedColumn<int> progressDone = GeneratedColumn<int>(
    'progress_done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressTotalMeta = const VerificationMeta(
    'progressTotal',
  );
  @override
  late final GeneratedColumn<int> progressTotal = GeneratedColumn<int>(
    'progress_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorJsonMeta = const VerificationMeta(
    'errorJson',
  );
  @override
  late final GeneratedColumn<String> errorJson = GeneratedColumn<String>(
    'error_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    srcAccountId,
    dstAccountId,
    specJson,
    state,
    progressDone,
    progressTotal,
    errorJson,
    createdAt,
    updatedAt,
    finishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfer_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransferJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('src_account_id')) {
      context.handle(
        _srcAccountIdMeta,
        srcAccountId.isAcceptableOrUnknown(
          data['src_account_id']!,
          _srcAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_srcAccountIdMeta);
    }
    if (data.containsKey('dst_account_id')) {
      context.handle(
        _dstAccountIdMeta,
        dstAccountId.isAcceptableOrUnknown(
          data['dst_account_id']!,
          _dstAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dstAccountIdMeta);
    }
    if (data.containsKey('spec_json')) {
      context.handle(
        _specJsonMeta,
        specJson.isAcceptableOrUnknown(data['spec_json']!, _specJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_specJsonMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('progress_done')) {
      context.handle(
        _progressDoneMeta,
        progressDone.isAcceptableOrUnknown(
          data['progress_done']!,
          _progressDoneMeta,
        ),
      );
    }
    if (data.containsKey('progress_total')) {
      context.handle(
        _progressTotalMeta,
        progressTotal.isAcceptableOrUnknown(
          data['progress_total']!,
          _progressTotalMeta,
        ),
      );
    }
    if (data.containsKey('error_json')) {
      context.handle(
        _errorJsonMeta,
        errorJson.isAcceptableOrUnknown(data['error_json']!, _errorJsonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransferJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransferJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      srcAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}src_account_id'],
      )!,
      dstAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dst_account_id'],
      )!,
      specJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spec_json'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      progressDone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_done'],
      )!,
      progressTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_total'],
      )!,
      errorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
    );
  }

  @override
  $TransferJobsTable createAlias(String alias) {
    return $TransferJobsTable(attachedDatabase, alias);
  }
}

class TransferJob extends DataClass implements Insertable<TransferJob> {
  final String id;
  final String kind;
  final String srcAccountId;
  final String dstAccountId;
  final String specJson;
  final String state;
  final int progressDone;
  final int progressTotal;
  final String? errorJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? finishedAt;
  const TransferJob({
    required this.id,
    required this.kind,
    required this.srcAccountId,
    required this.dstAccountId,
    required this.specJson,
    required this.state,
    required this.progressDone,
    required this.progressTotal,
    this.errorJson,
    required this.createdAt,
    required this.updatedAt,
    this.finishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['src_account_id'] = Variable<String>(srcAccountId);
    map['dst_account_id'] = Variable<String>(dstAccountId);
    map['spec_json'] = Variable<String>(specJson);
    map['state'] = Variable<String>(state);
    map['progress_done'] = Variable<int>(progressDone);
    map['progress_total'] = Variable<int>(progressTotal);
    if (!nullToAbsent || errorJson != null) {
      map['error_json'] = Variable<String>(errorJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    return map;
  }

  TransferJobsCompanion toCompanion(bool nullToAbsent) {
    return TransferJobsCompanion(
      id: Value(id),
      kind: Value(kind),
      srcAccountId: Value(srcAccountId),
      dstAccountId: Value(dstAccountId),
      specJson: Value(specJson),
      state: Value(state),
      progressDone: Value(progressDone),
      progressTotal: Value(progressTotal),
      errorJson: errorJson == null && nullToAbsent
          ? const Value.absent()
          : Value(errorJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
    );
  }

  factory TransferJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransferJob(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      srcAccountId: serializer.fromJson<String>(json['srcAccountId']),
      dstAccountId: serializer.fromJson<String>(json['dstAccountId']),
      specJson: serializer.fromJson<String>(json['specJson']),
      state: serializer.fromJson<String>(json['state']),
      progressDone: serializer.fromJson<int>(json['progressDone']),
      progressTotal: serializer.fromJson<int>(json['progressTotal']),
      errorJson: serializer.fromJson<String?>(json['errorJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'srcAccountId': serializer.toJson<String>(srcAccountId),
      'dstAccountId': serializer.toJson<String>(dstAccountId),
      'specJson': serializer.toJson<String>(specJson),
      'state': serializer.toJson<String>(state),
      'progressDone': serializer.toJson<int>(progressDone),
      'progressTotal': serializer.toJson<int>(progressTotal),
      'errorJson': serializer.toJson<String?>(errorJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
    };
  }

  TransferJob copyWith({
    String? id,
    String? kind,
    String? srcAccountId,
    String? dstAccountId,
    String? specJson,
    String? state,
    int? progressDone,
    int? progressTotal,
    Value<String?> errorJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
  }) => TransferJob(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    srcAccountId: srcAccountId ?? this.srcAccountId,
    dstAccountId: dstAccountId ?? this.dstAccountId,
    specJson: specJson ?? this.specJson,
    state: state ?? this.state,
    progressDone: progressDone ?? this.progressDone,
    progressTotal: progressTotal ?? this.progressTotal,
    errorJson: errorJson.present ? errorJson.value : this.errorJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
  );
  TransferJob copyWithCompanion(TransferJobsCompanion data) {
    return TransferJob(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      srcAccountId: data.srcAccountId.present
          ? data.srcAccountId.value
          : this.srcAccountId,
      dstAccountId: data.dstAccountId.present
          ? data.dstAccountId.value
          : this.dstAccountId,
      specJson: data.specJson.present ? data.specJson.value : this.specJson,
      state: data.state.present ? data.state.value : this.state,
      progressDone: data.progressDone.present
          ? data.progressDone.value
          : this.progressDone,
      progressTotal: data.progressTotal.present
          ? data.progressTotal.value
          : this.progressTotal,
      errorJson: data.errorJson.present ? data.errorJson.value : this.errorJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransferJob(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('srcAccountId: $srcAccountId, ')
          ..write('dstAccountId: $dstAccountId, ')
          ..write('specJson: $specJson, ')
          ..write('state: $state, ')
          ..write('progressDone: $progressDone, ')
          ..write('progressTotal: $progressTotal, ')
          ..write('errorJson: $errorJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    srcAccountId,
    dstAccountId,
    specJson,
    state,
    progressDone,
    progressTotal,
    errorJson,
    createdAt,
    updatedAt,
    finishedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransferJob &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.srcAccountId == this.srcAccountId &&
          other.dstAccountId == this.dstAccountId &&
          other.specJson == this.specJson &&
          other.state == this.state &&
          other.progressDone == this.progressDone &&
          other.progressTotal == this.progressTotal &&
          other.errorJson == this.errorJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.finishedAt == this.finishedAt);
}

class TransferJobsCompanion extends UpdateCompanion<TransferJob> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> srcAccountId;
  final Value<String> dstAccountId;
  final Value<String> specJson;
  final Value<String> state;
  final Value<int> progressDone;
  final Value<int> progressTotal;
  final Value<String?> errorJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> rowid;
  const TransferJobsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.srcAccountId = const Value.absent(),
    this.dstAccountId = const Value.absent(),
    this.specJson = const Value.absent(),
    this.state = const Value.absent(),
    this.progressDone = const Value.absent(),
    this.progressTotal = const Value.absent(),
    this.errorJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransferJobsCompanion.insert({
    required String id,
    required String kind,
    required String srcAccountId,
    required String dstAccountId,
    required String specJson,
    required String state,
    this.progressDone = const Value.absent(),
    this.progressTotal = const Value.absent(),
    this.errorJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       srcAccountId = Value(srcAccountId),
       dstAccountId = Value(dstAccountId),
       specJson = Value(specJson),
       state = Value(state),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TransferJob> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? srcAccountId,
    Expression<String>? dstAccountId,
    Expression<String>? specJson,
    Expression<String>? state,
    Expression<int>? progressDone,
    Expression<int>? progressTotal,
    Expression<String>? errorJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (srcAccountId != null) 'src_account_id': srcAccountId,
      if (dstAccountId != null) 'dst_account_id': dstAccountId,
      if (specJson != null) 'spec_json': specJson,
      if (state != null) 'state': state,
      if (progressDone != null) 'progress_done': progressDone,
      if (progressTotal != null) 'progress_total': progressTotal,
      if (errorJson != null) 'error_json': errorJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransferJobsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? srcAccountId,
    Value<String>? dstAccountId,
    Value<String>? specJson,
    Value<String>? state,
    Value<int>? progressDone,
    Value<int>? progressTotal,
    Value<String?>? errorJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? rowid,
  }) {
    return TransferJobsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      srcAccountId: srcAccountId ?? this.srcAccountId,
      dstAccountId: dstAccountId ?? this.dstAccountId,
      specJson: specJson ?? this.specJson,
      state: state ?? this.state,
      progressDone: progressDone ?? this.progressDone,
      progressTotal: progressTotal ?? this.progressTotal,
      errorJson: errorJson ?? this.errorJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (srcAccountId.present) {
      map['src_account_id'] = Variable<String>(srcAccountId.value);
    }
    if (dstAccountId.present) {
      map['dst_account_id'] = Variable<String>(dstAccountId.value);
    }
    if (specJson.present) {
      map['spec_json'] = Variable<String>(specJson.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (progressDone.present) {
      map['progress_done'] = Variable<int>(progressDone.value);
    }
    if (progressTotal.present) {
      map['progress_total'] = Variable<int>(progressTotal.value);
    }
    if (errorJson.present) {
      map['error_json'] = Variable<String>(errorJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransferJobsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('srcAccountId: $srcAccountId, ')
          ..write('dstAccountId: $dstAccountId, ')
          ..write('specJson: $specJson, ')
          ..write('state: $state, ')
          ..write('progressDone: $progressDone, ')
          ..write('progressTotal: $progressTotal, ')
          ..write('errorJson: $errorJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobItemsTable extends JobItems with TableInfo<$JobItemsTable, JobItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES transfer_jobs (id) ON DELETE CASCADE',
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _srcTrackIdMeta = const VerificationMeta(
    'srcTrackId',
  );
  @override
  late final GeneratedColumn<String> srcTrackId = GeneratedColumn<String>(
    'src_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES track_snapshots (id)',
  );
  static const VerificationMeta _mappingIdMeta = const VerificationMeta(
    'mappingId',
  );
  @override
  late final GeneratedColumn<String> mappingId = GeneratedColumn<String>(
    'mapping_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL REFERENCES track_mappings (id)',
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedDstIdMeta = const VerificationMeta(
    'resolvedDstId',
  );
  @override
  late final GeneratedColumn<String> resolvedDstId = GeneratedColumn<String>(
    'resolved_dst_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    seq,
    srcTrackId,
    mappingId,
    state,
    resolvedDstId,
    attemptCount,
    nextRetryAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('src_track_id')) {
      context.handle(
        _srcTrackIdMeta,
        srcTrackId.isAcceptableOrUnknown(
          data['src_track_id']!,
          _srcTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_srcTrackIdMeta);
    }
    if (data.containsKey('mapping_id')) {
      context.handle(
        _mappingIdMeta,
        mappingId.isAcceptableOrUnknown(data['mapping_id']!, _mappingIdMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('resolved_dst_id')) {
      context.handle(
        _resolvedDstIdMeta,
        resolvedDstId.isAcceptableOrUnknown(
          data['resolved_dst_id']!,
          _resolvedDstIdMeta,
        ),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {jobId, seq},
  ];
  @override
  JobItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      srcTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}src_track_id'],
      )!,
      mappingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mapping_id'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      resolvedDstId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_dst_id'],
      ),
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $JobItemsTable createAlias(String alias) {
    return $JobItemsTable(attachedDatabase, alias);
  }
}

class JobItem extends DataClass implements Insertable<JobItem> {
  final String id;
  final String jobId;
  final int seq;
  final String srcTrackId;
  final String? mappingId;
  final String state;

  /// Destination track id once resolved — engine checkpoint state.
  final String? resolvedDstId;
  final int attemptCount;
  final DateTime? nextRetryAt;
  final String? lastError;
  const JobItem({
    required this.id,
    required this.jobId,
    required this.seq,
    required this.srcTrackId,
    this.mappingId,
    required this.state,
    this.resolvedDstId,
    required this.attemptCount,
    this.nextRetryAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['job_id'] = Variable<String>(jobId);
    map['seq'] = Variable<int>(seq);
    map['src_track_id'] = Variable<String>(srcTrackId);
    if (!nullToAbsent || mappingId != null) {
      map['mapping_id'] = Variable<String>(mappingId);
    }
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || resolvedDstId != null) {
      map['resolved_dst_id'] = Variable<String>(resolvedDstId);
    }
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  JobItemsCompanion toCompanion(bool nullToAbsent) {
    return JobItemsCompanion(
      id: Value(id),
      jobId: Value(jobId),
      seq: Value(seq),
      srcTrackId: Value(srcTrackId),
      mappingId: mappingId == null && nullToAbsent
          ? const Value.absent()
          : Value(mappingId),
      state: Value(state),
      resolvedDstId: resolvedDstId == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedDstId),
      attemptCount: Value(attemptCount),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory JobItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobItem(
      id: serializer.fromJson<String>(json['id']),
      jobId: serializer.fromJson<String>(json['jobId']),
      seq: serializer.fromJson<int>(json['seq']),
      srcTrackId: serializer.fromJson<String>(json['srcTrackId']),
      mappingId: serializer.fromJson<String?>(json['mappingId']),
      state: serializer.fromJson<String>(json['state']),
      resolvedDstId: serializer.fromJson<String?>(json['resolvedDstId']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jobId': serializer.toJson<String>(jobId),
      'seq': serializer.toJson<int>(seq),
      'srcTrackId': serializer.toJson<String>(srcTrackId),
      'mappingId': serializer.toJson<String?>(mappingId),
      'state': serializer.toJson<String>(state),
      'resolvedDstId': serializer.toJson<String?>(resolvedDstId),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  JobItem copyWith({
    String? id,
    String? jobId,
    int? seq,
    String? srcTrackId,
    Value<String?> mappingId = const Value.absent(),
    String? state,
    Value<String?> resolvedDstId = const Value.absent(),
    int? attemptCount,
    Value<DateTime?> nextRetryAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => JobItem(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    seq: seq ?? this.seq,
    srcTrackId: srcTrackId ?? this.srcTrackId,
    mappingId: mappingId.present ? mappingId.value : this.mappingId,
    state: state ?? this.state,
    resolvedDstId: resolvedDstId.present
        ? resolvedDstId.value
        : this.resolvedDstId,
    attemptCount: attemptCount ?? this.attemptCount,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  JobItem copyWithCompanion(JobItemsCompanion data) {
    return JobItem(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      seq: data.seq.present ? data.seq.value : this.seq,
      srcTrackId: data.srcTrackId.present
          ? data.srcTrackId.value
          : this.srcTrackId,
      mappingId: data.mappingId.present ? data.mappingId.value : this.mappingId,
      state: data.state.present ? data.state.value : this.state,
      resolvedDstId: data.resolvedDstId.present
          ? data.resolvedDstId.value
          : this.resolvedDstId,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobItem(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('seq: $seq, ')
          ..write('srcTrackId: $srcTrackId, ')
          ..write('mappingId: $mappingId, ')
          ..write('state: $state, ')
          ..write('resolvedDstId: $resolvedDstId, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobId,
    seq,
    srcTrackId,
    mappingId,
    state,
    resolvedDstId,
    attemptCount,
    nextRetryAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobItem &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.seq == this.seq &&
          other.srcTrackId == this.srcTrackId &&
          other.mappingId == this.mappingId &&
          other.state == this.state &&
          other.resolvedDstId == this.resolvedDstId &&
          other.attemptCount == this.attemptCount &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError);
}

class JobItemsCompanion extends UpdateCompanion<JobItem> {
  final Value<String> id;
  final Value<String> jobId;
  final Value<int> seq;
  final Value<String> srcTrackId;
  final Value<String?> mappingId;
  final Value<String> state;
  final Value<String?> resolvedDstId;
  final Value<int> attemptCount;
  final Value<DateTime?> nextRetryAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const JobItemsCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.seq = const Value.absent(),
    this.srcTrackId = const Value.absent(),
    this.mappingId = const Value.absent(),
    this.state = const Value.absent(),
    this.resolvedDstId = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobItemsCompanion.insert({
    required String id,
    required String jobId,
    required int seq,
    required String srcTrackId,
    this.mappingId = const Value.absent(),
    required String state,
    this.resolvedDstId = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jobId = Value(jobId),
       seq = Value(seq),
       srcTrackId = Value(srcTrackId),
       state = Value(state);
  static Insertable<JobItem> custom({
    Expression<String>? id,
    Expression<String>? jobId,
    Expression<int>? seq,
    Expression<String>? srcTrackId,
    Expression<String>? mappingId,
    Expression<String>? state,
    Expression<String>? resolvedDstId,
    Expression<int>? attemptCount,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (seq != null) 'seq': seq,
      if (srcTrackId != null) 'src_track_id': srcTrackId,
      if (mappingId != null) 'mapping_id': mappingId,
      if (state != null) 'state': state,
      if (resolvedDstId != null) 'resolved_dst_id': resolvedDstId,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? jobId,
    Value<int>? seq,
    Value<String>? srcTrackId,
    Value<String?>? mappingId,
    Value<String>? state,
    Value<String?>? resolvedDstId,
    Value<int>? attemptCount,
    Value<DateTime?>? nextRetryAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return JobItemsCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      seq: seq ?? this.seq,
      srcTrackId: srcTrackId ?? this.srcTrackId,
      mappingId: mappingId ?? this.mappingId,
      state: state ?? this.state,
      resolvedDstId: resolvedDstId ?? this.resolvedDstId,
      attemptCount: attemptCount ?? this.attemptCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (srcTrackId.present) {
      map['src_track_id'] = Variable<String>(srcTrackId.value);
    }
    if (mappingId.present) {
      map['mapping_id'] = Variable<String>(mappingId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (resolvedDstId.present) {
      map['resolved_dst_id'] = Variable<String>(resolvedDstId.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobItemsCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('seq: $seq, ')
          ..write('srcTrackId: $srcTrackId, ')
          ..write('mappingId: $mappingId, ')
          ..write('state: $state, ')
          ..write('resolvedDstId: $resolvedDstId, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncPairsTable extends SyncPairs
    with TableInfo<$SyncPairsTable, SyncPair> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncPairsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _srcPlaylistIdMeta = const VerificationMeta(
    'srcPlaylistId',
  );
  @override
  late final GeneratedColumn<String> srcPlaylistId = GeneratedColumn<String>(
    'src_playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES playlist_snapshots (id) ON DELETE CASCADE',
  );
  static const VerificationMeta _dstPlaylistIdMeta = const VerificationMeta(
    'dstPlaylistId',
  );
  @override
  late final GeneratedColumn<String> dstPlaylistId = GeneratedColumn<String>(
    'dst_playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES playlist_snapshots (id) ON DELETE CASCADE',
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conflictPolicyMeta = const VerificationMeta(
    'conflictPolicy',
  );
  @override
  late final GeneratedColumn<String> conflictPolicy = GeneratedColumn<String>(
    'conflict_policy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleCronMeta = const VerificationMeta(
    'scheduleCron',
  );
  @override
  late final GeneratedColumn<String> scheduleCron = GeneratedColumn<String>(
    'schedule_cron',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseStateJsonMeta = const VerificationMeta(
    'baseStateJson',
  );
  @override
  late final GeneratedColumn<String> baseStateJson = GeneratedColumn<String>(
    'base_state_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    srcPlaylistId,
    dstPlaylistId,
    mode,
    conflictPolicy,
    scheduleCron,
    enabled,
    lastSyncedAt,
    baseStateJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_pairs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncPair> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('src_playlist_id')) {
      context.handle(
        _srcPlaylistIdMeta,
        srcPlaylistId.isAcceptableOrUnknown(
          data['src_playlist_id']!,
          _srcPlaylistIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_srcPlaylistIdMeta);
    }
    if (data.containsKey('dst_playlist_id')) {
      context.handle(
        _dstPlaylistIdMeta,
        dstPlaylistId.isAcceptableOrUnknown(
          data['dst_playlist_id']!,
          _dstPlaylistIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dstPlaylistIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('conflict_policy')) {
      context.handle(
        _conflictPolicyMeta,
        conflictPolicy.isAcceptableOrUnknown(
          data['conflict_policy']!,
          _conflictPolicyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conflictPolicyMeta);
    }
    if (data.containsKey('schedule_cron')) {
      context.handle(
        _scheduleCronMeta,
        scheduleCron.isAcceptableOrUnknown(
          data['schedule_cron']!,
          _scheduleCronMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('base_state_json')) {
      context.handle(
        _baseStateJsonMeta,
        baseStateJson.isAcceptableOrUnknown(
          data['base_state_json']!,
          _baseStateJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncPair map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncPair(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      srcPlaylistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}src_playlist_id'],
      )!,
      dstPlaylistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dst_playlist_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      conflictPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_policy'],
      )!,
      scheduleCron: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_cron'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      baseStateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_state_json'],
      ),
    );
  }

  @override
  $SyncPairsTable createAlias(String alias) {
    return $SyncPairsTable(attachedDatabase, alias);
  }
}

class SyncPair extends DataClass implements Insertable<SyncPair> {
  final String id;
  final String srcPlaylistId;
  final String dstPlaylistId;
  final String mode;
  final String conflictPolicy;
  final String? scheduleCron;
  final bool enabled;
  final DateTime? lastSyncedAt;

  /// Last agreed state — the 3-way diff anchor (docs/08 §5).
  final String? baseStateJson;
  const SyncPair({
    required this.id,
    required this.srcPlaylistId,
    required this.dstPlaylistId,
    required this.mode,
    required this.conflictPolicy,
    this.scheduleCron,
    required this.enabled,
    this.lastSyncedAt,
    this.baseStateJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['src_playlist_id'] = Variable<String>(srcPlaylistId);
    map['dst_playlist_id'] = Variable<String>(dstPlaylistId);
    map['mode'] = Variable<String>(mode);
    map['conflict_policy'] = Variable<String>(conflictPolicy);
    if (!nullToAbsent || scheduleCron != null) {
      map['schedule_cron'] = Variable<String>(scheduleCron);
    }
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || baseStateJson != null) {
      map['base_state_json'] = Variable<String>(baseStateJson);
    }
    return map;
  }

  SyncPairsCompanion toCompanion(bool nullToAbsent) {
    return SyncPairsCompanion(
      id: Value(id),
      srcPlaylistId: Value(srcPlaylistId),
      dstPlaylistId: Value(dstPlaylistId),
      mode: Value(mode),
      conflictPolicy: Value(conflictPolicy),
      scheduleCron: scheduleCron == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleCron),
      enabled: Value(enabled),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      baseStateJson: baseStateJson == null && nullToAbsent
          ? const Value.absent()
          : Value(baseStateJson),
    );
  }

  factory SyncPair.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncPair(
      id: serializer.fromJson<String>(json['id']),
      srcPlaylistId: serializer.fromJson<String>(json['srcPlaylistId']),
      dstPlaylistId: serializer.fromJson<String>(json['dstPlaylistId']),
      mode: serializer.fromJson<String>(json['mode']),
      conflictPolicy: serializer.fromJson<String>(json['conflictPolicy']),
      scheduleCron: serializer.fromJson<String?>(json['scheduleCron']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      baseStateJson: serializer.fromJson<String?>(json['baseStateJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'srcPlaylistId': serializer.toJson<String>(srcPlaylistId),
      'dstPlaylistId': serializer.toJson<String>(dstPlaylistId),
      'mode': serializer.toJson<String>(mode),
      'conflictPolicy': serializer.toJson<String>(conflictPolicy),
      'scheduleCron': serializer.toJson<String?>(scheduleCron),
      'enabled': serializer.toJson<bool>(enabled),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'baseStateJson': serializer.toJson<String?>(baseStateJson),
    };
  }

  SyncPair copyWith({
    String? id,
    String? srcPlaylistId,
    String? dstPlaylistId,
    String? mode,
    String? conflictPolicy,
    Value<String?> scheduleCron = const Value.absent(),
    bool? enabled,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<String?> baseStateJson = const Value.absent(),
  }) => SyncPair(
    id: id ?? this.id,
    srcPlaylistId: srcPlaylistId ?? this.srcPlaylistId,
    dstPlaylistId: dstPlaylistId ?? this.dstPlaylistId,
    mode: mode ?? this.mode,
    conflictPolicy: conflictPolicy ?? this.conflictPolicy,
    scheduleCron: scheduleCron.present ? scheduleCron.value : this.scheduleCron,
    enabled: enabled ?? this.enabled,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    baseStateJson: baseStateJson.present
        ? baseStateJson.value
        : this.baseStateJson,
  );
  SyncPair copyWithCompanion(SyncPairsCompanion data) {
    return SyncPair(
      id: data.id.present ? data.id.value : this.id,
      srcPlaylistId: data.srcPlaylistId.present
          ? data.srcPlaylistId.value
          : this.srcPlaylistId,
      dstPlaylistId: data.dstPlaylistId.present
          ? data.dstPlaylistId.value
          : this.dstPlaylistId,
      mode: data.mode.present ? data.mode.value : this.mode,
      conflictPolicy: data.conflictPolicy.present
          ? data.conflictPolicy.value
          : this.conflictPolicy,
      scheduleCron: data.scheduleCron.present
          ? data.scheduleCron.value
          : this.scheduleCron,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      baseStateJson: data.baseStateJson.present
          ? data.baseStateJson.value
          : this.baseStateJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncPair(')
          ..write('id: $id, ')
          ..write('srcPlaylistId: $srcPlaylistId, ')
          ..write('dstPlaylistId: $dstPlaylistId, ')
          ..write('mode: $mode, ')
          ..write('conflictPolicy: $conflictPolicy, ')
          ..write('scheduleCron: $scheduleCron, ')
          ..write('enabled: $enabled, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('baseStateJson: $baseStateJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    srcPlaylistId,
    dstPlaylistId,
    mode,
    conflictPolicy,
    scheduleCron,
    enabled,
    lastSyncedAt,
    baseStateJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncPair &&
          other.id == this.id &&
          other.srcPlaylistId == this.srcPlaylistId &&
          other.dstPlaylistId == this.dstPlaylistId &&
          other.mode == this.mode &&
          other.conflictPolicy == this.conflictPolicy &&
          other.scheduleCron == this.scheduleCron &&
          other.enabled == this.enabled &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.baseStateJson == this.baseStateJson);
}

class SyncPairsCompanion extends UpdateCompanion<SyncPair> {
  final Value<String> id;
  final Value<String> srcPlaylistId;
  final Value<String> dstPlaylistId;
  final Value<String> mode;
  final Value<String> conflictPolicy;
  final Value<String?> scheduleCron;
  final Value<bool> enabled;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> baseStateJson;
  final Value<int> rowid;
  const SyncPairsCompanion({
    this.id = const Value.absent(),
    this.srcPlaylistId = const Value.absent(),
    this.dstPlaylistId = const Value.absent(),
    this.mode = const Value.absent(),
    this.conflictPolicy = const Value.absent(),
    this.scheduleCron = const Value.absent(),
    this.enabled = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.baseStateJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncPairsCompanion.insert({
    required String id,
    required String srcPlaylistId,
    required String dstPlaylistId,
    required String mode,
    required String conflictPolicy,
    this.scheduleCron = const Value.absent(),
    this.enabled = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.baseStateJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       srcPlaylistId = Value(srcPlaylistId),
       dstPlaylistId = Value(dstPlaylistId),
       mode = Value(mode),
       conflictPolicy = Value(conflictPolicy);
  static Insertable<SyncPair> custom({
    Expression<String>? id,
    Expression<String>? srcPlaylistId,
    Expression<String>? dstPlaylistId,
    Expression<String>? mode,
    Expression<String>? conflictPolicy,
    Expression<String>? scheduleCron,
    Expression<bool>? enabled,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? baseStateJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (srcPlaylistId != null) 'src_playlist_id': srcPlaylistId,
      if (dstPlaylistId != null) 'dst_playlist_id': dstPlaylistId,
      if (mode != null) 'mode': mode,
      if (conflictPolicy != null) 'conflict_policy': conflictPolicy,
      if (scheduleCron != null) 'schedule_cron': scheduleCron,
      if (enabled != null) 'enabled': enabled,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (baseStateJson != null) 'base_state_json': baseStateJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncPairsCompanion copyWith({
    Value<String>? id,
    Value<String>? srcPlaylistId,
    Value<String>? dstPlaylistId,
    Value<String>? mode,
    Value<String>? conflictPolicy,
    Value<String?>? scheduleCron,
    Value<bool>? enabled,
    Value<DateTime?>? lastSyncedAt,
    Value<String?>? baseStateJson,
    Value<int>? rowid,
  }) {
    return SyncPairsCompanion(
      id: id ?? this.id,
      srcPlaylistId: srcPlaylistId ?? this.srcPlaylistId,
      dstPlaylistId: dstPlaylistId ?? this.dstPlaylistId,
      mode: mode ?? this.mode,
      conflictPolicy: conflictPolicy ?? this.conflictPolicy,
      scheduleCron: scheduleCron ?? this.scheduleCron,
      enabled: enabled ?? this.enabled,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      baseStateJson: baseStateJson ?? this.baseStateJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (srcPlaylistId.present) {
      map['src_playlist_id'] = Variable<String>(srcPlaylistId.value);
    }
    if (dstPlaylistId.present) {
      map['dst_playlist_id'] = Variable<String>(dstPlaylistId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (conflictPolicy.present) {
      map['conflict_policy'] = Variable<String>(conflictPolicy.value);
    }
    if (scheduleCron.present) {
      map['schedule_cron'] = Variable<String>(scheduleCron.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (baseStateJson.present) {
      map['base_state_json'] = Variable<String>(baseStateJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncPairsCompanion(')
          ..write('id: $id, ')
          ..write('srcPlaylistId: $srcPlaylistId, ')
          ..write('dstPlaylistId: $dstPlaylistId, ')
          ..write('mode: $mode, ')
          ..write('conflictPolicy: $conflictPolicy, ')
          ..write('scheduleCron: $scheduleCron, ')
          ..write('enabled: $enabled, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('baseStateJson: $baseStateJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncRunsTable extends SyncRuns with TableInfo<$SyncRunsTable, SyncRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairIdMeta = const VerificationMeta('pairId');
  @override
  late final GeneratedColumn<String> pairId = GeneratedColumn<String>(
    'pair_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES sync_pairs (id) ON DELETE CASCADE',
  );
  static const VerificationMeta _triggerMeta = const VerificationMeta(
    'trigger',
  );
  @override
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diffJsonMeta = const VerificationMeta(
    'diffJson',
  );
  @override
  late final GeneratedColumn<String> diffJson = GeneratedColumn<String>(
    'diff_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pairId,
    trigger,
    state,
    diffJson,
    startedAt,
    finishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pair_id')) {
      context.handle(
        _pairIdMeta,
        pairId.isAcceptableOrUnknown(data['pair_id']!, _pairIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pairIdMeta);
    }
    if (data.containsKey('trigger')) {
      context.handle(
        _triggerMeta,
        trigger.isAcceptableOrUnknown(data['trigger']!, _triggerMeta),
      );
    } else if (isInserting) {
      context.missing(_triggerMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('diff_json')) {
      context.handle(
        _diffJsonMeta,
        diffJson.isAcceptableOrUnknown(data['diff_json']!, _diffJsonMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pairId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pair_id'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      diffJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diff_json'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
    );
  }

  @override
  $SyncRunsTable createAlias(String alias) {
    return $SyncRunsTable(attachedDatabase, alias);
  }
}

class SyncRun extends DataClass implements Insertable<SyncRun> {
  final String id;
  final String pairId;
  final String trigger;
  final String state;
  final String? diffJson;
  final DateTime startedAt;
  final DateTime? finishedAt;
  const SyncRun({
    required this.id,
    required this.pairId,
    required this.trigger,
    required this.state,
    this.diffJson,
    required this.startedAt,
    this.finishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pair_id'] = Variable<String>(pairId);
    map['trigger'] = Variable<String>(trigger);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || diffJson != null) {
      map['diff_json'] = Variable<String>(diffJson);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    return map;
  }

  SyncRunsCompanion toCompanion(bool nullToAbsent) {
    return SyncRunsCompanion(
      id: Value(id),
      pairId: Value(pairId),
      trigger: Value(trigger),
      state: Value(state),
      diffJson: diffJson == null && nullToAbsent
          ? const Value.absent()
          : Value(diffJson),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
    );
  }

  factory SyncRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncRun(
      id: serializer.fromJson<String>(json['id']),
      pairId: serializer.fromJson<String>(json['pairId']),
      trigger: serializer.fromJson<String>(json['trigger']),
      state: serializer.fromJson<String>(json['state']),
      diffJson: serializer.fromJson<String?>(json['diffJson']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pairId': serializer.toJson<String>(pairId),
      'trigger': serializer.toJson<String>(trigger),
      'state': serializer.toJson<String>(state),
      'diffJson': serializer.toJson<String?>(diffJson),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
    };
  }

  SyncRun copyWith({
    String? id,
    String? pairId,
    String? trigger,
    String? state,
    Value<String?> diffJson = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
  }) => SyncRun(
    id: id ?? this.id,
    pairId: pairId ?? this.pairId,
    trigger: trigger ?? this.trigger,
    state: state ?? this.state,
    diffJson: diffJson.present ? diffJson.value : this.diffJson,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
  );
  SyncRun copyWithCompanion(SyncRunsCompanion data) {
    return SyncRun(
      id: data.id.present ? data.id.value : this.id,
      pairId: data.pairId.present ? data.pairId.value : this.pairId,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      state: data.state.present ? data.state.value : this.state,
      diffJson: data.diffJson.present ? data.diffJson.value : this.diffJson,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncRun(')
          ..write('id: $id, ')
          ..write('pairId: $pairId, ')
          ..write('trigger: $trigger, ')
          ..write('state: $state, ')
          ..write('diffJson: $diffJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pairId, trigger, state, diffJson, startedAt, finishedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncRun &&
          other.id == this.id &&
          other.pairId == this.pairId &&
          other.trigger == this.trigger &&
          other.state == this.state &&
          other.diffJson == this.diffJson &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt);
}

class SyncRunsCompanion extends UpdateCompanion<SyncRun> {
  final Value<String> id;
  final Value<String> pairId;
  final Value<String> trigger;
  final Value<String> state;
  final Value<String?> diffJson;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> rowid;
  const SyncRunsCompanion({
    this.id = const Value.absent(),
    this.pairId = const Value.absent(),
    this.trigger = const Value.absent(),
    this.state = const Value.absent(),
    this.diffJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncRunsCompanion.insert({
    required String id,
    required String pairId,
    required String trigger,
    required String state,
    this.diffJson = const Value.absent(),
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pairId = Value(pairId),
       trigger = Value(trigger),
       state = Value(state),
       startedAt = Value(startedAt);
  static Insertable<SyncRun> custom({
    Expression<String>? id,
    Expression<String>? pairId,
    Expression<String>? trigger,
    Expression<String>? state,
    Expression<String>? diffJson,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pairId != null) 'pair_id': pairId,
      if (trigger != null) 'trigger': trigger,
      if (state != null) 'state': state,
      if (diffJson != null) 'diff_json': diffJson,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncRunsCompanion copyWith({
    Value<String>? id,
    Value<String>? pairId,
    Value<String>? trigger,
    Value<String>? state,
    Value<String?>? diffJson,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? rowid,
  }) {
    return SyncRunsCompanion(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      trigger: trigger ?? this.trigger,
      state: state ?? this.state,
      diffJson: diffJson ?? this.diffJson,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pairId.present) {
      map['pair_id'] = Variable<String>(pairId.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (diffJson.present) {
      map['diff_json'] = Variable<String>(diffJson.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncRunsCompanion(')
          ..write('id: $id, ')
          ..write('pairId: $pairId, ')
          ..write('trigger: $trigger, ')
          ..write('state: $state, ')
          ..write('diffJson: $diffJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobLogsTable extends JobLogs with TableInfo<$JobLogsTable, JobLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventMeta = const VerificationMeta('event');
  @override
  late final GeneratedColumn<String> event = GeneratedColumn<String>(
    'event',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailJsonMeta = const VerificationMeta(
    'detailJson',
  );
  @override
  late final GeneratedColumn<String> detailJson = GeneratedColumn<String>(
    'detail_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    level,
    event,
    detailJson,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('event')) {
      context.handle(
        _eventMeta,
        event.isAcceptableOrUnknown(data['event']!, _eventMeta),
      );
    } else if (isInserting) {
      context.missing(_eventMeta);
    }
    if (data.containsKey('detail_json')) {
      context.handle(
        _detailJsonMeta,
        detailJson.isAcceptableOrUnknown(data['detail_json']!, _detailJsonMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      event: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event'],
      )!,
      detailJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail_json'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $JobLogsTable createAlias(String alias) {
    return $JobLogsTable(attachedDatabase, alias);
  }
}

class JobLog extends DataClass implements Insertable<JobLog> {
  final int id;
  final String? jobId;
  final String level;
  final String event;
  final String? detailJson;
  final DateTime at;
  const JobLog({
    required this.id,
    this.jobId,
    required this.level,
    required this.event,
    this.detailJson,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || jobId != null) {
      map['job_id'] = Variable<String>(jobId);
    }
    map['level'] = Variable<String>(level);
    map['event'] = Variable<String>(event);
    if (!nullToAbsent || detailJson != null) {
      map['detail_json'] = Variable<String>(detailJson);
    }
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  JobLogsCompanion toCompanion(bool nullToAbsent) {
    return JobLogsCompanion(
      id: Value(id),
      jobId: jobId == null && nullToAbsent
          ? const Value.absent()
          : Value(jobId),
      level: Value(level),
      event: Value(event),
      detailJson: detailJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detailJson),
      at: Value(at),
    );
  }

  factory JobLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobLog(
      id: serializer.fromJson<int>(json['id']),
      jobId: serializer.fromJson<String?>(json['jobId']),
      level: serializer.fromJson<String>(json['level']),
      event: serializer.fromJson<String>(json['event']),
      detailJson: serializer.fromJson<String?>(json['detailJson']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jobId': serializer.toJson<String?>(jobId),
      'level': serializer.toJson<String>(level),
      'event': serializer.toJson<String>(event),
      'detailJson': serializer.toJson<String?>(detailJson),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  JobLog copyWith({
    int? id,
    Value<String?> jobId = const Value.absent(),
    String? level,
    String? event,
    Value<String?> detailJson = const Value.absent(),
    DateTime? at,
  }) => JobLog(
    id: id ?? this.id,
    jobId: jobId.present ? jobId.value : this.jobId,
    level: level ?? this.level,
    event: event ?? this.event,
    detailJson: detailJson.present ? detailJson.value : this.detailJson,
    at: at ?? this.at,
  );
  JobLog copyWithCompanion(JobLogsCompanion data) {
    return JobLog(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      level: data.level.present ? data.level.value : this.level,
      event: data.event.present ? data.event.value : this.event,
      detailJson: data.detailJson.present
          ? data.detailJson.value
          : this.detailJson,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobLog(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('level: $level, ')
          ..write('event: $event, ')
          ..write('detailJson: $detailJson, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, jobId, level, event, detailJson, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobLog &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.level == this.level &&
          other.event == this.event &&
          other.detailJson == this.detailJson &&
          other.at == this.at);
}

class JobLogsCompanion extends UpdateCompanion<JobLog> {
  final Value<int> id;
  final Value<String?> jobId;
  final Value<String> level;
  final Value<String> event;
  final Value<String?> detailJson;
  final Value<DateTime> at;
  const JobLogsCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.level = const Value.absent(),
    this.event = const Value.absent(),
    this.detailJson = const Value.absent(),
    this.at = const Value.absent(),
  });
  JobLogsCompanion.insert({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    required String level,
    required String event,
    this.detailJson = const Value.absent(),
    required DateTime at,
  }) : level = Value(level),
       event = Value(event),
       at = Value(at);
  static Insertable<JobLog> custom({
    Expression<int>? id,
    Expression<String>? jobId,
    Expression<String>? level,
    Expression<String>? event,
    Expression<String>? detailJson,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (level != null) 'level': level,
      if (event != null) 'event': event,
      if (detailJson != null) 'detail_json': detailJson,
      if (at != null) 'at': at,
    });
  }

  JobLogsCompanion copyWith({
    Value<int>? id,
    Value<String?>? jobId,
    Value<String>? level,
    Value<String>? event,
    Value<String?>? detailJson,
    Value<DateTime>? at,
  }) {
    return JobLogsCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      level: level ?? this.level,
      event: event ?? this.event,
      detailJson: detailJson ?? this.detailJson,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (event.present) {
      map['event'] = Variable<String>(event.value);
    }
    if (detailJson.present) {
      map['detail_json'] = Variable<String>(detailJson.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobLogsCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('level: $level, ')
          ..write('event: $event, ')
          ..write('detailJson: $detailJson, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String valueJson;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.valueJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      valueJson: Value(valueJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? valueJson, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        valueJson: valueJson ?? this.valueJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String valueJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BridgetuneDatabase extends GeneratedDatabase {
  _$BridgetuneDatabase(QueryExecutor e) : super(e);
  $BridgetuneDatabaseManager get managers => $BridgetuneDatabaseManager(this);
  late final $ProviderAccountsTable providerAccounts = $ProviderAccountsTable(
    this,
  );
  late final $TrackSnapshotsTable trackSnapshots = $TrackSnapshotsTable(this);
  late final $TrackMappingsTable trackMappings = $TrackMappingsTable(this);
  late final $PlaylistSnapshotsTable playlistSnapshots =
      $PlaylistSnapshotsTable(this);
  late final $PlaylistTrackSnapshotsTable playlistTrackSnapshots =
      $PlaylistTrackSnapshotsTable(this);
  late final $TransferJobsTable transferJobs = $TransferJobsTable(this);
  late final $JobItemsTable jobItems = $JobItemsTable(this);
  late final $SyncPairsTable syncPairs = $SyncPairsTable(this);
  late final $SyncRunsTable syncRuns = $SyncRunsTable(this);
  late final $JobLogsTable jobLogs = $JobLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index idxTracksIsrc = Index(
    'idx_tracks_isrc',
    'CREATE INDEX idx_tracks_isrc ON track_snapshots (isrc)',
  );
  late final Index idxTracksNorm = Index(
    'idx_tracks_norm',
    'CREATE INDEX idx_tracks_norm ON track_snapshots (title_norm)',
  );
  late final Index idxMappingsDst = Index(
    'idx_mappings_dst',
    'CREATE INDEX idx_mappings_dst ON track_mappings (dst_provider_id)',
  );
  late final Index idxJobsState = Index(
    'idx_jobs_state',
    'CREATE INDEX idx_jobs_state ON transfer_jobs (state, updated_at)',
  );
  late final Index idxItemsJobState = Index(
    'idx_items_job_state',
    'CREATE INDEX idx_items_job_state ON job_items (job_id, state)',
  );
  late final Index idxItemsRetry = Index(
    'idx_items_retry',
    'CREATE INDEX idx_items_retry ON job_items (state, next_retry_at)',
  );
  late final Index idxLogsAt = Index(
    'idx_logs_at',
    'CREATE INDEX idx_logs_at ON job_logs (at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    providerAccounts,
    trackSnapshots,
    trackMappings,
    playlistSnapshots,
    playlistTrackSnapshots,
    transferJobs,
    jobItems,
    syncPairs,
    syncRuns,
    jobLogs,
    appSettings,
    idxTracksIsrc,
    idxTracksNorm,
    idxMappingsDst,
    idxJobsState,
    idxItemsJobState,
    idxItemsRetry,
    idxLogsAt,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'track_snapshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_mappings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'provider_accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_snapshots', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlist_snapshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('playlist_track_snapshots', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transfer_jobs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('job_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlist_snapshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sync_pairs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlist_snapshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sync_pairs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sync_pairs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sync_runs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProviderAccountsTableCreateCompanionBuilder =
    ProviderAccountsCompanion Function({
      required String id,
      required String providerId,
      required String accountValue,
      required String displayName,
      Value<String?> avatarUrl,
      required String tokenRef,
      Value<String> scopes,
      Value<String> status,
      required DateTime connectedAt,
      Value<int> rowid,
    });
typedef $$ProviderAccountsTableUpdateCompanionBuilder =
    ProviderAccountsCompanion Function({
      Value<String> id,
      Value<String> providerId,
      Value<String> accountValue,
      Value<String> displayName,
      Value<String?> avatarUrl,
      Value<String> tokenRef,
      Value<String> scopes,
      Value<String> status,
      Value<DateTime> connectedAt,
      Value<int> rowid,
    });

final class $$ProviderAccountsTableReferences
    extends
        BaseReferences<
          _$BridgetuneDatabase,
          $ProviderAccountsTable,
          ProviderAccount
        > {
  $$ProviderAccountsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PlaylistSnapshotsTable, List<PlaylistSnapshot>>
  _playlistSnapshotsRefsTable(_$BridgetuneDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistSnapshots,
        aliasName: $_aliasNameGenerator(
          db.providerAccounts.id,
          db.playlistSnapshots.accountId,
        ),
      );

  $$PlaylistSnapshotsTableProcessedTableManager get playlistSnapshotsRefs {
    final manager = $$PlaylistSnapshotsTableTableManager(
      $_db,
      $_db.playlistSnapshots,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProviderAccountsTableFilterComposer
    extends Composer<_$BridgetuneDatabase, $ProviderAccountsTable> {
  $$ProviderAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountValue => $composableBuilder(
    column: $table.accountValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenRef => $composableBuilder(
    column: $table.tokenRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopes => $composableBuilder(
    column: $table.scopes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistSnapshotsRefs(
    Expression<bool> Function($$PlaylistSnapshotsTableFilterComposer f) f,
  ) {
    final $$PlaylistSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSnapshots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.playlistSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProviderAccountsTableOrderingComposer
    extends Composer<_$BridgetuneDatabase, $ProviderAccountsTable> {
  $$ProviderAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountValue => $composableBuilder(
    column: $table.accountValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenRef => $composableBuilder(
    column: $table.tokenRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopes => $composableBuilder(
    column: $table.scopes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProviderAccountsTableAnnotationComposer
    extends Composer<_$BridgetuneDatabase, $ProviderAccountsTable> {
  $$ProviderAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountValue => $composableBuilder(
    column: $table.accountValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get tokenRef =>
      $composableBuilder(column: $table.tokenRef, builder: (column) => column);

  GeneratedColumn<String> get scopes =>
      $composableBuilder(column: $table.scopes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => column,
  );

  Expression<T> playlistSnapshotsRefs<T extends Object>(
    Expression<T> Function($$PlaylistSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistSnapshots,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProviderAccountsTableTableManager
    extends
        RootTableManager<
          _$BridgetuneDatabase,
          $ProviderAccountsTable,
          ProviderAccount,
          $$ProviderAccountsTableFilterComposer,
          $$ProviderAccountsTableOrderingComposer,
          $$ProviderAccountsTableAnnotationComposer,
          $$ProviderAccountsTableCreateCompanionBuilder,
          $$ProviderAccountsTableUpdateCompanionBuilder,
          (ProviderAccount, $$ProviderAccountsTableReferences),
          ProviderAccount,
          PrefetchHooks Function({bool playlistSnapshotsRefs})
        > {
  $$ProviderAccountsTableTableManager(
    _$BridgetuneDatabase db,
    $ProviderAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProviderAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProviderAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> accountValue = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> tokenRef = const Value.absent(),
                Value<String> scopes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> connectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderAccountsCompanion(
                id: id,
                providerId: providerId,
                accountValue: accountValue,
                displayName: displayName,
                avatarUrl: avatarUrl,
                tokenRef: tokenRef,
                scopes: scopes,
                status: status,
                connectedAt: connectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String providerId,
                required String accountValue,
                required String displayName,
                Value<String?> avatarUrl = const Value.absent(),
                required String tokenRef,
                Value<String> scopes = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime connectedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProviderAccountsCompanion.insert(
                id: id,
                providerId: providerId,
                accountValue: accountValue,
                displayName: displayName,
                avatarUrl: avatarUrl,
                tokenRef: tokenRef,
                scopes: scopes,
                status: status,
                connectedAt: connectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProviderAccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistSnapshotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistSnapshotsRefs) db.playlistSnapshots,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistSnapshotsRefs)
                    await $_getPrefetchedData<
                      ProviderAccount,
                      $ProviderAccountsTable,
                      PlaylistSnapshot
                    >(
                      currentTable: table,
                      referencedTable: $$ProviderAccountsTableReferences
                          ._playlistSnapshotsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProviderAccountsTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistSnapshotsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.accountId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProviderAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgetuneDatabase,
      $ProviderAccountsTable,
      ProviderAccount,
      $$ProviderAccountsTableFilterComposer,
      $$ProviderAccountsTableOrderingComposer,
      $$ProviderAccountsTableAnnotationComposer,
      $$ProviderAccountsTableCreateCompanionBuilder,
      $$ProviderAccountsTableUpdateCompanionBuilder,
      (ProviderAccount, $$ProviderAccountsTableReferences),
      ProviderAccount,
      PrefetchHooks Function({bool playlistSnapshotsRefs})
    >;
typedef $$TrackSnapshotsTableCreateCompanionBuilder =
    TrackSnapshotsCompanion Function({
      required String id,
      required String providerId,
      required String providerTrackId,
      Value<String?> isrc,
      required String title,
      required String titleNorm,
      required String artistsJson,
      Value<String?> album,
      Value<int?> durationMs,
      Value<int?> releaseYear,
      Value<bool?> explicit,
      Value<int?> popularity,
      Value<String?> rawJson,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$TrackSnapshotsTableUpdateCompanionBuilder =
    TrackSnapshotsCompanion Function({
      Value<String> id,
      Value<String> providerId,
      Value<String> providerTrackId,
      Value<String?> isrc,
      Value<String> title,
      Value<String> titleNorm,
      Value<String> artistsJson,
      Value<String?> album,
      Value<int?> durationMs,
      Value<int?> releaseYear,
      Value<bool?> explicit,
      Value<int?> popularity,
      Value<String?> rawJson,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

final class $$TrackSnapshotsTableReferences
    extends
        BaseReferences<
          _$BridgetuneDatabase,
          $TrackSnapshotsTable,
          TrackSnapshot
        > {
  $$TrackSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TrackMappingsTable, List<TrackMapping>>
  _trackMappingsRefsTable(_$BridgetuneDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackMappings,
        aliasName: $_aliasNameGenerator(
          db.trackSnapshots.id,
          db.trackMappings.srcTrackId,
        ),
      );

  $$TrackMappingsTableProcessedTableManager get trackMappingsRefs {
    final manager = $$TrackMappingsTableTableManager(
      $_db,
      $_db.trackMappings,
    ).filter((f) => f.srcTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackMappingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PlaylistTrackSnapshotsTable,
    List<PlaylistTrackSnapshot>
  >
  _playlistTrackSnapshotsRefsTable(_$BridgetuneDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistTrackSnapshots,
        aliasName: $_aliasNameGenerator(
          db.trackSnapshots.id,
          db.playlistTrackSnapshots.trackId,
        ),
      );

  $$PlaylistTrackSnapshotsTableProcessedTableManager
  get playlistTrackSnapshotsRefs {
    final manager = $$PlaylistTrackSnapshotsTableTableManager(
      $_db,
      $_db.playlistTrackSnapshots,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistTrackSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JobItemsTable, List<JobItem>> _jobItemsRefsTable(
    _$BridgetuneDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobItems,
    aliasName: $_aliasNameGenerator(
      db.trackSnapshots.id,
      db.jobItems.srcTrackId,
    ),
  );

  $$JobItemsTableProcessedTableManager get jobItemsRefs {
    final manager = $$JobItemsTableTableManager(
      $_db,
      $_db.jobItems,
    ).filter((f) => f.srcTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrackSnapshotsTableFilterComposer
    extends Composer<_$BridgetuneDatabase, $TrackSnapshotsTable> {
  $$TrackSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerTrackId => $composableBuilder(
    column: $table.providerTrackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isrc => $composableBuilder(
    column: $table.isrc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleNorm => $composableBuilder(
    column: $table.titleNorm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistsJson => $composableBuilder(
    column: $table.artistsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get popularity => $composableBuilder(
    column: $table.popularity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trackMappingsRefs(
    Expression<bool> Function($$TrackMappingsTableFilterComposer f) f,
  ) {
    final $$TrackMappingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackMappings,
      getReferencedColumn: (t) => t.srcTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackMappingsTableFilterComposer(
            $db: $db,
            $table: $db.trackMappings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playlistTrackSnapshotsRefs(
    Expression<bool> Function($$PlaylistTrackSnapshotsTableFilterComposer f) f,
  ) {
    final $$PlaylistTrackSnapshotsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistTrackSnapshots,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistTrackSnapshotsTableFilterComposer(
                $db: $db,
                $table: $db.playlistTrackSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> jobItemsRefs(
    Expression<bool> Function($$JobItemsTableFilterComposer f) f,
  ) {
    final $$JobItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobItems,
      getReferencedColumn: (t) => t.srcTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobItemsTableFilterComposer(
            $db: $db,
            $table: $db.jobItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackSnapshotsTableOrderingComposer
    extends Composer<_$BridgetuneDatabase, $TrackSnapshotsTable> {
  $$TrackSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerTrackId => $composableBuilder(
    column: $table.providerTrackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isrc => $composableBuilder(
    column: $table.isrc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleNorm => $composableBuilder(
    column: $table.titleNorm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistsJson => $composableBuilder(
    column: $table.artistsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get popularity => $composableBuilder(
    column: $table.popularity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackSnapshotsTableAnnotationComposer
    extends Composer<_$BridgetuneDatabase, $TrackSnapshotsTable> {
  $$TrackSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerTrackId => $composableBuilder(
    column: $table.providerTrackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get isrc =>
      $composableBuilder(column: $table.isrc, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get titleNorm =>
      $composableBuilder(column: $table.titleNorm, builder: (column) => column);

  GeneratedColumn<String> get artistsJson => $composableBuilder(
    column: $table.artistsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get explicit =>
      $composableBuilder(column: $table.explicit, builder: (column) => column);

  GeneratedColumn<int> get popularity => $composableBuilder(
    column: $table.popularity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  Expression<T> trackMappingsRefs<T extends Object>(
    Expression<T> Function($$TrackMappingsTableAnnotationComposer a) f,
  ) {
    final $$TrackMappingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackMappings,
      getReferencedColumn: (t) => t.srcTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackMappingsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackMappings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> playlistTrackSnapshotsRefs<T extends Object>(
    Expression<T> Function($$PlaylistTrackSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTrackSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistTrackSnapshots,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistTrackSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistTrackSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> jobItemsRefs<T extends Object>(
    Expression<T> Function($$JobItemsTableAnnotationComposer a) f,
  ) {
    final $$JobItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobItems,
      getReferencedColumn: (t) => t.srcTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackSnapshotsTableTableManager
    extends
        RootTableManager<
          _$BridgetuneDatabase,
          $TrackSnapshotsTable,
          TrackSnapshot,
          $$TrackSnapshotsTableFilterComposer,
          $$TrackSnapshotsTableOrderingComposer,
          $$TrackSnapshotsTableAnnotationComposer,
          $$TrackSnapshotsTableCreateCompanionBuilder,
          $$TrackSnapshotsTableUpdateCompanionBuilder,
          (TrackSnapshot, $$TrackSnapshotsTableReferences),
          TrackSnapshot,
          PrefetchHooks Function({
            bool trackMappingsRefs,
            bool playlistTrackSnapshotsRefs,
            bool jobItemsRefs,
          })
        > {
  $$TrackSnapshotsTableTableManager(
    _$BridgetuneDatabase db,
    $TrackSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> providerTrackId = const Value.absent(),
                Value<String?> isrc = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> titleNorm = const Value.absent(),
                Value<String> artistsJson = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<bool?> explicit = const Value.absent(),
                Value<int?> popularity = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackSnapshotsCompanion(
                id: id,
                providerId: providerId,
                providerTrackId: providerTrackId,
                isrc: isrc,
                title: title,
                titleNorm: titleNorm,
                artistsJson: artistsJson,
                album: album,
                durationMs: durationMs,
                releaseYear: releaseYear,
                explicit: explicit,
                popularity: popularity,
                rawJson: rawJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String providerId,
                required String providerTrackId,
                Value<String?> isrc = const Value.absent(),
                required String title,
                required String titleNorm,
                required String artistsJson,
                Value<String?> album = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<bool?> explicit = const Value.absent(),
                Value<int?> popularity = const Value.absent(),
                Value<String?> rawJson = const Value.absent(),
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => TrackSnapshotsCompanion.insert(
                id: id,
                providerId: providerId,
                providerTrackId: providerTrackId,
                isrc: isrc,
                title: title,
                titleNorm: titleNorm,
                artistsJson: artistsJson,
                album: album,
                durationMs: durationMs,
                releaseYear: releaseYear,
                explicit: explicit,
                popularity: popularity,
                rawJson: rawJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                trackMappingsRefs = false,
                playlistTrackSnapshotsRefs = false,
                jobItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trackMappingsRefs) db.trackMappings,
                    if (playlistTrackSnapshotsRefs) db.playlistTrackSnapshots,
                    if (jobItemsRefs) db.jobItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trackMappingsRefs)
                        await $_getPrefetchedData<
                          TrackSnapshot,
                          $TrackSnapshotsTable,
                          TrackMapping
                        >(
                          currentTable: table,
                          referencedTable: $$TrackSnapshotsTableReferences
                              ._trackMappingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackSnapshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).trackMappingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.srcTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playlistTrackSnapshotsRefs)
                        await $_getPrefetchedData<
                          TrackSnapshot,
                          $TrackSnapshotsTable,
                          PlaylistTrackSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$TrackSnapshotsTableReferences
                              ._playlistTrackSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackSnapshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistTrackSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (jobItemsRefs)
                        await $_getPrefetchedData<
                          TrackSnapshot,
                          $TrackSnapshotsTable,
                          JobItem
                        >(
                          currentTable: table,
                          referencedTable: $$TrackSnapshotsTableReferences
                              ._jobItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackSnapshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).jobItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.srcTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TrackSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgetuneDatabase,
      $TrackSnapshotsTable,
      TrackSnapshot,
      $$TrackSnapshotsTableFilterComposer,
      $$TrackSnapshotsTableOrderingComposer,
      $$TrackSnapshotsTableAnnotationComposer,
      $$TrackSnapshotsTableCreateCompanionBuilder,
      $$TrackSnapshotsTableUpdateCompanionBuilder,
      (TrackSnapshot, $$TrackSnapshotsTableReferences),
      TrackSnapshot,
      PrefetchHooks Function({
        bool trackMappingsRefs,
        bool playlistTrackSnapshotsRefs,
        bool jobItemsRefs,
      })
    >;
typedef $$TrackMappingsTableCreateCompanionBuilder =
    TrackMappingsCompanion Function({
      required String id,
      required String srcTrackId,
      required String dstProviderId,
      Value<String?> dstProviderTrackId,
      required double confidence,
      required String matchMethod,
      Value<String> signalsJson,
      required String decidedBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TrackMappingsTableUpdateCompanionBuilder =
    TrackMappingsCompanion Function({
      Value<String> id,
      Value<String> srcTrackId,
      Value<String> dstProviderId,
      Value<String?> dstProviderTrackId,
      Value<double> confidence,
      Value<String> matchMethod,
      Value<String> signalsJson,
      Value<String> decidedBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TrackMappingsTableReferences
    extends
        BaseReferences<
          _$BridgetuneDatabase,
          $TrackMappingsTable,
          TrackMapping
        > {
  $$TrackMappingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackSnapshotsTable _srcTrackIdTable(_$BridgetuneDatabase db) =>
      db.trackSnapshots.createAlias(
        $_aliasNameGenerator(db.trackMappings.srcTrackId, db.trackSnapshots.id),
      );

  $$TrackSnapshotsTableProcessedTableManager get srcTrackId {
    final $_column = $_itemColumn<String>('src_track_id')!;

    final manager = $$TrackSnapshotsTableTableManager(
      $_db,
      $_db.trackSnapshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_srcTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$JobItemsTable, List<JobItem>> _jobItemsRefsTable(
    _$BridgetuneDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobItems,
    aliasName: $_aliasNameGenerator(db.trackMappings.id, db.jobItems.mappingId),
  );

  $$JobItemsTableProcessedTableManager get jobItemsRefs {
    final manager = $$JobItemsTableTableManager(
      $_db,
      $_db.jobItems,
    ).filter((f) => f.mappingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrackMappingsTableFilterComposer
    extends Composer<_$BridgetuneDatabase, $TrackMappingsTable> {
  $$TrackMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dstProviderId => $composableBuilder(
    column: $table.dstProviderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dstProviderTrackId => $composableBuilder(
    column: $table.dstProviderTrackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchMethod => $composableBuilder(
    column: $table.matchMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signalsJson => $composableBuilder(
    column: $table.signalsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decidedBy => $composableBuilder(
    column: $table.decidedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackSnapshotsTableFilterComposer get srcTrackId {
    final $$TrackSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcTrackId,
      referencedTable: $db.trackSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.trackSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> jobItemsRefs(
    Expression<bool> Function($$JobItemsTableFilterComposer f) f,
  ) {
    final $$JobItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobItems,
      getReferencedColumn: (t) => t.mappingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobItemsTableFilterComposer(
            $db: $db,
            $table: $db.jobItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackMappingsTableOrderingComposer
    extends Composer<_$BridgetuneDatabase, $TrackMappingsTable> {
  $$TrackMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dstProviderId => $composableBuilder(
    column: $table.dstProviderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dstProviderTrackId => $composableBuilder(
    column: $table.dstProviderTrackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchMethod => $composableBuilder(
    column: $table.matchMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signalsJson => $composableBuilder(
    column: $table.signalsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decidedBy => $composableBuilder(
    column: $table.decidedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackSnapshotsTableOrderingComposer get srcTrackId {
    final $$TrackSnapshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcTrackId,
      referencedTable: $db.trackSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackSnapshotsTableOrderingComposer(
            $db: $db,
            $table: $db.trackSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackMappingsTableAnnotationComposer
    extends Composer<_$BridgetuneDatabase, $TrackMappingsTable> {
  $$TrackMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dstProviderId => $composableBuilder(
    column: $table.dstProviderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dstProviderTrackId => $composableBuilder(
    column: $table.dstProviderTrackId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchMethod => $composableBuilder(
    column: $table.matchMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get signalsJson => $composableBuilder(
    column: $table.signalsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decidedBy =>
      $composableBuilder(column: $table.decidedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TrackSnapshotsTableAnnotationComposer get srcTrackId {
    final $$TrackSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcTrackId,
      referencedTable: $db.trackSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> jobItemsRefs<T extends Object>(
    Expression<T> Function($$JobItemsTableAnnotationComposer a) f,
  ) {
    final $$JobItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobItems,
      getReferencedColumn: (t) => t.mappingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackMappingsTableTableManager
    extends
        RootTableManager<
          _$BridgetuneDatabase,
          $TrackMappingsTable,
          TrackMapping,
          $$TrackMappingsTableFilterComposer,
          $$TrackMappingsTableOrderingComposer,
          $$TrackMappingsTableAnnotationComposer,
          $$TrackMappingsTableCreateCompanionBuilder,
          $$TrackMappingsTableUpdateCompanionBuilder,
          (TrackMapping, $$TrackMappingsTableReferences),
          TrackMapping,
          PrefetchHooks Function({bool srcTrackId, bool jobItemsRefs})
        > {
  $$TrackMappingsTableTableManager(
    _$BridgetuneDatabase db,
    $TrackMappingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackMappingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> srcTrackId = const Value.absent(),
                Value<String> dstProviderId = const Value.absent(),
                Value<String?> dstProviderTrackId = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> matchMethod = const Value.absent(),
                Value<String> signalsJson = const Value.absent(),
                Value<String> decidedBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackMappingsCompanion(
                id: id,
                srcTrackId: srcTrackId,
                dstProviderId: dstProviderId,
                dstProviderTrackId: dstProviderTrackId,
                confidence: confidence,
                matchMethod: matchMethod,
                signalsJson: signalsJson,
                decidedBy: decidedBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String srcTrackId,
                required String dstProviderId,
                Value<String?> dstProviderTrackId = const Value.absent(),
                required double confidence,
                required String matchMethod,
                Value<String> signalsJson = const Value.absent(),
                required String decidedBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TrackMappingsCompanion.insert(
                id: id,
                srcTrackId: srcTrackId,
                dstProviderId: dstProviderId,
                dstProviderTrackId: dstProviderTrackId,
                confidence: confidence,
                matchMethod: matchMethod,
                signalsJson: signalsJson,
                decidedBy: decidedBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackMappingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({srcTrackId = false, jobItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (jobItemsRefs) db.jobItems],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (srcTrackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.srcTrackId,
                                referencedTable: $$TrackMappingsTableReferences
                                    ._srcTrackIdTable(db),
                                referencedColumn: $$TrackMappingsTableReferences
                                    ._srcTrackIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (jobItemsRefs)
                    await $_getPrefetchedData<
                      TrackMapping,
                      $TrackMappingsTable,
                      JobItem
                    >(
                      currentTable: table,
                      referencedTable: $$TrackMappingsTableReferences
                          ._jobItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TrackMappingsTableReferences(
                            db,
                            table,
                            p0,
                          ).jobItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.mappingId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TrackMappingsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgetuneDatabase,
      $TrackMappingsTable,
      TrackMapping,
      $$TrackMappingsTableFilterComposer,
      $$TrackMappingsTableOrderingComposer,
      $$TrackMappingsTableAnnotationComposer,
      $$TrackMappingsTableCreateCompanionBuilder,
      $$TrackMappingsTableUpdateCompanionBuilder,
      (TrackMapping, $$TrackMappingsTableReferences),
      TrackMapping,
      PrefetchHooks Function({bool srcTrackId, bool jobItemsRefs})
    >;
typedef $$PlaylistSnapshotsTableCreateCompanionBuilder =
    PlaylistSnapshotsCompanion Function({
      required String id,
      required String accountId,
      required String providerPlaylistId,
      required String name,
      Value<String?> description,
      Value<String?> privacy,
      Value<bool> collaborative,
      Value<String?> artworkUrl,
      Value<int> trackCount,
      required String contentHash,
      Value<String?> providerEtag,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$PlaylistSnapshotsTableUpdateCompanionBuilder =
    PlaylistSnapshotsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String> providerPlaylistId,
      Value<String> name,
      Value<String?> description,
      Value<String?> privacy,
      Value<bool> collaborative,
      Value<String?> artworkUrl,
      Value<int> trackCount,
      Value<String> contentHash,
      Value<String?> providerEtag,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

final class $$PlaylistSnapshotsTableReferences
    extends
        BaseReferences<
          _$BridgetuneDatabase,
          $PlaylistSnapshotsTable,
          PlaylistSnapshot
        > {
  $$PlaylistSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProviderAccountsTable _accountIdTable(_$BridgetuneDatabase db) =>
      db.providerAccounts.createAlias(
        $_aliasNameGenerator(
          db.playlistSnapshots.accountId,
          db.providerAccounts.id,
        ),
      );

  $$ProviderAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$ProviderAccountsTableTableManager(
      $_db,
      $_db.providerAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PlaylistTrackSnapshotsTable,
    List<PlaylistTrackSnapshot>
  >
  _playlistTrackSnapshotsRefsTable(_$BridgetuneDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistTrackSnapshots,
        aliasName: $_aliasNameGenerator(
          db.playlistSnapshots.id,
          db.playlistTrackSnapshots.playlistId,
        ),
      );

  $$PlaylistTrackSnapshotsTableProcessedTableManager
  get playlistTrackSnapshotsRefs {
    final manager = $$PlaylistTrackSnapshotsTableTableManager(
      $_db,
      $_db.playlistTrackSnapshots,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistTrackSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistSnapshotsTableFilterComposer
    extends Composer<_$BridgetuneDatabase, $PlaylistSnapshotsTable> {
  $$PlaylistSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerPlaylistId => $composableBuilder(
    column: $table.providerPlaylistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacy => $composableBuilder(
    column: $table.privacy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get collaborative => $composableBuilder(
    column: $table.collaborative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerEtag => $composableBuilder(
    column: $table.providerEtag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProviderAccountsTableFilterComposer get accountId {
    final $$ProviderAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.providerAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderAccountsTableFilterComposer(
            $db: $db,
            $table: $db.providerAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> playlistTrackSnapshotsRefs(
    Expression<bool> Function($$PlaylistTrackSnapshotsTableFilterComposer f) f,
  ) {
    final $$PlaylistTrackSnapshotsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistTrackSnapshots,
          getReferencedColumn: (t) => t.playlistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistTrackSnapshotsTableFilterComposer(
                $db: $db,
                $table: $db.playlistTrackSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlaylistSnapshotsTableOrderingComposer
    extends Composer<_$BridgetuneDatabase, $PlaylistSnapshotsTable> {
  $$PlaylistSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerPlaylistId => $composableBuilder(
    column: $table.providerPlaylistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacy => $composableBuilder(
    column: $table.privacy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get collaborative => $composableBuilder(
    column: $table.collaborative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerEtag => $composableBuilder(
    column: $table.providerEtag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProviderAccountsTableOrderingComposer get accountId {
    final $$ProviderAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.providerAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.providerAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSnapshotsTableAnnotationComposer
    extends Composer<_$BridgetuneDatabase, $PlaylistSnapshotsTable> {
  $$PlaylistSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerPlaylistId => $composableBuilder(
    column: $table.providerPlaylistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privacy =>
      $composableBuilder(column: $table.privacy, builder: (column) => column);

  GeneratedColumn<bool> get collaborative => $composableBuilder(
    column: $table.collaborative,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerEtag => $composableBuilder(
    column: $table.providerEtag,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$ProviderAccountsTableAnnotationComposer get accountId {
    final $$ProviderAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.providerAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.providerAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> playlistTrackSnapshotsRefs<T extends Object>(
    Expression<T> Function($$PlaylistTrackSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTrackSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistTrackSnapshots,
          getReferencedColumn: (t) => t.playlistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistTrackSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistTrackSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlaylistSnapshotsTableTableManager
    extends
        RootTableManager<
          _$BridgetuneDatabase,
          $PlaylistSnapshotsTable,
          PlaylistSnapshot,
          $$PlaylistSnapshotsTableFilterComposer,
          $$PlaylistSnapshotsTableOrderingComposer,
          $$PlaylistSnapshotsTableAnnotationComposer,
          $$PlaylistSnapshotsTableCreateCompanionBuilder,
          $$PlaylistSnapshotsTableUpdateCompanionBuilder,
          (PlaylistSnapshot, $$PlaylistSnapshotsTableReferences),
          PlaylistSnapshot,
          PrefetchHooks Function({
            bool accountId,
            bool playlistTrackSnapshotsRefs,
          })
        > {
  $$PlaylistSnapshotsTableTableManager(
    _$BridgetuneDatabase db,
    $PlaylistSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> providerPlaylistId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> privacy = const Value.absent(),
                Value<bool> collaborative = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                Value<int> trackCount = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String?> providerEtag = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSnapshotsCompanion(
                id: id,
                accountId: accountId,
                providerPlaylistId: providerPlaylistId,
                name: name,
                description: description,
                privacy: privacy,
                collaborative: collaborative,
                artworkUrl: artworkUrl,
                trackCount: trackCount,
                contentHash: contentHash,
                providerEtag: providerEtag,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required String providerPlaylistId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> privacy = const Value.absent(),
                Value<bool> collaborative = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                Value<int> trackCount = const Value.absent(),
                required String contentHash,
                Value<String?> providerEtag = const Value.absent(),
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSnapshotsCompanion.insert(
                id: id,
                accountId: accountId,
                providerPlaylistId: providerPlaylistId,
                name: name,
                description: description,
                privacy: privacy,
                collaborative: collaborative,
                artworkUrl: artworkUrl,
                trackCount: trackCount,
                contentHash: contentHash,
                providerEtag: providerEtag,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({accountId = false, playlistTrackSnapshotsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistTrackSnapshotsRefs) db.playlistTrackSnapshots,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable:
                                        $$PlaylistSnapshotsTableReferences
                                            ._accountIdTable(db),
                                    referencedColumn:
                                        $$PlaylistSnapshotsTableReferences
                                            ._accountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playlistTrackSnapshotsRefs)
                        await $_getPrefetchedData<
                          PlaylistSnapshot,
                          $PlaylistSnapshotsTable,
                          PlaylistTrackSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistSnapshotsTableReferences
                              ._playlistTrackSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistSnapshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistTrackSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playlistId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlaylistSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgetuneDatabase,
      $PlaylistSnapshotsTable,
      PlaylistSnapshot,
      $$PlaylistSnapshotsTableFilterComposer,
      $$PlaylistSnapshotsTableOrderingComposer,
      $$PlaylistSnapshotsTableAnnotationComposer,
      $$PlaylistSnapshotsTableCreateCompanionBuilder,
      $$PlaylistSnapshotsTableUpdateCompanionBuilder,
      (PlaylistSnapshot, $$PlaylistSnapshotsTableReferences),
      PlaylistSnapshot,
      PrefetchHooks Function({bool accountId, bool playlistTrackSnapshotsRefs})
    >;
typedef $$PlaylistTrackSnapshotsTableCreateCompanionBuilder =
    PlaylistTrackSnapshotsCompanion Function({
      required String playlistId,
      required String trackId,
      required int position,
      Value<DateTime?> addedAt,
      Value<int> rowid,
    });
typedef $$PlaylistTrackSnapshotsTableUpdateCompanionBuilder =
    PlaylistTrackSnapshotsCompanion Function({
      Value<String> playlistId,
      Value<String> trackId,
      Value<int> position,
      Value<DateTime?> addedAt,
      Value<int> rowid,
    });

final class $$PlaylistTrackSnapshotsTableReferences
    extends
        BaseReferences<
          _$BridgetuneDatabase,
          $PlaylistTrackSnapshotsTable,
          PlaylistTrackSnapshot
        > {
  $$PlaylistTrackSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistSnapshotsTable _playlistIdTable(_$BridgetuneDatabase db) =>
      db.playlistSnapshots.createAlias(
        $_aliasNameGenerator(
          db.playlistTrackSnapshots.playlistId,
          db.playlistSnapshots.id,
        ),
      );

  $$PlaylistSnapshotsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistSnapshotsTableTableManager(
      $_db,
      $_db.playlistSnapshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TrackSnapshotsTable _trackIdTable(_$BridgetuneDatabase db) =>
      db.trackSnapshots.createAlias(
        $_aliasNameGenerator(
          db.playlistTrackSnapshots.trackId,
          db.trackSnapshots.id,
        ),
      );

  $$TrackSnapshotsTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TrackSnapshotsTableTableManager(
      $_db,
      $_db.trackSnapshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistTrackSnapshotsTableFilterComposer
    extends Composer<_$BridgetuneDatabase, $PlaylistTrackSnapshotsTable> {
  $$PlaylistTrackSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistSnapshotsTableFilterComposer get playlistId {
    final $$PlaylistSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.playlistSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackSnapshotsTableFilterComposer get trackId {
    final $$TrackSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.trackSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.trackSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTrackSnapshotsTableOrderingComposer
    extends Composer<_$BridgetuneDatabase, $PlaylistTrackSnapshotsTable> {
  $$PlaylistTrackSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistSnapshotsTableOrderingComposer get playlistId {
    final $$PlaylistSnapshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSnapshotsTableOrderingComposer(
            $db: $db,
            $table: $db.playlistSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackSnapshotsTableOrderingComposer get trackId {
    final $$TrackSnapshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.trackSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackSnapshotsTableOrderingComposer(
            $db: $db,
            $table: $db.trackSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTrackSnapshotsTableAnnotationComposer
    extends Composer<_$BridgetuneDatabase, $PlaylistTrackSnapshotsTable> {
  $$PlaylistTrackSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$PlaylistSnapshotsTableAnnotationComposer get playlistId {
    final $$PlaylistSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.playlistId,
          referencedTable: $db.playlistSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TrackSnapshotsTableAnnotationComposer get trackId {
    final $$TrackSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.trackSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTrackSnapshotsTableTableManager
    extends
        RootTableManager<
          _$BridgetuneDatabase,
          $PlaylistTrackSnapshotsTable,
          PlaylistTrackSnapshot,
          $$PlaylistTrackSnapshotsTableFilterComposer,
          $$PlaylistTrackSnapshotsTableOrderingComposer,
          $$PlaylistTrackSnapshotsTableAnnotationComposer,
          $$PlaylistTrackSnapshotsTableCreateCompanionBuilder,
          $$PlaylistTrackSnapshotsTableUpdateCompanionBuilder,
          (PlaylistTrackSnapshot, $$PlaylistTrackSnapshotsTableReferences),
          PlaylistTrackSnapshot,
          PrefetchHooks Function({bool playlistId, bool trackId})
        > {
  $$PlaylistTrackSnapshotsTableTableManager(
    _$BridgetuneDatabase db,
    $PlaylistTrackSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTrackSnapshotsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PlaylistTrackSnapshotsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaylistTrackSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTrackSnapshotsCompanion(
                playlistId: playlistId,
                trackId: trackId,
                position: position,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String trackId,
                required int position,
                Value<DateTime?> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTrackSnapshotsCompanion.insert(
                playlistId: playlistId,
                trackId: trackId,
                position: position,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistTrackSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable:
                                    $$PlaylistTrackSnapshotsTableReferences
                                        ._playlistIdTable(db),
                                referencedColumn:
                                    $$PlaylistTrackSnapshotsTableReferences
                                        ._playlistIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable:
                                    $$PlaylistTrackSnapshotsTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$PlaylistTrackSnapshotsTableReferences
                                        ._trackIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistTrackSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgetuneDatabase,
      $PlaylistTrackSnapshotsTable,
      PlaylistTrackSnapshot,
      $$PlaylistTrackSnapshotsTableFilterComposer,
      $$PlaylistTrackSnapshotsTableOrderingComposer,
      $$PlaylistTrackSnapshotsTableAnnotationComposer,
      $$PlaylistTrackSnapshotsTableCreateCompanionBuilder,
      $$PlaylistTrackSnapshotsTableUpdateCompanionBuilder,
      (PlaylistTrackSnapshot, $$PlaylistTrackSnapshotsTableReferences),
      PlaylistTrackSnapshot,
      PrefetchHooks Function({bool playlistId, bool trackId})
    >;
typedef $$TransferJobsTableCreateCompanionBuilder =
    TransferJobsCompanion Function({
      required String id,
      required String kind,
      required String srcAccountId,
      required String dstAccountId,
      required String specJson,
      required String state,
      Value<int> progressDone,
      Value<int> progressTotal,
      Value<String?> errorJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> finishedAt,
      Value<int> rowid,
    });
typedef $$TransferJobsTableUpdateCompanionBuilder =
    TransferJobsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> srcAccountId,
      Value<String> dstAccountId,
      Value<String> specJson,
      Value<String> state,
      Value<int> progressDone,
      Value<int> progressTotal,
      Value<String?> errorJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> finishedAt,
      Value<int> rowid,
    });

final class $$TransferJobsTableReferences
    extends
        BaseReferences<_$BridgetuneDatabase, $TransferJobsTable, TransferJob> {
  $$TransferJobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProviderAccountsTable _srcAccountIdTable(_$BridgetuneDatabase db) =>
      db.providerAccounts.createAlias(
        $_aliasNameGenerator(
          db.transferJobs.srcAccountId,
          db.providerAccounts.id,
        ),
      );

  $$ProviderAccountsTableProcessedTableManager get srcAccountId {
    final $_column = $_itemColumn<String>('src_account_id')!;

    final manager = $$ProviderAccountsTableTableManager(
      $_db,
      $_db.providerAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_srcAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProviderAccountsTable _dstAccountIdTable(_$BridgetuneDatabase db) =>
      db.providerAccounts.createAlias(
        $_aliasNameGenerator(
          db.transferJobs.dstAccountId,
          db.providerAccounts.id,
        ),
      );

  $$ProviderAccountsTableProcessedTableManager get dstAccountId {
    final $_column = $_itemColumn<String>('dst_account_id')!;

    final manager = $$ProviderAccountsTableTableManager(
      $_db,
      $_db.providerAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dstAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$JobItemsTable, List<JobItem>> _jobItemsRefsTable(
    _$BridgetuneDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobItems,
    aliasName: $_aliasNameGenerator(db.transferJobs.id, db.jobItems.jobId),
  );

  $$JobItemsTableProcessedTableManager get jobItemsRefs {
    final manager = $$JobItemsTableTableManager(
      $_db,
      $_db.jobItems,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransferJobsTableFilterComposer
    extends Composer<_$BridgetuneDatabase, $TransferJobsTable> {
  $$TransferJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specJson => $composableBuilder(
    column: $table.specJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressDone => $composableBuilder(
    column: $table.progressDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressTotal => $composableBuilder(
    column: $table.progressTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorJson => $composableBuilder(
    column: $table.errorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProviderAccountsTableFilterComposer get srcAccountId {
    final $$ProviderAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcAccountId,
      referencedTable: $db.providerAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderAccountsTableFilterComposer(
            $db: $db,
            $table: $db.providerAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProviderAccountsTableFilterComposer get dstAccountId {
    final $$ProviderAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dstAccountId,
      referencedTable: $db.providerAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderAccountsTableFilterComposer(
            $db: $db,
            $table: $db.providerAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> jobItemsRefs(
    Expression<bool> Function($$JobItemsTableFilterComposer f) f,
  ) {
    final $$JobItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobItems,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobItemsTableFilterComposer(
            $db: $db,
            $table: $db.jobItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransferJobsTableOrderingComposer
    extends Composer<_$BridgetuneDatabase, $TransferJobsTable> {
  $$TransferJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specJson => $composableBuilder(
    column: $table.specJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressDone => $composableBuilder(
    column: $table.progressDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressTotal => $composableBuilder(
    column: $table.progressTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorJson => $composableBuilder(
    column: $table.errorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProviderAccountsTableOrderingComposer get srcAccountId {
    final $$ProviderAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcAccountId,
      referencedTable: $db.providerAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.providerAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProviderAccountsTableOrderingComposer get dstAccountId {
    final $$ProviderAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dstAccountId,
      referencedTable: $db.providerAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.providerAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransferJobsTableAnnotationComposer
    extends Composer<_$BridgetuneDatabase, $TransferJobsTable> {
  $$TransferJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get specJson =>
      $composableBuilder(column: $table.specJson, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get progressDone => $composableBuilder(
    column: $table.progressDone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progressTotal => $composableBuilder(
    column: $table.progressTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorJson =>
      $composableBuilder(column: $table.errorJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  $$ProviderAccountsTableAnnotationComposer get srcAccountId {
    final $$ProviderAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcAccountId,
      referencedTable: $db.providerAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.providerAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProviderAccountsTableAnnotationComposer get dstAccountId {
    final $$ProviderAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dstAccountId,
      referencedTable: $db.providerAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.providerAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> jobItemsRefs<T extends Object>(
    Expression<T> Function($$JobItemsTableAnnotationComposer a) f,
  ) {
    final $$JobItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobItems,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransferJobsTableTableManager
    extends
        RootTableManager<
          _$BridgetuneDatabase,
          $TransferJobsTable,
          TransferJob,
          $$TransferJobsTableFilterComposer,
          $$TransferJobsTableOrderingComposer,
          $$TransferJobsTableAnnotationComposer,
          $$TransferJobsTableCreateCompanionBuilder,
          $$TransferJobsTableUpdateCompanionBuilder,
          (TransferJob, $$TransferJobsTableReferences),
          TransferJob,
          PrefetchHooks Function({
            bool srcAccountId,
            bool dstAccountId,
            bool jobItemsRefs,
          })
        > {
  $$TransferJobsTableTableManager(
    _$BridgetuneDatabase db,
    $TransferJobsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransferJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransferJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransferJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> srcAccountId = const Value.absent(),
                Value<String> dstAccountId = const Value.absent(),
                Value<String> specJson = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> progressDone = const Value.absent(),
                Value<int> progressTotal = const Value.absent(),
                Value<String?> errorJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransferJobsCompanion(
                id: id,
                kind: kind,
                srcAccountId: srcAccountId,
                dstAccountId: dstAccountId,
                specJson: specJson,
                state: state,
                progressDone: progressDone,
                progressTotal: progressTotal,
                errorJson: errorJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                finishedAt: finishedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String srcAccountId,
                required String dstAccountId,
                required String specJson,
                required String state,
                Value<int> progressDone = const Value.absent(),
                Value<int> progressTotal = const Value.absent(),
                Value<String?> errorJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransferJobsCompanion.insert(
                id: id,
                kind: kind,
                srcAccountId: srcAccountId,
                dstAccountId: dstAccountId,
                specJson: specJson,
                state: state,
                progressDone: progressDone,
                progressTotal: progressTotal,
                errorJson: errorJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                finishedAt: finishedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransferJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                srcAccountId = false,
                dstAccountId = false,
                jobItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (jobItemsRefs) db.jobItems],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (srcAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.srcAccountId,
                                    referencedTable:
                                        $$TransferJobsTableReferences
                                            ._srcAccountIdTable(db),
                                    referencedColumn:
                                        $$TransferJobsTableReferences
                                            ._srcAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (dstAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dstAccountId,
                                    referencedTable:
                                        $$TransferJobsTableReferences
                                            ._dstAccountIdTable(db),
                                    referencedColumn:
                                        $$TransferJobsTableReferences
                                            ._dstAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (jobItemsRefs)
                        await $_getPrefetchedData<
                          TransferJob,
                          $TransferJobsTable,
                          JobItem
                        >(
                          currentTable: table,
                          referencedTable: $$TransferJobsTableReferences
                              ._jobItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransferJobsTableReferences(
                                db,
                                table,
                                p0,
                              ).jobItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jobId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransferJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgetuneDatabase,
      $TransferJobsTable,
      TransferJob,
      $$TransferJobsTableFilterComposer,
      $$TransferJobsTableOrderingComposer,
      $$TransferJobsTableAnnotationComposer,
      $$TransferJobsTableCreateCompanionBuilder,
      $$TransferJobsTableUpdateCompanionBuilder,
      (TransferJob, $$TransferJobsTableReferences),
      TransferJob,
      PrefetchHooks Function({
        bool srcAccountId,
        bool dstAccountId,
        bool jobItemsRefs,
      })
    >;
typedef $$JobItemsTableCreateCompanionBuilder =
    JobItemsCompanion Function({
      required String id,
      required String jobId,
      required int seq,
      required String srcTrackId,
      Value<String?> mappingId,
      required String state,
      Value<String?> resolvedDstId,
      Value<int> attemptCount,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$JobItemsTableUpdateCompanionBuilder =
    JobItemsCompanion Function({
      Value<String> id,
      Value<String> jobId,
      Value<int> seq,
      Value<String> srcTrackId,
      Value<String?> mappingId,
      Value<String> state,
      Value<String?> resolvedDstId,
      Value<int> attemptCount,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
      Value<int> rowid,
    });

final class $$JobItemsTableReferences
    extends BaseReferences<_$BridgetuneDatabase, $JobItemsTable, JobItem> {
  $$JobItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransferJobsTable _jobIdTable(_$BridgetuneDatabase db) => db
      .transferJobs
      .createAlias($_aliasNameGenerator(db.jobItems.jobId, db.transferJobs.id));

  $$TransferJobsTableProcessedTableManager get jobId {
    final $_column = $_itemColumn<String>('job_id')!;

    final manager = $$TransferJobsTableTableManager(
      $_db,
      $_db.transferJobs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TrackSnapshotsTable _srcTrackIdTable(_$BridgetuneDatabase db) =>
      db.trackSnapshots.createAlias(
        $_aliasNameGenerator(db.jobItems.srcTrackId, db.trackSnapshots.id),
      );

  $$TrackSnapshotsTableProcessedTableManager get srcTrackId {
    final $_column = $_itemColumn<String>('src_track_id')!;

    final manager = $$TrackSnapshotsTableTableManager(
      $_db,
      $_db.trackSnapshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_srcTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TrackMappingsTable _mappingIdTable(_$BridgetuneDatabase db) =>
      db.trackMappings.createAlias(
        $_aliasNameGenerator(db.jobItems.mappingId, db.trackMappings.id),
      );

  $$TrackMappingsTableProcessedTableManager? get mappingId {
    final $_column = $_itemColumn<String>('mapping_id');
    if ($_column == null) return null;
    final manager = $$TrackMappingsTableTableManager(
      $_db,
      $_db.trackMappings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mappingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JobItemsTableFilterComposer
    extends Composer<_$BridgetuneDatabase, $JobItemsTable> {
  $$JobItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedDstId => $composableBuilder(
    column: $table.resolvedDstId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  $$TransferJobsTableFilterComposer get jobId {
    final $$TransferJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.transferJobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransferJobsTableFilterComposer(
            $db: $db,
            $table: $db.transferJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackSnapshotsTableFilterComposer get srcTrackId {
    final $$TrackSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcTrackId,
      referencedTable: $db.trackSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.trackSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackMappingsTableFilterComposer get mappingId {
    final $$TrackMappingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mappingId,
      referencedTable: $db.trackMappings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackMappingsTableFilterComposer(
            $db: $db,
            $table: $db.trackMappings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobItemsTableOrderingComposer
    extends Composer<_$BridgetuneDatabase, $JobItemsTable> {
  $$JobItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedDstId => $composableBuilder(
    column: $table.resolvedDstId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransferJobsTableOrderingComposer get jobId {
    final $$TransferJobsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.transferJobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransferJobsTableOrderingComposer(
            $db: $db,
            $table: $db.transferJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackSnapshotsTableOrderingComposer get srcTrackId {
    final $$TrackSnapshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcTrackId,
      referencedTable: $db.trackSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackSnapshotsTableOrderingComposer(
            $db: $db,
            $table: $db.trackSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackMappingsTableOrderingComposer get mappingId {
    final $$TrackMappingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mappingId,
      referencedTable: $db.trackMappings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackMappingsTableOrderingComposer(
            $db: $db,
            $table: $db.trackMappings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobItemsTableAnnotationComposer
    extends Composer<_$BridgetuneDatabase, $JobItemsTable> {
  $$JobItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get resolvedDstId => $composableBuilder(
    column: $table.resolvedDstId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  $$TransferJobsTableAnnotationComposer get jobId {
    final $$TransferJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.transferJobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransferJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.transferJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackSnapshotsTableAnnotationComposer get srcTrackId {
    final $$TrackSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcTrackId,
      referencedTable: $db.trackSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackMappingsTableAnnotationComposer get mappingId {
    final $$TrackMappingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mappingId,
      referencedTable: $db.trackMappings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackMappingsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackMappings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobItemsTableTableManager
    extends
        RootTableManager<
          _$BridgetuneDatabase,
          $JobItemsTable,
          JobItem,
          $$JobItemsTableFilterComposer,
          $$JobItemsTableOrderingComposer,
          $$JobItemsTableAnnotationComposer,
          $$JobItemsTableCreateCompanionBuilder,
          $$JobItemsTableUpdateCompanionBuilder,
          (JobItem, $$JobItemsTableReferences),
          JobItem,
          PrefetchHooks Function({bool jobId, bool srcTrackId, bool mappingId})
        > {
  $$JobItemsTableTableManager(_$BridgetuneDatabase db, $JobItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jobId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> srcTrackId = const Value.absent(),
                Value<String?> mappingId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> resolvedDstId = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobItemsCompanion(
                id: id,
                jobId: jobId,
                seq: seq,
                srcTrackId: srcTrackId,
                mappingId: mappingId,
                state: state,
                resolvedDstId: resolvedDstId,
                attemptCount: attemptCount,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String jobId,
                required int seq,
                required String srcTrackId,
                Value<String?> mappingId = const Value.absent(),
                required String state,
                Value<String?> resolvedDstId = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobItemsCompanion.insert(
                id: id,
                jobId: jobId,
                seq: seq,
                srcTrackId: srcTrackId,
                mappingId: mappingId,
                state: state,
                resolvedDstId: resolvedDstId,
                attemptCount: attemptCount,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JobItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({jobId = false, srcTrackId = false, mappingId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (jobId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.jobId,
                                    referencedTable: $$JobItemsTableReferences
                                        ._jobIdTable(db),
                                    referencedColumn: $$JobItemsTableReferences
                                        ._jobIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (srcTrackId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.srcTrackId,
                                    referencedTable: $$JobItemsTableReferences
                                        ._srcTrackIdTable(db),
                                    referencedColumn: $$JobItemsTableReferences
                                        ._srcTrackIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (mappingId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.mappingId,
                                    referencedTable: $$JobItemsTableReferences
                                        ._mappingIdTable(db),
                                    referencedColumn: $$JobItemsTableReferences
                                        ._mappingIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$JobItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgetuneDatabase,
      $JobItemsTable,
      JobItem,
      $$JobItemsTableFilterComposer,
      $$JobItemsTableOrderingComposer,
      $$JobItemsTableAnnotationComposer,
      $$JobItemsTableCreateCompanionBuilder,
      $$JobItemsTableUpdateCompanionBuilder,
      (JobItem, $$JobItemsTableReferences),
      JobItem,
      PrefetchHooks Function({bool jobId, bool srcTrackId, bool mappingId})
    >;
typedef $$SyncPairsTableCreateCompanionBuilder =
    SyncPairsCompanion Function({
      required String id,
      required String srcPlaylistId,
      required String dstPlaylistId,
      required String mode,
      required String conflictPolicy,
      Value<String?> scheduleCron,
      Value<bool> enabled,
      Value<DateTime?> lastSyncedAt,
      Value<String?> baseStateJson,
      Value<int> rowid,
    });
typedef $$SyncPairsTableUpdateCompanionBuilder =
    SyncPairsCompanion Function({
      Value<String> id,
      Value<String> srcPlaylistId,
      Value<String> dstPlaylistId,
      Value<String> mode,
      Value<String> conflictPolicy,
      Value<String?> scheduleCron,
      Value<bool> enabled,
      Value<DateTime?> lastSyncedAt,
      Value<String?> baseStateJson,
      Value<int> rowid,
    });

final class $$SyncPairsTableReferences
    extends BaseReferences<_$BridgetuneDatabase, $SyncPairsTable, SyncPair> {
  $$SyncPairsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlaylistSnapshotsTable _srcPlaylistIdTable(_$BridgetuneDatabase db) =>
      db.playlistSnapshots.createAlias(
        $_aliasNameGenerator(
          db.syncPairs.srcPlaylistId,
          db.playlistSnapshots.id,
        ),
      );

  $$PlaylistSnapshotsTableProcessedTableManager get srcPlaylistId {
    final $_column = $_itemColumn<String>('src_playlist_id')!;

    final manager = $$PlaylistSnapshotsTableTableManager(
      $_db,
      $_db.playlistSnapshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_srcPlaylistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlaylistSnapshotsTable _dstPlaylistIdTable(_$BridgetuneDatabase db) =>
      db.playlistSnapshots.createAlias(
        $_aliasNameGenerator(
          db.syncPairs.dstPlaylistId,
          db.playlistSnapshots.id,
        ),
      );

  $$PlaylistSnapshotsTableProcessedTableManager get dstPlaylistId {
    final $_column = $_itemColumn<String>('dst_playlist_id')!;

    final manager = $$PlaylistSnapshotsTableTableManager(
      $_db,
      $_db.playlistSnapshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dstPlaylistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SyncRunsTable, List<SyncRun>> _syncRunsRefsTable(
    _$BridgetuneDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.syncRuns,
    aliasName: $_aliasNameGenerator(db.syncPairs.id, db.syncRuns.pairId),
  );

  $$SyncRunsTableProcessedTableManager get syncRunsRefs {
    final manager = $$SyncRunsTableTableManager(
      $_db,
      $_db.syncRuns,
    ).filter((f) => f.pairId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncRunsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SyncPairsTableFilterComposer
    extends Composer<_$BridgetuneDatabase, $SyncPairsTable> {
  $$SyncPairsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictPolicy => $composableBuilder(
    column: $table.conflictPolicy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleCron => $composableBuilder(
    column: $table.scheduleCron,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseStateJson => $composableBuilder(
    column: $table.baseStateJson,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistSnapshotsTableFilterComposer get srcPlaylistId {
    final $$PlaylistSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcPlaylistId,
      referencedTable: $db.playlistSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.playlistSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlaylistSnapshotsTableFilterComposer get dstPlaylistId {
    final $$PlaylistSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dstPlaylistId,
      referencedTable: $db.playlistSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.playlistSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> syncRunsRefs(
    Expression<bool> Function($$SyncRunsTableFilterComposer f) f,
  ) {
    final $$SyncRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncRuns,
      getReferencedColumn: (t) => t.pairId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncRunsTableFilterComposer(
            $db: $db,
            $table: $db.syncRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncPairsTableOrderingComposer
    extends Composer<_$BridgetuneDatabase, $SyncPairsTable> {
  $$SyncPairsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictPolicy => $composableBuilder(
    column: $table.conflictPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleCron => $composableBuilder(
    column: $table.scheduleCron,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseStateJson => $composableBuilder(
    column: $table.baseStateJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistSnapshotsTableOrderingComposer get srcPlaylistId {
    final $$PlaylistSnapshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.srcPlaylistId,
      referencedTable: $db.playlistSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSnapshotsTableOrderingComposer(
            $db: $db,
            $table: $db.playlistSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlaylistSnapshotsTableOrderingComposer get dstPlaylistId {
    final $$PlaylistSnapshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dstPlaylistId,
      referencedTable: $db.playlistSnapshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSnapshotsTableOrderingComposer(
            $db: $db,
            $table: $db.playlistSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncPairsTableAnnotationComposer
    extends Composer<_$BridgetuneDatabase, $SyncPairsTable> {
  $$SyncPairsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get conflictPolicy => $composableBuilder(
    column: $table.conflictPolicy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleCron => $composableBuilder(
    column: $table.scheduleCron,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseStateJson => $composableBuilder(
    column: $table.baseStateJson,
    builder: (column) => column,
  );

  $$PlaylistSnapshotsTableAnnotationComposer get srcPlaylistId {
    final $$PlaylistSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.srcPlaylistId,
          referencedTable: $db.playlistSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$PlaylistSnapshotsTableAnnotationComposer get dstPlaylistId {
    final $$PlaylistSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.dstPlaylistId,
          referencedTable: $db.playlistSnapshots,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> syncRunsRefs<T extends Object>(
    Expression<T> Function($$SyncRunsTableAnnotationComposer a) f,
  ) {
    final $$SyncRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncRuns,
      getReferencedColumn: (t) => t.pairId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncPairsTableTableManager
    extends
        RootTableManager<
          _$BridgetuneDatabase,
          $SyncPairsTable,
          SyncPair,
          $$SyncPairsTableFilterComposer,
          $$SyncPairsTableOrderingComposer,
          $$SyncPairsTableAnnotationComposer,
          $$SyncPairsTableCreateCompanionBuilder,
          $$SyncPairsTableUpdateCompanionBuilder,
          (SyncPair, $$SyncPairsTableReferences),
          SyncPair,
          PrefetchHooks Function({
            bool srcPlaylistId,
            bool dstPlaylistId,
            bool syncRunsRefs,
          })
        > {
  $$SyncPairsTableTableManager(_$BridgetuneDatabase db, $SyncPairsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncPairsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncPairsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncPairsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> srcPlaylistId = const Value.absent(),
                Value<String> dstPlaylistId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> conflictPolicy = const Value.absent(),
                Value<String?> scheduleCron = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> baseStateJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncPairsCompanion(
                id: id,
                srcPlaylistId: srcPlaylistId,
                dstPlaylistId: dstPlaylistId,
                mode: mode,
                conflictPolicy: conflictPolicy,
                scheduleCron: scheduleCron,
                enabled: enabled,
                lastSyncedAt: lastSyncedAt,
                baseStateJson: baseStateJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String srcPlaylistId,
                required String dstPlaylistId,
                required String mode,
                required String conflictPolicy,
                Value<String?> scheduleCron = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> baseStateJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncPairsCompanion.insert(
                id: id,
                srcPlaylistId: srcPlaylistId,
                dstPlaylistId: dstPlaylistId,
                mode: mode,
                conflictPolicy: conflictPolicy,
                scheduleCron: scheduleCron,
                enabled: enabled,
                lastSyncedAt: lastSyncedAt,
                baseStateJson: baseStateJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SyncPairsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                srcPlaylistId = false,
                dstPlaylistId = false,
                syncRunsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (syncRunsRefs) db.syncRuns],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (srcPlaylistId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.srcPlaylistId,
                                    referencedTable: $$SyncPairsTableReferences
                                        ._srcPlaylistIdTable(db),
                                    referencedColumn: $$SyncPairsTableReferences
                                        ._srcPlaylistIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (dstPlaylistId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dstPlaylistId,
                                    referencedTable: $$SyncPairsTableReferences
                                        ._dstPlaylistIdTable(db),
                                    referencedColumn: $$SyncPairsTableReferences
                                        ._dstPlaylistIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (syncRunsRefs)
                        await $_getPrefetchedData<
                          SyncPair,
                          $SyncPairsTable,
                          SyncRun
                        >(
                          currentTable: table,
                          referencedTable: $$SyncPairsTableReferences
                              ._syncRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncPairsTableReferences(
                                db,
                                table,
                                p0,
                              ).syncRunsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pairId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SyncPairsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgetuneDatabase,
      $SyncPairsTable,
      SyncPair,
      $$SyncPairsTableFilterComposer,
      $$SyncPairsTableOrderingComposer,
      $$SyncPairsTableAnnotationComposer,
      $$SyncPairsTableCreateCompanionBuilder,
      $$SyncPairsTableUpdateCompanionBuilder,
      (SyncPair, $$SyncPairsTableReferences),
      SyncPair,
      PrefetchHooks Function({
        bool srcPlaylistId,
        bool dstPlaylistId,
        bool syncRunsRefs,
      })
    >;
typedef $$SyncRunsTableCreateCompanionBuilder =
    SyncRunsCompanion Function({
      required String id,
      required String pairId,
      required String trigger,
      required String state,
      Value<String?> diffJson,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      Value<int> rowid,
    });
typedef $$SyncRunsTableUpdateCompanionBuilder =
    SyncRunsCompanion Function({
      Value<String> id,
      Value<String> pairId,
      Value<String> trigger,
      Value<String> state,
      Value<String?> diffJson,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<int> rowid,
    });

final class $$SyncRunsTableReferences
    extends BaseReferences<_$BridgetuneDatabase, $SyncRunsTable, SyncRun> {
  $$SyncRunsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SyncPairsTable _pairIdTable(_$BridgetuneDatabase db) => db.syncPairs
      .createAlias($_aliasNameGenerator(db.syncRuns.pairId, db.syncPairs.id));

  $$SyncPairsTableProcessedTableManager get pairId {
    final $_column = $_itemColumn<String>('pair_id')!;

    final manager = $$SyncPairsTableTableManager(
      $_db,
      $_db.syncPairs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pairIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncRunsTableFilterComposer
    extends Composer<_$BridgetuneDatabase, $SyncRunsTable> {
  $$SyncRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diffJson => $composableBuilder(
    column: $table.diffJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncPairsTableFilterComposer get pairId {
    final $$SyncPairsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairId,
      referencedTable: $db.syncPairs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncPairsTableFilterComposer(
            $db: $db,
            $table: $db.syncPairs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncRunsTableOrderingComposer
    extends Composer<_$BridgetuneDatabase, $SyncRunsTable> {
  $$SyncRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diffJson => $composableBuilder(
    column: $table.diffJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncPairsTableOrderingComposer get pairId {
    final $$SyncPairsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairId,
      referencedTable: $db.syncPairs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncPairsTableOrderingComposer(
            $db: $db,
            $table: $db.syncPairs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncRunsTableAnnotationComposer
    extends Composer<_$BridgetuneDatabase, $SyncRunsTable> {
  $$SyncRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get diffJson =>
      $composableBuilder(column: $table.diffJson, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  $$SyncPairsTableAnnotationComposer get pairId {
    final $$SyncPairsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairId,
      referencedTable: $db.syncPairs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncPairsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncPairs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncRunsTableTableManager
    extends
        RootTableManager<
          _$BridgetuneDatabase,
          $SyncRunsTable,
          SyncRun,
          $$SyncRunsTableFilterComposer,
          $$SyncRunsTableOrderingComposer,
          $$SyncRunsTableAnnotationComposer,
          $$SyncRunsTableCreateCompanionBuilder,
          $$SyncRunsTableUpdateCompanionBuilder,
          (SyncRun, $$SyncRunsTableReferences),
          SyncRun,
          PrefetchHooks Function({bool pairId})
        > {
  $$SyncRunsTableTableManager(_$BridgetuneDatabase db, $SyncRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pairId = const Value.absent(),
                Value<String> trigger = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> diffJson = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncRunsCompanion(
                id: id,
                pairId: pairId,
                trigger: trigger,
                state: state,
                diffJson: diffJson,
                startedAt: startedAt,
                finishedAt: finishedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pairId,
                required String trigger,
                required String state,
                Value<String?> diffJson = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncRunsCompanion.insert(
                id: id,
                pairId: pairId,
                trigger: trigger,
                state: state,
                diffJson: diffJson,
                startedAt: startedAt,
                finishedAt: finishedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SyncRunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pairId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pairId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pairId,
                                referencedTable: $$SyncRunsTableReferences
                                    ._pairIdTable(db),
                                referencedColumn: $$SyncRunsTableReferences
                                    ._pairIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SyncRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgetuneDatabase,
      $SyncRunsTable,
      SyncRun,
      $$SyncRunsTableFilterComposer,
      $$SyncRunsTableOrderingComposer,
      $$SyncRunsTableAnnotationComposer,
      $$SyncRunsTableCreateCompanionBuilder,
      $$SyncRunsTableUpdateCompanionBuilder,
      (SyncRun, $$SyncRunsTableReferences),
      SyncRun,
      PrefetchHooks Function({bool pairId})
    >;
typedef $$JobLogsTableCreateCompanionBuilder =
    JobLogsCompanion Function({
      Value<int> id,
      Value<String?> jobId,
      required String level,
      required String event,
      Value<String?> detailJson,
      required DateTime at,
    });
typedef $$JobLogsTableUpdateCompanionBuilder =
    JobLogsCompanion Function({
      Value<int> id,
      Value<String?> jobId,
      Value<String> level,
      Value<String> event,
      Value<String?> detailJson,
      Value<DateTime> at,
    });

class $$JobLogsTableFilterComposer
    extends Composer<_$BridgetuneDatabase, $JobLogsTable> {
  $$JobLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get event => $composableBuilder(
    column: $table.event,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailJson => $composableBuilder(
    column: $table.detailJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JobLogsTableOrderingComposer
    extends Composer<_$BridgetuneDatabase, $JobLogsTable> {
  $$JobLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get event => $composableBuilder(
    column: $table.event,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailJson => $composableBuilder(
    column: $table.detailJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JobLogsTableAnnotationComposer
    extends Composer<_$BridgetuneDatabase, $JobLogsTable> {
  $$JobLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get event =>
      $composableBuilder(column: $table.event, builder: (column) => column);

  GeneratedColumn<String> get detailJson => $composableBuilder(
    column: $table.detailJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$JobLogsTableTableManager
    extends
        RootTableManager<
          _$BridgetuneDatabase,
          $JobLogsTable,
          JobLog,
          $$JobLogsTableFilterComposer,
          $$JobLogsTableOrderingComposer,
          $$JobLogsTableAnnotationComposer,
          $$JobLogsTableCreateCompanionBuilder,
          $$JobLogsTableUpdateCompanionBuilder,
          (JobLog, BaseReferences<_$BridgetuneDatabase, $JobLogsTable, JobLog>),
          JobLog,
          PrefetchHooks Function()
        > {
  $$JobLogsTableTableManager(_$BridgetuneDatabase db, $JobLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> jobId = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> event = const Value.absent(),
                Value<String?> detailJson = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => JobLogsCompanion(
                id: id,
                jobId: jobId,
                level: level,
                event: event,
                detailJson: detailJson,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> jobId = const Value.absent(),
                required String level,
                required String event,
                Value<String?> detailJson = const Value.absent(),
                required DateTime at,
              }) => JobLogsCompanion.insert(
                id: id,
                jobId: jobId,
                level: level,
                event: event,
                detailJson: detailJson,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JobLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgetuneDatabase,
      $JobLogsTable,
      JobLog,
      $$JobLogsTableFilterComposer,
      $$JobLogsTableOrderingComposer,
      $$JobLogsTableAnnotationComposer,
      $$JobLogsTableCreateCompanionBuilder,
      $$JobLogsTableUpdateCompanionBuilder,
      (JobLog, BaseReferences<_$BridgetuneDatabase, $JobLogsTable, JobLog>),
      JobLog,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String valueJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> valueJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$BridgetuneDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$BridgetuneDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$BridgetuneDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$BridgetuneDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$BridgetuneDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(
    _$BridgetuneDatabase db,
    $AppSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                valueJson: valueJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String valueJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                valueJson: valueJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$BridgetuneDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$BridgetuneDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $BridgetuneDatabaseManager {
  final _$BridgetuneDatabase _db;
  $BridgetuneDatabaseManager(this._db);
  $$ProviderAccountsTableTableManager get providerAccounts =>
      $$ProviderAccountsTableTableManager(_db, _db.providerAccounts);
  $$TrackSnapshotsTableTableManager get trackSnapshots =>
      $$TrackSnapshotsTableTableManager(_db, _db.trackSnapshots);
  $$TrackMappingsTableTableManager get trackMappings =>
      $$TrackMappingsTableTableManager(_db, _db.trackMappings);
  $$PlaylistSnapshotsTableTableManager get playlistSnapshots =>
      $$PlaylistSnapshotsTableTableManager(_db, _db.playlistSnapshots);
  $$PlaylistTrackSnapshotsTableTableManager get playlistTrackSnapshots =>
      $$PlaylistTrackSnapshotsTableTableManager(
        _db,
        _db.playlistTrackSnapshots,
      );
  $$TransferJobsTableTableManager get transferJobs =>
      $$TransferJobsTableTableManager(_db, _db.transferJobs);
  $$JobItemsTableTableManager get jobItems =>
      $$JobItemsTableTableManager(_db, _db.jobItems);
  $$SyncPairsTableTableManager get syncPairs =>
      $$SyncPairsTableTableManager(_db, _db.syncPairs);
  $$SyncRunsTableTableManager get syncRuns =>
      $$SyncRunsTableTableManager(_db, _db.syncRuns);
  $$JobLogsTableTableManager get jobLogs =>
      $$JobLogsTableTableManager(_db, _db.jobLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
