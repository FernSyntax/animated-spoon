// This is a generated file - do not edit.
//
// Generated from kd.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'kd.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'kd.pbenum.dart';

/// ----------------------------- common -----------------------------
class Empty extends $pb.GeneratedMessage {
  factory Empty() => Empty._();

  Empty._();

  factory Empty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Empty()..mergeFromBuffer(data, registry);
  factory Empty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Empty()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Empty',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: Empty.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty)) as Empty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Empty() / Empty.new instead')
  static Empty create() => Empty._();
  static $pb.GeneratedMessage $_createMessage() => Empty._();
  @$core.override
  Empty createEmptyInstance() => Empty._();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Empty>(Empty.$_createMessage);
  static Empty? _defaultInstance;
}

class Vec2 extends $pb.GeneratedMessage {
  factory Vec2({
    $core.int? x,
    $core.int? y,
  }) {
    final result = Vec2._();
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    return result;
  }

  Vec2._();

  factory Vec2.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Vec2()..mergeFromBuffer(data, registry);
  factory Vec2.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Vec2()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Vec2',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: Vec2.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'x')
    ..aI(2, _omitFieldNames ? '' : 'y')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Vec2 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Vec2 copyWith(void Function(Vec2) updates) =>
      super.copyWith((message) => updates(message as Vec2)) as Vec2;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Vec2() / Vec2.new instead')
  static Vec2 create() => Vec2._();
  static $pb.GeneratedMessage $_createMessage() => Vec2._();
  @$core.override
  Vec2 createEmptyInstance() => Vec2._();
  @$core.pragma('dart2js:noInline')
  static Vec2 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Vec2>(Vec2.$_createMessage);
  static Vec2? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get x => $_getIZ(0);
  @$pb.TagNumber(1)
  set x($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get y => $_getIZ(1);
  @$pb.TagNumber(2)
  set y($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => $_clearField(2);
}

class Resources extends $pb.GeneratedMessage {
  factory Resources({
    $fixnum.Int64? food,
    $fixnum.Int64? wood,
    $fixnum.Int64? stone,
    $fixnum.Int64? iron,
    $fixnum.Int64? gold,
  }) {
    final result = Resources._();
    if (food != null) result.food = food;
    if (wood != null) result.wood = wood;
    if (stone != null) result.stone = stone;
    if (iron != null) result.iron = iron;
    if (gold != null) result.gold = gold;
    return result;
  }

  Resources._();

  factory Resources.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Resources()..mergeFromBuffer(data, registry);
  factory Resources.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Resources()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Resources',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: Resources.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'food')
    ..aInt64(2, _omitFieldNames ? '' : 'wood')
    ..aInt64(3, _omitFieldNames ? '' : 'stone')
    ..aInt64(4, _omitFieldNames ? '' : 'iron')
    ..aInt64(5, _omitFieldNames ? '' : 'gold')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Resources clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Resources copyWith(void Function(Resources) updates) =>
      super.copyWith((message) => updates(message as Resources)) as Resources;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Resources() / Resources.new instead')
  static Resources create() => Resources._();
  static $pb.GeneratedMessage $_createMessage() => Resources._();
  @$core.override
  Resources createEmptyInstance() => Resources._();
  @$core.pragma('dart2js:noInline')
  static Resources getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Resources>(Resources.$_createMessage);
  static Resources? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get food => $_getI64(0);
  @$pb.TagNumber(1)
  set food($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFood() => $_has(0);
  @$pb.TagNumber(1)
  void clearFood() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get wood => $_getI64(1);
  @$pb.TagNumber(2)
  set wood($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWood() => $_has(1);
  @$pb.TagNumber(2)
  void clearWood() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get stone => $_getI64(2);
  @$pb.TagNumber(3)
  set stone($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStone() => $_has(2);
  @$pb.TagNumber(3)
  void clearStone() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get iron => $_getI64(3);
  @$pb.TagNumber(4)
  set iron($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIron() => $_has(3);
  @$pb.TagNumber(4)
  void clearIron() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get gold => $_getI64(4);
  @$pb.TagNumber(5)
  set gold($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGold() => $_has(4);
  @$pb.TagNumber(5)
  void clearGold() => $_clearField(5);
}

/// ------------------------- control plane --------------------------
class RegisterRequest extends $pb.GeneratedMessage {
  factory RegisterRequest({
    $core.String? username,
    $core.String? password,
    $core.String? displayName,
  }) {
    final result = RegisterRequest._();
    if (username != null) result.username = username;
    if (password != null) result.password = password;
    if (displayName != null) result.displayName = displayName;
    return result;
  }

  RegisterRequest._();

  factory RegisterRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterRequest()..mergeFromBuffer(data, registry);
  factory RegisterRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: RegisterRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..aOS(3, _omitFieldNames ? '' : 'displayName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterRequest copyWith(void Function(RegisterRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterRequest))
          as RegisterRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RegisterRequest() / RegisterRequest.new instead')
  static RegisterRequest create() => RegisterRequest._();
  static $pb.GeneratedMessage $_createMessage() => RegisterRequest._();
  @$core.override
  RegisterRequest createEmptyInstance() => RegisterRequest._();
  @$core.pragma('dart2js:noInline')
  static RegisterRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RegisterRequest>(
          RegisterRequest.$_createMessage);
  static RegisterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get displayName => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDisplayName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayName() => $_clearField(3);
}

class RegisterResponse extends $pb.GeneratedMessage {
  factory RegisterResponse({
    $core.String? accountId,
  }) {
    final result = RegisterResponse._();
    if (accountId != null) result.accountId = accountId;
    return result;
  }

  RegisterResponse._();

  factory RegisterResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterResponse()..mergeFromBuffer(data, registry);
  factory RegisterResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: RegisterResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'accountId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterResponse copyWith(void Function(RegisterResponse) updates) =>
      super.copyWith((message) => updates(message as RegisterResponse))
          as RegisterResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RegisterResponse() / RegisterResponse.new instead')
  static RegisterResponse create() => RegisterResponse._();
  static $pb.GeneratedMessage $_createMessage() => RegisterResponse._();
  @$core.override
  RegisterResponse createEmptyInstance() => RegisterResponse._();
  @$core.pragma('dart2js:noInline')
  static RegisterResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RegisterResponse>(
          RegisterResponse.$_createMessage);
  static RegisterResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set accountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountId() => $_clearField(1);
}

class LoginRequest extends $pb.GeneratedMessage {
  factory LoginRequest({
    $core.String? username,
    $core.String? password,
  }) {
    final result = LoginRequest._();
    if (username != null) result.username = username;
    if (password != null) result.password = password;
    return result;
  }

  LoginRequest._();

  factory LoginRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoginRequest()..mergeFromBuffer(data, registry);
  factory LoginRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoginRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoginRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: LoginRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginRequest copyWith(void Function(LoginRequest) updates) =>
      super.copyWith((message) => updates(message as LoginRequest))
          as LoginRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoginRequest() / LoginRequest.new instead')
  static LoginRequest create() => LoginRequest._();
  static $pb.GeneratedMessage $_createMessage() => LoginRequest._();
  @$core.override
  LoginRequest createEmptyInstance() => LoginRequest._();
  @$core.pragma('dart2js:noInline')
  static LoginRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginRequest>(
          LoginRequest.$_createMessage);
  static LoginRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);
}

class LoginResponse extends $pb.GeneratedMessage {
  factory LoginResponse({
    $core.String? token,
    $fixnum.Int64? expiresAtUnix,
    $core.String? accountId,
  }) {
    final result = LoginResponse._();
    if (token != null) result.token = token;
    if (expiresAtUnix != null) result.expiresAtUnix = expiresAtUnix;
    if (accountId != null) result.accountId = accountId;
    return result;
  }

  LoginResponse._();

  factory LoginResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoginResponse()..mergeFromBuffer(data, registry);
  factory LoginResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LoginResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoginResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: LoginResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..aInt64(2, _omitFieldNames ? '' : 'expiresAtUnix')
    ..aOS(3, _omitFieldNames ? '' : 'accountId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginResponse copyWith(void Function(LoginResponse) updates) =>
      super.copyWith((message) => updates(message as LoginResponse))
          as LoginResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LoginResponse() / LoginResponse.new instead')
  static LoginResponse create() => LoginResponse._();
  static $pb.GeneratedMessage $_createMessage() => LoginResponse._();
  @$core.override
  LoginResponse createEmptyInstance() => LoginResponse._();
  @$core.pragma('dart2js:noInline')
  static LoginResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginResponse>(
          LoginResponse.$_createMessage);
  static LoginResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expiresAtUnix => $_getI64(1);
  @$pb.TagNumber(2)
  set expiresAtUnix($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpiresAtUnix() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiresAtUnix() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get accountId => $_getSZ(2);
  @$pb.TagNumber(3)
  set accountId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccountId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccountId() => $_clearField(3);
}

class LogoutRequest extends $pb.GeneratedMessage {
  factory LogoutRequest({
    $core.String? token,
  }) {
    final result = LogoutRequest._();
    if (token != null) result.token = token;
    return result;
  }

  LogoutRequest._();

  factory LogoutRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LogoutRequest()..mergeFromBuffer(data, registry);
  factory LogoutRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LogoutRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogoutRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: LogoutRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutRequest copyWith(void Function(LogoutRequest) updates) =>
      super.copyWith((message) => updates(message as LogoutRequest))
          as LogoutRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LogoutRequest() / LogoutRequest.new instead')
  static LogoutRequest create() => LogoutRequest._();
  static $pb.GeneratedMessage $_createMessage() => LogoutRequest._();
  @$core.override
  LogoutRequest createEmptyInstance() => LogoutRequest._();
  @$core.pragma('dart2js:noInline')
  static LogoutRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogoutRequest>(
          LogoutRequest.$_createMessage);
  static LogoutRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);
}

class RealmInfo extends $pb.GeneratedMessage {
  factory RealmInfo({
    $core.String? realmId,
    $core.String? name,
    $core.String? status,
    $core.int? players,
    $core.String? shard,
  }) {
    final result = RealmInfo._();
    if (realmId != null) result.realmId = realmId;
    if (name != null) result.name = name;
    if (status != null) result.status = status;
    if (players != null) result.players = players;
    if (shard != null) result.shard = shard;
    return result;
  }

  RealmInfo._();

  factory RealmInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RealmInfo()..mergeFromBuffer(data, registry);
  factory RealmInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RealmInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RealmInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: RealmInfo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'realmId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..aI(4, _omitFieldNames ? '' : 'players', fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'shard')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RealmInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RealmInfo copyWith(void Function(RealmInfo) updates) =>
      super.copyWith((message) => updates(message as RealmInfo)) as RealmInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RealmInfo() / RealmInfo.new instead')
  static RealmInfo create() => RealmInfo._();
  static $pb.GeneratedMessage $_createMessage() => RealmInfo._();
  @$core.override
  RealmInfo createEmptyInstance() => RealmInfo._();
  @$core.pragma('dart2js:noInline')
  static RealmInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RealmInfo>(RealmInfo.$_createMessage);
  static RealmInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get realmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set realmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRealmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRealmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get players => $_getIZ(3);
  @$pb.TagNumber(4)
  set players($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPlayers() => $_has(3);
  @$pb.TagNumber(4)
  void clearPlayers() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get shard => $_getSZ(4);
  @$pb.TagNumber(5)
  set shard($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasShard() => $_has(4);
  @$pb.TagNumber(5)
  void clearShard() => $_clearField(5);
}

class ListRealmsResponse extends $pb.GeneratedMessage {
  factory ListRealmsResponse({
    $core.Iterable<RealmInfo>? realms,
  }) {
    final result = ListRealmsResponse._();
    if (realms != null) result.realms.addAll(realms);
    return result;
  }

  ListRealmsResponse._();

  factory ListRealmsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListRealmsResponse()..mergeFromBuffer(data, registry);
  factory ListRealmsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListRealmsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListRealmsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: ListRealmsResponse.$_createMessage)
    ..pPM<RealmInfo>(1, _omitFieldNames ? '' : 'realms',
        subBuilder: RealmInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRealmsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRealmsResponse copyWith(void Function(ListRealmsResponse) updates) =>
      super.copyWith((message) => updates(message as ListRealmsResponse))
          as ListRealmsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListRealmsResponse() / ListRealmsResponse.new instead')
  static ListRealmsResponse create() => ListRealmsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListRealmsResponse._();
  @$core.override
  ListRealmsResponse createEmptyInstance() => ListRealmsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListRealmsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRealmsResponse>(
          ListRealmsResponse.$_createMessage);
  static ListRealmsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RealmInfo> get realms => $_getList(0);
}

class JoinRealmRequest extends $pb.GeneratedMessage {
  factory JoinRealmRequest({
    $core.String? realmId,
  }) {
    final result = JoinRealmRequest._();
    if (realmId != null) result.realmId = realmId;
    return result;
  }

  JoinRealmRequest._();

  factory JoinRealmRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      JoinRealmRequest()..mergeFromBuffer(data, registry);
  factory JoinRealmRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      JoinRealmRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRealmRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: JoinRealmRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'realmId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRealmRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRealmRequest copyWith(void Function(JoinRealmRequest) updates) =>
      super.copyWith((message) => updates(message as JoinRealmRequest))
          as JoinRealmRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use JoinRealmRequest() / JoinRealmRequest.new instead')
  static JoinRealmRequest create() => JoinRealmRequest._();
  static $pb.GeneratedMessage $_createMessage() => JoinRealmRequest._();
  @$core.override
  JoinRealmRequest createEmptyInstance() => JoinRealmRequest._();
  @$core.pragma('dart2js:noInline')
  static JoinRealmRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinRealmRequest>(
          JoinRealmRequest.$_createMessage);
  static JoinRealmRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get realmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set realmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRealmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRealmId() => $_clearField(1);
}

class JoinRealmResponse extends $pb.GeneratedMessage {
  factory JoinRealmResponse({
    $core.String? playerId,
    $core.bool? createdCity,
  }) {
    final result = JoinRealmResponse._();
    if (playerId != null) result.playerId = playerId;
    if (createdCity != null) result.createdCity = createdCity;
    return result;
  }

  JoinRealmResponse._();

  factory JoinRealmResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      JoinRealmResponse()..mergeFromBuffer(data, registry);
  factory JoinRealmResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      JoinRealmResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinRealmResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: JoinRealmResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'playerId')
    ..aOB(2, _omitFieldNames ? '' : 'createdCity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRealmResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinRealmResponse copyWith(void Function(JoinRealmResponse) updates) =>
      super.copyWith((message) => updates(message as JoinRealmResponse))
          as JoinRealmResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use JoinRealmResponse() / JoinRealmResponse.new instead')
  static JoinRealmResponse create() => JoinRealmResponse._();
  static $pb.GeneratedMessage $_createMessage() => JoinRealmResponse._();
  @$core.override
  JoinRealmResponse createEmptyInstance() => JoinRealmResponse._();
  @$core.pragma('dart2js:noInline')
  static JoinRealmResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinRealmResponse>(
          JoinRealmResponse.$_createMessage);
  static JoinRealmResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get playerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set playerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlayerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlayerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get createdCity => $_getBF(1);
  @$pb.TagNumber(2)
  set createdCity($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCreatedCity() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreatedCity() => $_clearField(2);
}

class CreateRealmRequest extends $pb.GeneratedMessage {
  factory CreateRealmRequest({
    $core.String? name,
    $core.String? shard,
  }) {
    final result = CreateRealmRequest._();
    if (name != null) result.name = name;
    if (shard != null) result.shard = shard;
    return result;
  }

  CreateRealmRequest._();

  factory CreateRealmRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateRealmRequest()..mergeFromBuffer(data, registry);
  factory CreateRealmRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateRealmRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateRealmRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: CreateRealmRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'shard')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRealmRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRealmRequest copyWith(void Function(CreateRealmRequest) updates) =>
      super.copyWith((message) => updates(message as CreateRealmRequest))
          as CreateRealmRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateRealmRequest() / CreateRealmRequest.new instead')
  static CreateRealmRequest create() => CreateRealmRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateRealmRequest._();
  @$core.override
  CreateRealmRequest createEmptyInstance() => CreateRealmRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateRealmRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateRealmRequest>(
          CreateRealmRequest.$_createMessage);
  static CreateRealmRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shard => $_getSZ(1);
  @$pb.TagNumber(2)
  set shard($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShard() => $_has(1);
  @$pb.TagNumber(2)
  void clearShard() => $_clearField(2);
}

class CreateRealmResponse extends $pb.GeneratedMessage {
  factory CreateRealmResponse({
    $core.String? realmId,
  }) {
    final result = CreateRealmResponse._();
    if (realmId != null) result.realmId = realmId;
    return result;
  }

  CreateRealmResponse._();

  factory CreateRealmResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateRealmResponse()..mergeFromBuffer(data, registry);
  factory CreateRealmResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateRealmResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateRealmResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: CreateRealmResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'realmId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRealmResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRealmResponse copyWith(void Function(CreateRealmResponse) updates) =>
      super.copyWith((message) => updates(message as CreateRealmResponse))
          as CreateRealmResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use CreateRealmResponse() / CreateRealmResponse.new instead')
  static CreateRealmResponse create() => CreateRealmResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateRealmResponse._();
  @$core.override
  CreateRealmResponse createEmptyInstance() => CreateRealmResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateRealmResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateRealmResponse>(
          CreateRealmResponse.$_createMessage);
  static CreateRealmResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get realmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set realmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRealmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRealmId() => $_clearField(1);
}

class RealmMembership extends $pb.GeneratedMessage {
  factory RealmMembership({
    $core.String? realmId,
    $core.String? playerId,
  }) {
    final result = RealmMembership._();
    if (realmId != null) result.realmId = realmId;
    if (playerId != null) result.playerId = playerId;
    return result;
  }

  RealmMembership._();

  factory RealmMembership.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RealmMembership()..mergeFromBuffer(data, registry);
  factory RealmMembership.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RealmMembership()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RealmMembership',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: RealmMembership.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'realmId')
    ..aOS(2, _omitFieldNames ? '' : 'playerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RealmMembership clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RealmMembership copyWith(void Function(RealmMembership) updates) =>
      super.copyWith((message) => updates(message as RealmMembership))
          as RealmMembership;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RealmMembership() / RealmMembership.new instead')
  static RealmMembership create() => RealmMembership._();
  static $pb.GeneratedMessage $_createMessage() => RealmMembership._();
  @$core.override
  RealmMembership createEmptyInstance() => RealmMembership._();
  @$core.pragma('dart2js:noInline')
  static RealmMembership getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RealmMembership>(
          RealmMembership.$_createMessage);
  static RealmMembership? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get realmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set realmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRealmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRealmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get playerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set playerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPlayerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlayerId() => $_clearField(2);
}

class ValidateRequest extends $pb.GeneratedMessage {
  factory ValidateRequest({
    $core.String? token,
  }) {
    final result = ValidateRequest._();
    if (token != null) result.token = token;
    return result;
  }

  ValidateRequest._();

  factory ValidateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateRequest()..mergeFromBuffer(data, registry);
  factory ValidateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ValidateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: ValidateRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateRequest copyWith(void Function(ValidateRequest) updates) =>
      super.copyWith((message) => updates(message as ValidateRequest))
          as ValidateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateRequest() / ValidateRequest.new instead')
  static ValidateRequest create() => ValidateRequest._();
  static $pb.GeneratedMessage $_createMessage() => ValidateRequest._();
  @$core.override
  ValidateRequest createEmptyInstance() => ValidateRequest._();
  @$core.pragma('dart2js:noInline')
  static ValidateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateRequest>(
          ValidateRequest.$_createMessage);
  static ValidateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);
}

class ValidateResponse extends $pb.GeneratedMessage {
  factory ValidateResponse({
    $core.String? accountId,
    $core.String? username,
    $core.Iterable<RealmMembership>? memberships,
  }) {
    final result = ValidateResponse._();
    if (accountId != null) result.accountId = accountId;
    if (username != null) result.username = username;
    if (memberships != null) result.memberships.addAll(memberships);
    return result;
  }

  ValidateResponse._();

  factory ValidateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateResponse()..mergeFromBuffer(data, registry);
  factory ValidateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ValidateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: ValidateResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'accountId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..pPM<RealmMembership>(3, _omitFieldNames ? '' : 'memberships',
        subBuilder: RealmMembership.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateResponse copyWith(void Function(ValidateResponse) updates) =>
      super.copyWith((message) => updates(message as ValidateResponse))
          as ValidateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateResponse() / ValidateResponse.new instead')
  static ValidateResponse create() => ValidateResponse._();
  static $pb.GeneratedMessage $_createMessage() => ValidateResponse._();
  @$core.override
  ValidateResponse createEmptyInstance() => ValidateResponse._();
  @$core.pragma('dart2js:noInline')
  static ValidateResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateResponse>(
          ValidateResponse.$_createMessage);
  static ValidateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accountId => $_getSZ(0);
  @$pb.TagNumber(1)
  set accountId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccountId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<RealmMembership> get memberships => $_getList(2);
}

class GetRealmRouteRequest extends $pb.GeneratedMessage {
  factory GetRealmRouteRequest({
    $core.String? realmId,
  }) {
    final result = GetRealmRouteRequest._();
    if (realmId != null) result.realmId = realmId;
    return result;
  }

  GetRealmRouteRequest._();

  factory GetRealmRouteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRealmRouteRequest()..mergeFromBuffer(data, registry);
  factory GetRealmRouteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRealmRouteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRealmRouteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: GetRealmRouteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'realmId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRealmRouteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRealmRouteRequest copyWith(void Function(GetRealmRouteRequest) updates) =>
      super.copyWith((message) => updates(message as GetRealmRouteRequest))
          as GetRealmRouteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetRealmRouteRequest() / GetRealmRouteRequest.new instead')
  static GetRealmRouteRequest create() => GetRealmRouteRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetRealmRouteRequest._();
  @$core.override
  GetRealmRouteRequest createEmptyInstance() => GetRealmRouteRequest._();
  @$core.pragma('dart2js:noInline')
  static GetRealmRouteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRealmRouteRequest>(
          GetRealmRouteRequest.$_createMessage);
  static GetRealmRouteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get realmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set realmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRealmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRealmId() => $_clearField(1);
}

class GetRealmRouteResponse extends $pb.GeneratedMessage {
  factory GetRealmRouteResponse({
    $core.String? realmId,
    $core.String? shard,
    $core.String? workerAddress,
  }) {
    final result = GetRealmRouteResponse._();
    if (realmId != null) result.realmId = realmId;
    if (shard != null) result.shard = shard;
    if (workerAddress != null) result.workerAddress = workerAddress;
    return result;
  }

  GetRealmRouteResponse._();

  factory GetRealmRouteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRealmRouteResponse()..mergeFromBuffer(data, registry);
  factory GetRealmRouteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRealmRouteResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRealmRouteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: GetRealmRouteResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'realmId')
    ..aOS(2, _omitFieldNames ? '' : 'shard')
    ..aOS(3, _omitFieldNames ? '' : 'workerAddress')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRealmRouteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRealmRouteResponse copyWith(
          void Function(GetRealmRouteResponse) updates) =>
      super.copyWith((message) => updates(message as GetRealmRouteResponse))
          as GetRealmRouteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetRealmRouteResponse() / GetRealmRouteResponse.new instead')
  static GetRealmRouteResponse create() => GetRealmRouteResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetRealmRouteResponse._();
  @$core.override
  GetRealmRouteResponse createEmptyInstance() => GetRealmRouteResponse._();
  @$core.pragma('dart2js:noInline')
  static GetRealmRouteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRealmRouteResponse>(
          GetRealmRouteResponse.$_createMessage);
  static GetRealmRouteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get realmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set realmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRealmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRealmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get shard => $_getSZ(1);
  @$pb.TagNumber(2)
  set shard($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasShard() => $_has(1);
  @$pb.TagNumber(2)
  void clearShard() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get workerAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set workerAddress($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWorkerAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearWorkerAddress() => $_clearField(3);
}

/// ----------------------- realm internal RPC -----------------------
class SubmitCommandRequest extends $pb.GeneratedMessage {
  factory SubmitCommandRequest({
    $core.String? realmId,
    $core.String? principalPlayerId,
    $core.String? commandId,
    CommandPayload? payload,
  }) {
    final result = SubmitCommandRequest._();
    if (realmId != null) result.realmId = realmId;
    if (principalPlayerId != null) result.principalPlayerId = principalPlayerId;
    if (commandId != null) result.commandId = commandId;
    if (payload != null) result.payload = payload;
    return result;
  }

  SubmitCommandRequest._();

  factory SubmitCommandRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubmitCommandRequest()..mergeFromBuffer(data, registry);
  factory SubmitCommandRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubmitCommandRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitCommandRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: SubmitCommandRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'realmId')
    ..aOS(2, _omitFieldNames ? '' : 'principalPlayerId')
    ..aOS(3, _omitFieldNames ? '' : 'commandId')
    ..aOM<CommandPayload>(4, _omitFieldNames ? '' : 'payload',
        subBuilder: CommandPayload.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitCommandRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitCommandRequest copyWith(void Function(SubmitCommandRequest) updates) =>
      super.copyWith((message) => updates(message as SubmitCommandRequest))
          as SubmitCommandRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SubmitCommandRequest() / SubmitCommandRequest.new instead')
  static SubmitCommandRequest create() => SubmitCommandRequest._();
  static $pb.GeneratedMessage $_createMessage() => SubmitCommandRequest._();
  @$core.override
  SubmitCommandRequest createEmptyInstance() => SubmitCommandRequest._();
  @$core.pragma('dart2js:noInline')
  static SubmitCommandRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitCommandRequest>(
          SubmitCommandRequest.$_createMessage);
  static SubmitCommandRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get realmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set realmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRealmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRealmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get principalPlayerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set principalPlayerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrincipalPlayerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrincipalPlayerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get commandId => $_getSZ(2);
  @$pb.TagNumber(3)
  set commandId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCommandId() => $_has(2);
  @$pb.TagNumber(3)
  void clearCommandId() => $_clearField(3);

  @$pb.TagNumber(4)
  CommandPayload get payload => $_getN(3);
  @$pb.TagNumber(4)
  set payload(CommandPayload value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPayload() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayload() => $_clearField(4);
  @$pb.TagNumber(4)
  CommandPayload ensurePayload() => $_ensure(3);
}

class CommandResult extends $pb.GeneratedMessage {
  factory CommandResult({
    $core.String? commandId,
    ErrorCode? code,
    $core.String? message,
    $fixnum.Int64? stateVersion,
    $fixnum.Int64? serverTimeUnixMs,
    $core.List<$core.int>? stateJson,
  }) {
    final result = CommandResult._();
    if (commandId != null) result.commandId = commandId;
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (stateVersion != null) result.stateVersion = stateVersion;
    if (serverTimeUnixMs != null) result.serverTimeUnixMs = serverTimeUnixMs;
    if (stateJson != null) result.stateJson = stateJson;
    return result;
  }

  CommandResult._();

  factory CommandResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandResult()..mergeFromBuffer(data, registry);
  factory CommandResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: CommandResult.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'commandId')
    ..aE<ErrorCode>(2, _omitFieldNames ? '' : 'code',
        enumValues: ErrorCode.values)
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'stateVersion', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(5, _omitFieldNames ? '' : 'serverTimeUnixMs')
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'stateJson', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandResult copyWith(void Function(CommandResult) updates) =>
      super.copyWith((message) => updates(message as CommandResult))
          as CommandResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommandResult() / CommandResult.new instead')
  static CommandResult create() => CommandResult._();
  static $pb.GeneratedMessage $_createMessage() => CommandResult._();
  @$core.override
  CommandResult createEmptyInstance() => CommandResult._();
  @$core.pragma('dart2js:noInline')
  static CommandResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommandResult>(
          CommandResult.$_createMessage);
  static CommandResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get commandId => $_getSZ(0);
  @$pb.TagNumber(1)
  set commandId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommandId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommandId() => $_clearField(1);

  @$pb.TagNumber(2)
  ErrorCode get code => $_getN(1);
  @$pb.TagNumber(2)
  set code(ErrorCode value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get stateVersion => $_getI64(3);
  @$pb.TagNumber(4)
  set stateVersion($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStateVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearStateVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get serverTimeUnixMs => $_getI64(4);
  @$pb.TagNumber(5)
  set serverTimeUnixMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasServerTimeUnixMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearServerTimeUnixMs() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get stateJson => $_getN(5);
  @$pb.TagNumber(6)
  set stateJson($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStateJson() => $_has(5);
  @$pb.TagNumber(6)
  void clearStateJson() => $_clearField(6);
}

class SnapshotRequest extends $pb.GeneratedMessage {
  factory SnapshotRequest({
    $core.String? realmId,
    $core.String? principalPlayerId,
    $core.Iterable<Vec2>? chunks,
  }) {
    final result = SnapshotRequest._();
    if (realmId != null) result.realmId = realmId;
    if (principalPlayerId != null) result.principalPlayerId = principalPlayerId;
    if (chunks != null) result.chunks.addAll(chunks);
    return result;
  }

  SnapshotRequest._();

  factory SnapshotRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SnapshotRequest()..mergeFromBuffer(data, registry);
  factory SnapshotRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SnapshotRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SnapshotRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: SnapshotRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'realmId')
    ..aOS(2, _omitFieldNames ? '' : 'principalPlayerId')
    ..pPM<Vec2>(3, _omitFieldNames ? '' : 'chunks',
        subBuilder: Vec2.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SnapshotRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SnapshotRequest copyWith(void Function(SnapshotRequest) updates) =>
      super.copyWith((message) => updates(message as SnapshotRequest))
          as SnapshotRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SnapshotRequest() / SnapshotRequest.new instead')
  static SnapshotRequest create() => SnapshotRequest._();
  static $pb.GeneratedMessage $_createMessage() => SnapshotRequest._();
  @$core.override
  SnapshotRequest createEmptyInstance() => SnapshotRequest._();
  @$core.pragma('dart2js:noInline')
  static SnapshotRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SnapshotRequest>(
          SnapshotRequest.$_createMessage);
  static SnapshotRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get realmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set realmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRealmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRealmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get principalPlayerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set principalPlayerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrincipalPlayerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrincipalPlayerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<Vec2> get chunks => $_getList(2);
}

class SnapshotResponse extends $pb.GeneratedMessage {
  factory SnapshotResponse({
    $core.String? realmId,
    $fixnum.Int64? version,
    $core.List<$core.int>? stateJson,
    $core.List<$core.int>? mapJson,
    $fixnum.Int64? serverTimeUnixMs,
    $core.String? cursor,
  }) {
    final result = SnapshotResponse._();
    if (realmId != null) result.realmId = realmId;
    if (version != null) result.version = version;
    if (stateJson != null) result.stateJson = stateJson;
    if (mapJson != null) result.mapJson = mapJson;
    if (serverTimeUnixMs != null) result.serverTimeUnixMs = serverTimeUnixMs;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  SnapshotResponse._();

  factory SnapshotResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SnapshotResponse()..mergeFromBuffer(data, registry);
  factory SnapshotResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SnapshotResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SnapshotResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: SnapshotResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'realmId')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'stateJson', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'mapJson', $pb.PbFieldType.OY)
    ..aInt64(5, _omitFieldNames ? '' : 'serverTimeUnixMs')
    ..aOS(6, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SnapshotResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SnapshotResponse copyWith(void Function(SnapshotResponse) updates) =>
      super.copyWith((message) => updates(message as SnapshotResponse))
          as SnapshotResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SnapshotResponse() / SnapshotResponse.new instead')
  static SnapshotResponse create() => SnapshotResponse._();
  static $pb.GeneratedMessage $_createMessage() => SnapshotResponse._();
  @$core.override
  SnapshotResponse createEmptyInstance() => SnapshotResponse._();
  @$core.pragma('dart2js:noInline')
  static SnapshotResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SnapshotResponse>(
          SnapshotResponse.$_createMessage);
  static SnapshotResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get realmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set realmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRealmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRealmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get version => $_getI64(1);
  @$pb.TagNumber(2)
  set version($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get stateJson => $_getN(2);
  @$pb.TagNumber(3)
  set stateJson($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStateJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearStateJson() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get mapJson => $_getN(3);
  @$pb.TagNumber(4)
  set mapJson($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMapJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearMapJson() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get serverTimeUnixMs => $_getI64(4);
  @$pb.TagNumber(5)
  set serverTimeUnixMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasServerTimeUnixMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearServerTimeUnixMs() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get cursor => $_getSZ(5);
  @$pb.TagNumber(6)
  set cursor($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearCursor() => $_clearField(6);
}

class WorkerHealth extends $pb.GeneratedMessage {
  factory WorkerHealth({
    $core.String? workerId,
    $core.Iterable<$core.String>? realms,
    $core.bool? ready,
  }) {
    final result = WorkerHealth._();
    if (workerId != null) result.workerId = workerId;
    if (realms != null) result.realms.addAll(realms);
    if (ready != null) result.ready = ready;
    return result;
  }

  WorkerHealth._();

  factory WorkerHealth.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkerHealth()..mergeFromBuffer(data, registry);
  factory WorkerHealth.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkerHealth()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkerHealth',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: WorkerHealth.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workerId')
    ..pPS(2, _omitFieldNames ? '' : 'realms')
    ..aOB(3, _omitFieldNames ? '' : 'ready')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkerHealth clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkerHealth copyWith(void Function(WorkerHealth) updates) =>
      super.copyWith((message) => updates(message as WorkerHealth))
          as WorkerHealth;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WorkerHealth() / WorkerHealth.new instead')
  static WorkerHealth create() => WorkerHealth._();
  static $pb.GeneratedMessage $_createMessage() => WorkerHealth._();
  @$core.override
  WorkerHealth createEmptyInstance() => WorkerHealth._();
  @$core.pragma('dart2js:noInline')
  static WorkerHealth getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkerHealth>(
          WorkerHealth.$_createMessage);
  static WorkerHealth? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get realms => $_getList(1);

  @$pb.TagNumber(3)
  $core.bool get ready => $_getBF(2);
  @$pb.TagNumber(3)
  set ready($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReady() => $_has(2);
  @$pb.TagNumber(3)
  void clearReady() => $_clearField(3);
}

class EnsurePlayerRequest extends $pb.GeneratedMessage {
  factory EnsurePlayerRequest({
    $core.String? realmId,
    $core.String? accountId,
    $core.String? playerId,
    $core.String? name,
  }) {
    final result = EnsurePlayerRequest._();
    if (realmId != null) result.realmId = realmId;
    if (accountId != null) result.accountId = accountId;
    if (playerId != null) result.playerId = playerId;
    if (name != null) result.name = name;
    return result;
  }

  EnsurePlayerRequest._();

  factory EnsurePlayerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EnsurePlayerRequest()..mergeFromBuffer(data, registry);
  factory EnsurePlayerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EnsurePlayerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EnsurePlayerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: EnsurePlayerRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'realmId')
    ..aOS(2, _omitFieldNames ? '' : 'accountId')
    ..aOS(3, _omitFieldNames ? '' : 'playerId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnsurePlayerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnsurePlayerRequest copyWith(void Function(EnsurePlayerRequest) updates) =>
      super.copyWith((message) => updates(message as EnsurePlayerRequest))
          as EnsurePlayerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use EnsurePlayerRequest() / EnsurePlayerRequest.new instead')
  static EnsurePlayerRequest create() => EnsurePlayerRequest._();
  static $pb.GeneratedMessage $_createMessage() => EnsurePlayerRequest._();
  @$core.override
  EnsurePlayerRequest createEmptyInstance() => EnsurePlayerRequest._();
  @$core.pragma('dart2js:noInline')
  static EnsurePlayerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EnsurePlayerRequest>(
          EnsurePlayerRequest.$_createMessage);
  static EnsurePlayerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get realmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set realmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRealmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRealmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get accountId => $_getSZ(1);
  @$pb.TagNumber(2)
  set accountId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccountId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccountId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get playerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set playerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPlayerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlayerId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);
}

class EnsurePlayerResponse extends $pb.GeneratedMessage {
  factory EnsurePlayerResponse({
    $core.String? playerId,
    $core.bool? created,
  }) {
    final result = EnsurePlayerResponse._();
    if (playerId != null) result.playerId = playerId;
    if (created != null) result.created = created;
    return result;
  }

  EnsurePlayerResponse._();

  factory EnsurePlayerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EnsurePlayerResponse()..mergeFromBuffer(data, registry);
  factory EnsurePlayerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EnsurePlayerResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EnsurePlayerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: EnsurePlayerResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'playerId')
    ..aOB(2, _omitFieldNames ? '' : 'created')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnsurePlayerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnsurePlayerResponse copyWith(void Function(EnsurePlayerResponse) updates) =>
      super.copyWith((message) => updates(message as EnsurePlayerResponse))
          as EnsurePlayerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use EnsurePlayerResponse() / EnsurePlayerResponse.new instead')
  static EnsurePlayerResponse create() => EnsurePlayerResponse._();
  static $pb.GeneratedMessage $_createMessage() => EnsurePlayerResponse._();
  @$core.override
  EnsurePlayerResponse createEmptyInstance() => EnsurePlayerResponse._();
  @$core.pragma('dart2js:noInline')
  static EnsurePlayerResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EnsurePlayerResponse>(
          EnsurePlayerResponse.$_createMessage);
  static EnsurePlayerResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get playerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set playerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlayerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlayerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get created => $_getBF(1);
  @$pb.TagNumber(2)
  set created($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCreated() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreated() => $_clearField(2);
}

class AdvanceClockRequest extends $pb.GeneratedMessage {
  factory AdvanceClockRequest({
    $core.String? realmId,
    $fixnum.Int64? deltaMicros,
  }) {
    final result = AdvanceClockRequest._();
    if (realmId != null) result.realmId = realmId;
    if (deltaMicros != null) result.deltaMicros = deltaMicros;
    return result;
  }

  AdvanceClockRequest._();

  factory AdvanceClockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AdvanceClockRequest()..mergeFromBuffer(data, registry);
  factory AdvanceClockRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AdvanceClockRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AdvanceClockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: AdvanceClockRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'realmId')
    ..aInt64(2, _omitFieldNames ? '' : 'deltaMicros')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceClockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceClockRequest copyWith(void Function(AdvanceClockRequest) updates) =>
      super.copyWith((message) => updates(message as AdvanceClockRequest))
          as AdvanceClockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use AdvanceClockRequest() / AdvanceClockRequest.new instead')
  static AdvanceClockRequest create() => AdvanceClockRequest._();
  static $pb.GeneratedMessage $_createMessage() => AdvanceClockRequest._();
  @$core.override
  AdvanceClockRequest createEmptyInstance() => AdvanceClockRequest._();
  @$core.pragma('dart2js:noInline')
  static AdvanceClockRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AdvanceClockRequest>(
          AdvanceClockRequest.$_createMessage);
  static AdvanceClockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get realmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set realmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRealmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRealmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get deltaMicros => $_getI64(1);
  @$pb.TagNumber(2)
  set deltaMicros($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeltaMicros() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeltaMicros() => $_clearField(2);
}

class AdvanceClockResponse extends $pb.GeneratedMessage {
  factory AdvanceClockResponse({
    $fixnum.Int64? clockNowMs,
  }) {
    final result = AdvanceClockResponse._();
    if (clockNowMs != null) result.clockNowMs = clockNowMs;
    return result;
  }

  AdvanceClockResponse._();

  factory AdvanceClockResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AdvanceClockResponse()..mergeFromBuffer(data, registry);
  factory AdvanceClockResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AdvanceClockResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AdvanceClockResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: AdvanceClockResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'clockNowMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceClockResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceClockResponse copyWith(void Function(AdvanceClockResponse) updates) =>
      super.copyWith((message) => updates(message as AdvanceClockResponse))
          as AdvanceClockResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AdvanceClockResponse() / AdvanceClockResponse.new instead')
  static AdvanceClockResponse create() => AdvanceClockResponse._();
  static $pb.GeneratedMessage $_createMessage() => AdvanceClockResponse._();
  @$core.override
  AdvanceClockResponse createEmptyInstance() => AdvanceClockResponse._();
  @$core.pragma('dart2js:noInline')
  static AdvanceClockResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AdvanceClockResponse>(
          AdvanceClockResponse.$_createMessage);
  static AdvanceClockResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get clockNowMs => $_getI64(0);
  @$pb.TagNumber(1)
  set clockNowMs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClockNowMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearClockNowMs() => $_clearField(1);
}

enum CommandPayload_Action {
  createCity,
  upgradeBuilding,
  startResearch,
  trainTroops,
  healTroops,
  useItem,
  scoutTile,
  attackMonster,
  gather,
  attackCity,
  attackFort,
  reinforce,
  transport,
  recall,
  setShield,
  createAlliance,
  allianceInvite,
  allianceAccept,
  allianceJoin,
  allianceLeave,
  allianceKick,
  allianceHelp,
  rallyCreate,
  rallyJoin,
  rallyCancel,
  chat,
  switchCapital,
  recruitHero,
  demolishBuilding,
  marketBuy,
  marketSell,
  notSet
}

/// --------------------------- commands -----------------------------
class CommandPayload extends $pb.GeneratedMessage {
  factory CommandPayload({
    CreateCityCmd? createCity,
    UpgradeBuildingCmd? upgradeBuilding,
    StartResearchCmd? startResearch,
    TrainTroopsCmd? trainTroops,
    HealTroopsCmd? healTroops,
    UseItemCmd? useItem,
    ScoutTileCmd? scoutTile,
    AttackMonsterCmd? attackMonster,
    GatherCmd? gather,
    AttackCityCmd? attackCity,
    AttackFortCmd? attackFort,
    ReinforceCmd? reinforce,
    TransportCmd? transport,
    RecallCmd? recall,
    SetShieldCmd? setShield,
    CreateAllianceCmd? createAlliance,
    AllianceInviteCmd? allianceInvite,
    AllianceAcceptCmd? allianceAccept,
    AllianceJoinCmd? allianceJoin,
    AllianceLeaveCmd? allianceLeave,
    AllianceKickCmd? allianceKick,
    AllianceHelpCmd? allianceHelp,
    RallyCreateCmd? rallyCreate,
    RallyJoinCmd? rallyJoin,
    RallyCancelCmd? rallyCancel,
    ChatCmd? chat,
    SwitchCapitalCmd? switchCapital,
    RecruitHeroCmd? recruitHero,
    DemolishBuildingCmd? demolishBuilding,
    MarketBuyCmd? marketBuy,
    MarketSellCmd? marketSell,
  }) {
    final result = CommandPayload._();
    if (createCity != null) result.createCity = createCity;
    if (upgradeBuilding != null) result.upgradeBuilding = upgradeBuilding;
    if (startResearch != null) result.startResearch = startResearch;
    if (trainTroops != null) result.trainTroops = trainTroops;
    if (healTroops != null) result.healTroops = healTroops;
    if (useItem != null) result.useItem = useItem;
    if (scoutTile != null) result.scoutTile = scoutTile;
    if (attackMonster != null) result.attackMonster = attackMonster;
    if (gather != null) result.gather = gather;
    if (attackCity != null) result.attackCity = attackCity;
    if (attackFort != null) result.attackFort = attackFort;
    if (reinforce != null) result.reinforce = reinforce;
    if (transport != null) result.transport = transport;
    if (recall != null) result.recall = recall;
    if (setShield != null) result.setShield = setShield;
    if (createAlliance != null) result.createAlliance = createAlliance;
    if (allianceInvite != null) result.allianceInvite = allianceInvite;
    if (allianceAccept != null) result.allianceAccept = allianceAccept;
    if (allianceJoin != null) result.allianceJoin = allianceJoin;
    if (allianceLeave != null) result.allianceLeave = allianceLeave;
    if (allianceKick != null) result.allianceKick = allianceKick;
    if (allianceHelp != null) result.allianceHelp = allianceHelp;
    if (rallyCreate != null) result.rallyCreate = rallyCreate;
    if (rallyJoin != null) result.rallyJoin = rallyJoin;
    if (rallyCancel != null) result.rallyCancel = rallyCancel;
    if (chat != null) result.chat = chat;
    if (switchCapital != null) result.switchCapital = switchCapital;
    if (recruitHero != null) result.recruitHero = recruitHero;
    if (demolishBuilding != null) result.demolishBuilding = demolishBuilding;
    if (marketBuy != null) result.marketBuy = marketBuy;
    if (marketSell != null) result.marketSell = marketSell;
    return result;
  }

  CommandPayload._();

  factory CommandPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandPayload()..mergeFromBuffer(data, registry);
  factory CommandPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandPayload()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, CommandPayload_Action>
      _CommandPayload_ActionByTag = {
    1: CommandPayload_Action.createCity,
    2: CommandPayload_Action.upgradeBuilding,
    3: CommandPayload_Action.startResearch,
    4: CommandPayload_Action.trainTroops,
    5: CommandPayload_Action.healTroops,
    6: CommandPayload_Action.useItem,
    7: CommandPayload_Action.scoutTile,
    8: CommandPayload_Action.attackMonster,
    9: CommandPayload_Action.gather,
    10: CommandPayload_Action.attackCity,
    11: CommandPayload_Action.attackFort,
    12: CommandPayload_Action.reinforce,
    13: CommandPayload_Action.transport,
    14: CommandPayload_Action.recall,
    15: CommandPayload_Action.setShield,
    16: CommandPayload_Action.createAlliance,
    17: CommandPayload_Action.allianceInvite,
    18: CommandPayload_Action.allianceAccept,
    19: CommandPayload_Action.allianceJoin,
    20: CommandPayload_Action.allianceLeave,
    21: CommandPayload_Action.allianceKick,
    22: CommandPayload_Action.allianceHelp,
    23: CommandPayload_Action.rallyCreate,
    24: CommandPayload_Action.rallyJoin,
    25: CommandPayload_Action.rallyCancel,
    26: CommandPayload_Action.chat,
    27: CommandPayload_Action.switchCapital,
    28: CommandPayload_Action.recruitHero,
    29: CommandPayload_Action.demolishBuilding,
    30: CommandPayload_Action.marketBuy,
    31: CommandPayload_Action.marketSell,
    0: CommandPayload_Action.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: CommandPayload.$_createMessage)
    ..oo(0, [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      30,
      31
    ])
    ..aOM<CreateCityCmd>(1, _omitFieldNames ? '' : 'createCity',
        subBuilder: CreateCityCmd.$_createMessage)
    ..aOM<UpgradeBuildingCmd>(2, _omitFieldNames ? '' : 'upgradeBuilding',
        subBuilder: UpgradeBuildingCmd.$_createMessage)
    ..aOM<StartResearchCmd>(3, _omitFieldNames ? '' : 'startResearch',
        subBuilder: StartResearchCmd.$_createMessage)
    ..aOM<TrainTroopsCmd>(4, _omitFieldNames ? '' : 'trainTroops',
        subBuilder: TrainTroopsCmd.$_createMessage)
    ..aOM<HealTroopsCmd>(5, _omitFieldNames ? '' : 'healTroops',
        subBuilder: HealTroopsCmd.$_createMessage)
    ..aOM<UseItemCmd>(6, _omitFieldNames ? '' : 'useItem',
        subBuilder: UseItemCmd.$_createMessage)
    ..aOM<ScoutTileCmd>(7, _omitFieldNames ? '' : 'scoutTile',
        subBuilder: ScoutTileCmd.$_createMessage)
    ..aOM<AttackMonsterCmd>(8, _omitFieldNames ? '' : 'attackMonster',
        subBuilder: AttackMonsterCmd.$_createMessage)
    ..aOM<GatherCmd>(9, _omitFieldNames ? '' : 'gather',
        subBuilder: GatherCmd.$_createMessage)
    ..aOM<AttackCityCmd>(10, _omitFieldNames ? '' : 'attackCity',
        subBuilder: AttackCityCmd.$_createMessage)
    ..aOM<AttackFortCmd>(11, _omitFieldNames ? '' : 'attackFort',
        subBuilder: AttackFortCmd.$_createMessage)
    ..aOM<ReinforceCmd>(12, _omitFieldNames ? '' : 'reinforce',
        subBuilder: ReinforceCmd.$_createMessage)
    ..aOM<TransportCmd>(13, _omitFieldNames ? '' : 'transport',
        subBuilder: TransportCmd.$_createMessage)
    ..aOM<RecallCmd>(14, _omitFieldNames ? '' : 'recall',
        subBuilder: RecallCmd.$_createMessage)
    ..aOM<SetShieldCmd>(15, _omitFieldNames ? '' : 'setShield',
        subBuilder: SetShieldCmd.$_createMessage)
    ..aOM<CreateAllianceCmd>(16, _omitFieldNames ? '' : 'createAlliance',
        subBuilder: CreateAllianceCmd.$_createMessage)
    ..aOM<AllianceInviteCmd>(17, _omitFieldNames ? '' : 'allianceInvite',
        subBuilder: AllianceInviteCmd.$_createMessage)
    ..aOM<AllianceAcceptCmd>(18, _omitFieldNames ? '' : 'allianceAccept',
        subBuilder: AllianceAcceptCmd.$_createMessage)
    ..aOM<AllianceJoinCmd>(19, _omitFieldNames ? '' : 'allianceJoin',
        subBuilder: AllianceJoinCmd.$_createMessage)
    ..aOM<AllianceLeaveCmd>(20, _omitFieldNames ? '' : 'allianceLeave',
        subBuilder: AllianceLeaveCmd.$_createMessage)
    ..aOM<AllianceKickCmd>(21, _omitFieldNames ? '' : 'allianceKick',
        subBuilder: AllianceKickCmd.$_createMessage)
    ..aOM<AllianceHelpCmd>(22, _omitFieldNames ? '' : 'allianceHelp',
        subBuilder: AllianceHelpCmd.$_createMessage)
    ..aOM<RallyCreateCmd>(23, _omitFieldNames ? '' : 'rallyCreate',
        subBuilder: RallyCreateCmd.$_createMessage)
    ..aOM<RallyJoinCmd>(24, _omitFieldNames ? '' : 'rallyJoin',
        subBuilder: RallyJoinCmd.$_createMessage)
    ..aOM<RallyCancelCmd>(25, _omitFieldNames ? '' : 'rallyCancel',
        subBuilder: RallyCancelCmd.$_createMessage)
    ..aOM<ChatCmd>(26, _omitFieldNames ? '' : 'chat',
        subBuilder: ChatCmd.$_createMessage)
    ..aOM<SwitchCapitalCmd>(27, _omitFieldNames ? '' : 'switchCapital',
        subBuilder: SwitchCapitalCmd.$_createMessage)
    ..aOM<RecruitHeroCmd>(28, _omitFieldNames ? '' : 'recruitHero',
        subBuilder: RecruitHeroCmd.$_createMessage)
    ..aOM<DemolishBuildingCmd>(29, _omitFieldNames ? '' : 'demolishBuilding',
        subBuilder: DemolishBuildingCmd.$_createMessage)
    ..aOM<MarketBuyCmd>(30, _omitFieldNames ? '' : 'marketBuy',
        subBuilder: MarketBuyCmd.$_createMessage)
    ..aOM<MarketSellCmd>(31, _omitFieldNames ? '' : 'marketSell',
        subBuilder: MarketSellCmd.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandPayload copyWith(void Function(CommandPayload) updates) =>
      super.copyWith((message) => updates(message as CommandPayload))
          as CommandPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommandPayload() / CommandPayload.new instead')
  static CommandPayload create() => CommandPayload._();
  static $pb.GeneratedMessage $_createMessage() => CommandPayload._();
  @$core.override
  CommandPayload createEmptyInstance() => CommandPayload._();
  @$core.pragma('dart2js:noInline')
  static CommandPayload getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommandPayload>(
          CommandPayload.$_createMessage);
  static CommandPayload? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(18)
  @$pb.TagNumber(19)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  @$pb.TagNumber(23)
  @$pb.TagNumber(24)
  @$pb.TagNumber(25)
  @$pb.TagNumber(26)
  @$pb.TagNumber(27)
  @$pb.TagNumber(28)
  @$pb.TagNumber(29)
  @$pb.TagNumber(30)
  @$pb.TagNumber(31)
  CommandPayload_Action whichAction() =>
      _CommandPayload_ActionByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(18)
  @$pb.TagNumber(19)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  @$pb.TagNumber(23)
  @$pb.TagNumber(24)
  @$pb.TagNumber(25)
  @$pb.TagNumber(26)
  @$pb.TagNumber(27)
  @$pb.TagNumber(28)
  @$pb.TagNumber(29)
  @$pb.TagNumber(30)
  @$pb.TagNumber(31)
  void clearAction() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  CreateCityCmd get createCity => $_getN(0);
  @$pb.TagNumber(1)
  set createCity(CreateCityCmd value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCreateCity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCreateCity() => $_clearField(1);
  @$pb.TagNumber(1)
  CreateCityCmd ensureCreateCity() => $_ensure(0);

  @$pb.TagNumber(2)
  UpgradeBuildingCmd get upgradeBuilding => $_getN(1);
  @$pb.TagNumber(2)
  set upgradeBuilding(UpgradeBuildingCmd value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUpgradeBuilding() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpgradeBuilding() => $_clearField(2);
  @$pb.TagNumber(2)
  UpgradeBuildingCmd ensureUpgradeBuilding() => $_ensure(1);

  @$pb.TagNumber(3)
  StartResearchCmd get startResearch => $_getN(2);
  @$pb.TagNumber(3)
  set startResearch(StartResearchCmd value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStartResearch() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartResearch() => $_clearField(3);
  @$pb.TagNumber(3)
  StartResearchCmd ensureStartResearch() => $_ensure(2);

  @$pb.TagNumber(4)
  TrainTroopsCmd get trainTroops => $_getN(3);
  @$pb.TagNumber(4)
  set trainTroops(TrainTroopsCmd value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTrainTroops() => $_has(3);
  @$pb.TagNumber(4)
  void clearTrainTroops() => $_clearField(4);
  @$pb.TagNumber(4)
  TrainTroopsCmd ensureTrainTroops() => $_ensure(3);

  @$pb.TagNumber(5)
  HealTroopsCmd get healTroops => $_getN(4);
  @$pb.TagNumber(5)
  set healTroops(HealTroopsCmd value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasHealTroops() => $_has(4);
  @$pb.TagNumber(5)
  void clearHealTroops() => $_clearField(5);
  @$pb.TagNumber(5)
  HealTroopsCmd ensureHealTroops() => $_ensure(4);

  @$pb.TagNumber(6)
  UseItemCmd get useItem => $_getN(5);
  @$pb.TagNumber(6)
  set useItem(UseItemCmd value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasUseItem() => $_has(5);
  @$pb.TagNumber(6)
  void clearUseItem() => $_clearField(6);
  @$pb.TagNumber(6)
  UseItemCmd ensureUseItem() => $_ensure(5);

  @$pb.TagNumber(7)
  ScoutTileCmd get scoutTile => $_getN(6);
  @$pb.TagNumber(7)
  set scoutTile(ScoutTileCmd value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasScoutTile() => $_has(6);
  @$pb.TagNumber(7)
  void clearScoutTile() => $_clearField(7);
  @$pb.TagNumber(7)
  ScoutTileCmd ensureScoutTile() => $_ensure(6);

  @$pb.TagNumber(8)
  AttackMonsterCmd get attackMonster => $_getN(7);
  @$pb.TagNumber(8)
  set attackMonster(AttackMonsterCmd value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasAttackMonster() => $_has(7);
  @$pb.TagNumber(8)
  void clearAttackMonster() => $_clearField(8);
  @$pb.TagNumber(8)
  AttackMonsterCmd ensureAttackMonster() => $_ensure(7);

  @$pb.TagNumber(9)
  GatherCmd get gather => $_getN(8);
  @$pb.TagNumber(9)
  set gather(GatherCmd value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasGather() => $_has(8);
  @$pb.TagNumber(9)
  void clearGather() => $_clearField(9);
  @$pb.TagNumber(9)
  GatherCmd ensureGather() => $_ensure(8);

  @$pb.TagNumber(10)
  AttackCityCmd get attackCity => $_getN(9);
  @$pb.TagNumber(10)
  set attackCity(AttackCityCmd value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasAttackCity() => $_has(9);
  @$pb.TagNumber(10)
  void clearAttackCity() => $_clearField(10);
  @$pb.TagNumber(10)
  AttackCityCmd ensureAttackCity() => $_ensure(9);

  @$pb.TagNumber(11)
  AttackFortCmd get attackFort => $_getN(10);
  @$pb.TagNumber(11)
  set attackFort(AttackFortCmd value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasAttackFort() => $_has(10);
  @$pb.TagNumber(11)
  void clearAttackFort() => $_clearField(11);
  @$pb.TagNumber(11)
  AttackFortCmd ensureAttackFort() => $_ensure(10);

  @$pb.TagNumber(12)
  ReinforceCmd get reinforce => $_getN(11);
  @$pb.TagNumber(12)
  set reinforce(ReinforceCmd value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasReinforce() => $_has(11);
  @$pb.TagNumber(12)
  void clearReinforce() => $_clearField(12);
  @$pb.TagNumber(12)
  ReinforceCmd ensureReinforce() => $_ensure(11);

  @$pb.TagNumber(13)
  TransportCmd get transport => $_getN(12);
  @$pb.TagNumber(13)
  set transport(TransportCmd value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasTransport() => $_has(12);
  @$pb.TagNumber(13)
  void clearTransport() => $_clearField(13);
  @$pb.TagNumber(13)
  TransportCmd ensureTransport() => $_ensure(12);

  @$pb.TagNumber(14)
  RecallCmd get recall => $_getN(13);
  @$pb.TagNumber(14)
  set recall(RecallCmd value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasRecall() => $_has(13);
  @$pb.TagNumber(14)
  void clearRecall() => $_clearField(14);
  @$pb.TagNumber(14)
  RecallCmd ensureRecall() => $_ensure(13);

  @$pb.TagNumber(15)
  SetShieldCmd get setShield => $_getN(14);
  @$pb.TagNumber(15)
  set setShield(SetShieldCmd value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasSetShield() => $_has(14);
  @$pb.TagNumber(15)
  void clearSetShield() => $_clearField(15);
  @$pb.TagNumber(15)
  SetShieldCmd ensureSetShield() => $_ensure(14);

  @$pb.TagNumber(16)
  CreateAllianceCmd get createAlliance => $_getN(15);
  @$pb.TagNumber(16)
  set createAlliance(CreateAllianceCmd value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasCreateAlliance() => $_has(15);
  @$pb.TagNumber(16)
  void clearCreateAlliance() => $_clearField(16);
  @$pb.TagNumber(16)
  CreateAllianceCmd ensureCreateAlliance() => $_ensure(15);

  @$pb.TagNumber(17)
  AllianceInviteCmd get allianceInvite => $_getN(16);
  @$pb.TagNumber(17)
  set allianceInvite(AllianceInviteCmd value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasAllianceInvite() => $_has(16);
  @$pb.TagNumber(17)
  void clearAllianceInvite() => $_clearField(17);
  @$pb.TagNumber(17)
  AllianceInviteCmd ensureAllianceInvite() => $_ensure(16);

  @$pb.TagNumber(18)
  AllianceAcceptCmd get allianceAccept => $_getN(17);
  @$pb.TagNumber(18)
  set allianceAccept(AllianceAcceptCmd value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasAllianceAccept() => $_has(17);
  @$pb.TagNumber(18)
  void clearAllianceAccept() => $_clearField(18);
  @$pb.TagNumber(18)
  AllianceAcceptCmd ensureAllianceAccept() => $_ensure(17);

  @$pb.TagNumber(19)
  AllianceJoinCmd get allianceJoin => $_getN(18);
  @$pb.TagNumber(19)
  set allianceJoin(AllianceJoinCmd value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasAllianceJoin() => $_has(18);
  @$pb.TagNumber(19)
  void clearAllianceJoin() => $_clearField(19);
  @$pb.TagNumber(19)
  AllianceJoinCmd ensureAllianceJoin() => $_ensure(18);

  @$pb.TagNumber(20)
  AllianceLeaveCmd get allianceLeave => $_getN(19);
  @$pb.TagNumber(20)
  set allianceLeave(AllianceLeaveCmd value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasAllianceLeave() => $_has(19);
  @$pb.TagNumber(20)
  void clearAllianceLeave() => $_clearField(20);
  @$pb.TagNumber(20)
  AllianceLeaveCmd ensureAllianceLeave() => $_ensure(19);

  @$pb.TagNumber(21)
  AllianceKickCmd get allianceKick => $_getN(20);
  @$pb.TagNumber(21)
  set allianceKick(AllianceKickCmd value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasAllianceKick() => $_has(20);
  @$pb.TagNumber(21)
  void clearAllianceKick() => $_clearField(21);
  @$pb.TagNumber(21)
  AllianceKickCmd ensureAllianceKick() => $_ensure(20);

  @$pb.TagNumber(22)
  AllianceHelpCmd get allianceHelp => $_getN(21);
  @$pb.TagNumber(22)
  set allianceHelp(AllianceHelpCmd value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasAllianceHelp() => $_has(21);
  @$pb.TagNumber(22)
  void clearAllianceHelp() => $_clearField(22);
  @$pb.TagNumber(22)
  AllianceHelpCmd ensureAllianceHelp() => $_ensure(21);

  @$pb.TagNumber(23)
  RallyCreateCmd get rallyCreate => $_getN(22);
  @$pb.TagNumber(23)
  set rallyCreate(RallyCreateCmd value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasRallyCreate() => $_has(22);
  @$pb.TagNumber(23)
  void clearRallyCreate() => $_clearField(23);
  @$pb.TagNumber(23)
  RallyCreateCmd ensureRallyCreate() => $_ensure(22);

  @$pb.TagNumber(24)
  RallyJoinCmd get rallyJoin => $_getN(23);
  @$pb.TagNumber(24)
  set rallyJoin(RallyJoinCmd value) => $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasRallyJoin() => $_has(23);
  @$pb.TagNumber(24)
  void clearRallyJoin() => $_clearField(24);
  @$pb.TagNumber(24)
  RallyJoinCmd ensureRallyJoin() => $_ensure(23);

  @$pb.TagNumber(25)
  RallyCancelCmd get rallyCancel => $_getN(24);
  @$pb.TagNumber(25)
  set rallyCancel(RallyCancelCmd value) => $_setField(25, value);
  @$pb.TagNumber(25)
  $core.bool hasRallyCancel() => $_has(24);
  @$pb.TagNumber(25)
  void clearRallyCancel() => $_clearField(25);
  @$pb.TagNumber(25)
  RallyCancelCmd ensureRallyCancel() => $_ensure(24);

  @$pb.TagNumber(26)
  ChatCmd get chat => $_getN(25);
  @$pb.TagNumber(26)
  set chat(ChatCmd value) => $_setField(26, value);
  @$pb.TagNumber(26)
  $core.bool hasChat() => $_has(25);
  @$pb.TagNumber(26)
  void clearChat() => $_clearField(26);
  @$pb.TagNumber(26)
  ChatCmd ensureChat() => $_ensure(25);

  @$pb.TagNumber(27)
  SwitchCapitalCmd get switchCapital => $_getN(26);
  @$pb.TagNumber(27)
  set switchCapital(SwitchCapitalCmd value) => $_setField(27, value);
  @$pb.TagNumber(27)
  $core.bool hasSwitchCapital() => $_has(26);
  @$pb.TagNumber(27)
  void clearSwitchCapital() => $_clearField(27);
  @$pb.TagNumber(27)
  SwitchCapitalCmd ensureSwitchCapital() => $_ensure(26);

  @$pb.TagNumber(28)
  RecruitHeroCmd get recruitHero => $_getN(27);
  @$pb.TagNumber(28)
  set recruitHero(RecruitHeroCmd value) => $_setField(28, value);
  @$pb.TagNumber(28)
  $core.bool hasRecruitHero() => $_has(27);
  @$pb.TagNumber(28)
  void clearRecruitHero() => $_clearField(28);
  @$pb.TagNumber(28)
  RecruitHeroCmd ensureRecruitHero() => $_ensure(27);

  @$pb.TagNumber(29)
  DemolishBuildingCmd get demolishBuilding => $_getN(28);
  @$pb.TagNumber(29)
  set demolishBuilding(DemolishBuildingCmd value) => $_setField(29, value);
  @$pb.TagNumber(29)
  $core.bool hasDemolishBuilding() => $_has(28);
  @$pb.TagNumber(29)
  void clearDemolishBuilding() => $_clearField(29);
  @$pb.TagNumber(29)
  DemolishBuildingCmd ensureDemolishBuilding() => $_ensure(28);

  @$pb.TagNumber(30)
  MarketBuyCmd get marketBuy => $_getN(29);
  @$pb.TagNumber(30)
  set marketBuy(MarketBuyCmd value) => $_setField(30, value);
  @$pb.TagNumber(30)
  $core.bool hasMarketBuy() => $_has(29);
  @$pb.TagNumber(30)
  void clearMarketBuy() => $_clearField(30);
  @$pb.TagNumber(30)
  MarketBuyCmd ensureMarketBuy() => $_ensure(29);

  @$pb.TagNumber(31)
  MarketSellCmd get marketSell => $_getN(30);
  @$pb.TagNumber(31)
  set marketSell(MarketSellCmd value) => $_setField(31, value);
  @$pb.TagNumber(31)
  $core.bool hasMarketSell() => $_has(30);
  @$pb.TagNumber(31)
  void clearMarketSell() => $_clearField(31);
  @$pb.TagNumber(31)
  MarketSellCmd ensureMarketSell() => $_ensure(30);
}

class CreateCityCmd extends $pb.GeneratedMessage {
  factory CreateCityCmd({
    $core.String? name,
    Vec2? pos,
  }) {
    final result = CreateCityCmd._();
    if (name != null) result.name = name;
    if (pos != null) result.pos = pos;
    return result;
  }

  CreateCityCmd._();

  factory CreateCityCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateCityCmd()..mergeFromBuffer(data, registry);
  factory CreateCityCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateCityCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCityCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: CreateCityCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOM<Vec2>(2, _omitFieldNames ? '' : 'pos',
        subBuilder: Vec2.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCityCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCityCmd copyWith(void Function(CreateCityCmd) updates) =>
      super.copyWith((message) => updates(message as CreateCityCmd))
          as CreateCityCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateCityCmd() / CreateCityCmd.new instead')
  static CreateCityCmd create() => CreateCityCmd._();
  static $pb.GeneratedMessage $_createMessage() => CreateCityCmd._();
  @$core.override
  CreateCityCmd createEmptyInstance() => CreateCityCmd._();
  @$core.pragma('dart2js:noInline')
  static CreateCityCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateCityCmd>(
          CreateCityCmd.$_createMessage);
  static CreateCityCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  Vec2 get pos => $_getN(1);
  @$pb.TagNumber(2)
  set pos(Vec2 value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPos() => $_has(1);
  @$pb.TagNumber(2)
  void clearPos() => $_clearField(2);
  @$pb.TagNumber(2)
  Vec2 ensurePos() => $_ensure(1);
}

class UpgradeBuildingCmd extends $pb.GeneratedMessage {
  factory UpgradeBuildingCmd({
    $core.String? cityId,
    $core.String? building,
  }) {
    final result = UpgradeBuildingCmd._();
    if (cityId != null) result.cityId = cityId;
    if (building != null) result.building = building;
    return result;
  }

  UpgradeBuildingCmd._();

  factory UpgradeBuildingCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpgradeBuildingCmd()..mergeFromBuffer(data, registry);
  factory UpgradeBuildingCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpgradeBuildingCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpgradeBuildingCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: UpgradeBuildingCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cityId')
    ..aOS(2, _omitFieldNames ? '' : 'building')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpgradeBuildingCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpgradeBuildingCmd copyWith(void Function(UpgradeBuildingCmd) updates) =>
      super.copyWith((message) => updates(message as UpgradeBuildingCmd))
          as UpgradeBuildingCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpgradeBuildingCmd() / UpgradeBuildingCmd.new instead')
  static UpgradeBuildingCmd create() => UpgradeBuildingCmd._();
  static $pb.GeneratedMessage $_createMessage() => UpgradeBuildingCmd._();
  @$core.override
  UpgradeBuildingCmd createEmptyInstance() => UpgradeBuildingCmd._();
  @$core.pragma('dart2js:noInline')
  static UpgradeBuildingCmd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpgradeBuildingCmd>(
          UpgradeBuildingCmd.$_createMessage);
  static UpgradeBuildingCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get building => $_getSZ(1);
  @$pb.TagNumber(2)
  set building($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBuilding() => $_has(1);
  @$pb.TagNumber(2)
  void clearBuilding() => $_clearField(2);
}

class StartResearchCmd extends $pb.GeneratedMessage {
  factory StartResearchCmd({
    $core.String? tech,
  }) {
    final result = StartResearchCmd._();
    if (tech != null) result.tech = tech;
    return result;
  }

  StartResearchCmd._();

  factory StartResearchCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartResearchCmd()..mergeFromBuffer(data, registry);
  factory StartResearchCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartResearchCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StartResearchCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: StartResearchCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'tech')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartResearchCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartResearchCmd copyWith(void Function(StartResearchCmd) updates) =>
      super.copyWith((message) => updates(message as StartResearchCmd))
          as StartResearchCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StartResearchCmd() / StartResearchCmd.new instead')
  static StartResearchCmd create() => StartResearchCmd._();
  static $pb.GeneratedMessage $_createMessage() => StartResearchCmd._();
  @$core.override
  StartResearchCmd createEmptyInstance() => StartResearchCmd._();
  @$core.pragma('dart2js:noInline')
  static StartResearchCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartResearchCmd>(
          StartResearchCmd.$_createMessage);
  static StartResearchCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tech => $_getSZ(0);
  @$pb.TagNumber(1)
  set tech($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTech() => $_has(0);
  @$pb.TagNumber(1)
  void clearTech() => $_clearField(1);
}

class TrainTroopsCmd extends $pb.GeneratedMessage {
  factory TrainTroopsCmd({
    $core.String? cityId,
    $core.String? unit,
    $core.int? tier,
    $core.int? count,
  }) {
    final result = TrainTroopsCmd._();
    if (cityId != null) result.cityId = cityId;
    if (unit != null) result.unit = unit;
    if (tier != null) result.tier = tier;
    if (count != null) result.count = count;
    return result;
  }

  TrainTroopsCmd._();

  factory TrainTroopsCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TrainTroopsCmd()..mergeFromBuffer(data, registry);
  factory TrainTroopsCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TrainTroopsCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TrainTroopsCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: TrainTroopsCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cityId')
    ..aOS(2, _omitFieldNames ? '' : 'unit')
    ..aI(3, _omitFieldNames ? '' : 'tier', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'count', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrainTroopsCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrainTroopsCmd copyWith(void Function(TrainTroopsCmd) updates) =>
      super.copyWith((message) => updates(message as TrainTroopsCmd))
          as TrainTroopsCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TrainTroopsCmd() / TrainTroopsCmd.new instead')
  static TrainTroopsCmd create() => TrainTroopsCmd._();
  static $pb.GeneratedMessage $_createMessage() => TrainTroopsCmd._();
  @$core.override
  TrainTroopsCmd createEmptyInstance() => TrainTroopsCmd._();
  @$core.pragma('dart2js:noInline')
  static TrainTroopsCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TrainTroopsCmd>(
          TrainTroopsCmd.$_createMessage);
  static TrainTroopsCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get unit => $_getSZ(1);
  @$pb.TagNumber(2)
  set unit($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUnit() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get tier => $_getIZ(2);
  @$pb.TagNumber(3)
  set tier($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTier() => $_has(2);
  @$pb.TagNumber(3)
  void clearTier() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get count => $_getIZ(3);
  @$pb.TagNumber(4)
  set count($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearCount() => $_clearField(4);
}

class HealTroopsCmd extends $pb.GeneratedMessage {
  factory HealTroopsCmd({
    $core.String? cityId,
    $core.String? unit,
    $core.int? tier,
    $core.int? count,
  }) {
    final result = HealTroopsCmd._();
    if (cityId != null) result.cityId = cityId;
    if (unit != null) result.unit = unit;
    if (tier != null) result.tier = tier;
    if (count != null) result.count = count;
    return result;
  }

  HealTroopsCmd._();

  factory HealTroopsCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HealTroopsCmd()..mergeFromBuffer(data, registry);
  factory HealTroopsCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HealTroopsCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HealTroopsCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: HealTroopsCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cityId')
    ..aOS(2, _omitFieldNames ? '' : 'unit')
    ..aI(3, _omitFieldNames ? '' : 'tier', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'count', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealTroopsCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealTroopsCmd copyWith(void Function(HealTroopsCmd) updates) =>
      super.copyWith((message) => updates(message as HealTroopsCmd))
          as HealTroopsCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HealTroopsCmd() / HealTroopsCmd.new instead')
  static HealTroopsCmd create() => HealTroopsCmd._();
  static $pb.GeneratedMessage $_createMessage() => HealTroopsCmd._();
  @$core.override
  HealTroopsCmd createEmptyInstance() => HealTroopsCmd._();
  @$core.pragma('dart2js:noInline')
  static HealTroopsCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HealTroopsCmd>(
          HealTroopsCmd.$_createMessage);
  static HealTroopsCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get unit => $_getSZ(1);
  @$pb.TagNumber(2)
  set unit($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUnit() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get tier => $_getIZ(2);
  @$pb.TagNumber(3)
  set tier($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTier() => $_has(2);
  @$pb.TagNumber(3)
  void clearTier() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get count => $_getIZ(3);
  @$pb.TagNumber(4)
  set count($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearCount() => $_clearField(4);
}

class UseItemCmd extends $pb.GeneratedMessage {
  factory UseItemCmd({
    $core.String? item,
    $core.String? targetCityId,
  }) {
    final result = UseItemCmd._();
    if (item != null) result.item = item;
    if (targetCityId != null) result.targetCityId = targetCityId;
    return result;
  }

  UseItemCmd._();

  factory UseItemCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UseItemCmd()..mergeFromBuffer(data, registry);
  factory UseItemCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UseItemCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UseItemCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: UseItemCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'item')
    ..aOS(2, _omitFieldNames ? '' : 'targetCityId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UseItemCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UseItemCmd copyWith(void Function(UseItemCmd) updates) =>
      super.copyWith((message) => updates(message as UseItemCmd)) as UseItemCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UseItemCmd() / UseItemCmd.new instead')
  static UseItemCmd create() => UseItemCmd._();
  static $pb.GeneratedMessage $_createMessage() => UseItemCmd._();
  @$core.override
  UseItemCmd createEmptyInstance() => UseItemCmd._();
  @$core.pragma('dart2js:noInline')
  static UseItemCmd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UseItemCmd>(UseItemCmd.$_createMessage);
  static UseItemCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get item => $_getSZ(0);
  @$pb.TagNumber(1)
  set item($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasItem() => $_has(0);
  @$pb.TagNumber(1)
  void clearItem() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get targetCityId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetCityId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetCityId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetCityId() => $_clearField(2);
}

class ScoutTileCmd extends $pb.GeneratedMessage {
  factory ScoutTileCmd({
    Vec2? pos,
  }) {
    final result = ScoutTileCmd._();
    if (pos != null) result.pos = pos;
    return result;
  }

  ScoutTileCmd._();

  factory ScoutTileCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ScoutTileCmd()..mergeFromBuffer(data, registry);
  factory ScoutTileCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ScoutTileCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScoutTileCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: ScoutTileCmd.$_createMessage)
    ..aOM<Vec2>(1, _omitFieldNames ? '' : 'pos',
        subBuilder: Vec2.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScoutTileCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScoutTileCmd copyWith(void Function(ScoutTileCmd) updates) =>
      super.copyWith((message) => updates(message as ScoutTileCmd))
          as ScoutTileCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ScoutTileCmd() / ScoutTileCmd.new instead')
  static ScoutTileCmd create() => ScoutTileCmd._();
  static $pb.GeneratedMessage $_createMessage() => ScoutTileCmd._();
  @$core.override
  ScoutTileCmd createEmptyInstance() => ScoutTileCmd._();
  @$core.pragma('dart2js:noInline')
  static ScoutTileCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScoutTileCmd>(
          ScoutTileCmd.$_createMessage);
  static ScoutTileCmd? _defaultInstance;

  @$pb.TagNumber(1)
  Vec2 get pos => $_getN(0);
  @$pb.TagNumber(1)
  set pos(Vec2 value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPos() => $_has(0);
  @$pb.TagNumber(1)
  void clearPos() => $_clearField(1);
  @$pb.TagNumber(1)
  Vec2 ensurePos() => $_ensure(0);
}

class AttackMonsterCmd extends $pb.GeneratedMessage {
  factory AttackMonsterCmd({
    $core.String? cityId,
    $core.String? monsterId,
  }) {
    final result = AttackMonsterCmd._();
    if (cityId != null) result.cityId = cityId;
    if (monsterId != null) result.monsterId = monsterId;
    return result;
  }

  AttackMonsterCmd._();

  factory AttackMonsterCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttackMonsterCmd()..mergeFromBuffer(data, registry);
  factory AttackMonsterCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttackMonsterCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttackMonsterCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: AttackMonsterCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cityId')
    ..aOS(2, _omitFieldNames ? '' : 'monsterId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttackMonsterCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttackMonsterCmd copyWith(void Function(AttackMonsterCmd) updates) =>
      super.copyWith((message) => updates(message as AttackMonsterCmd))
          as AttackMonsterCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AttackMonsterCmd() / AttackMonsterCmd.new instead')
  static AttackMonsterCmd create() => AttackMonsterCmd._();
  static $pb.GeneratedMessage $_createMessage() => AttackMonsterCmd._();
  @$core.override
  AttackMonsterCmd createEmptyInstance() => AttackMonsterCmd._();
  @$core.pragma('dart2js:noInline')
  static AttackMonsterCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AttackMonsterCmd>(
          AttackMonsterCmd.$_createMessage);
  static AttackMonsterCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get monsterId => $_getSZ(1);
  @$pb.TagNumber(2)
  set monsterId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMonsterId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMonsterId() => $_clearField(2);
}

class GatherCmd extends $pb.GeneratedMessage {
  factory GatherCmd({
    $core.String? cityId,
    $core.String? nodeId,
  }) {
    final result = GatherCmd._();
    if (cityId != null) result.cityId = cityId;
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  GatherCmd._();

  factory GatherCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GatherCmd()..mergeFromBuffer(data, registry);
  factory GatherCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GatherCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GatherCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: GatherCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cityId')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatherCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatherCmd copyWith(void Function(GatherCmd) updates) =>
      super.copyWith((message) => updates(message as GatherCmd)) as GatherCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GatherCmd() / GatherCmd.new instead')
  static GatherCmd create() => GatherCmd._();
  static $pb.GeneratedMessage $_createMessage() => GatherCmd._();
  @$core.override
  GatherCmd createEmptyInstance() => GatherCmd._();
  @$core.pragma('dart2js:noInline')
  static GatherCmd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GatherCmd>(GatherCmd.$_createMessage);
  static GatherCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);
}

class AttackCityCmd extends $pb.GeneratedMessage {
  factory AttackCityCmd({
    $core.String? cityId,
    $core.String? targetCityId,
  }) {
    final result = AttackCityCmd._();
    if (cityId != null) result.cityId = cityId;
    if (targetCityId != null) result.targetCityId = targetCityId;
    return result;
  }

  AttackCityCmd._();

  factory AttackCityCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttackCityCmd()..mergeFromBuffer(data, registry);
  factory AttackCityCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttackCityCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttackCityCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: AttackCityCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cityId')
    ..aOS(2, _omitFieldNames ? '' : 'targetCityId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttackCityCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttackCityCmd copyWith(void Function(AttackCityCmd) updates) =>
      super.copyWith((message) => updates(message as AttackCityCmd))
          as AttackCityCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AttackCityCmd() / AttackCityCmd.new instead')
  static AttackCityCmd create() => AttackCityCmd._();
  static $pb.GeneratedMessage $_createMessage() => AttackCityCmd._();
  @$core.override
  AttackCityCmd createEmptyInstance() => AttackCityCmd._();
  @$core.pragma('dart2js:noInline')
  static AttackCityCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AttackCityCmd>(
          AttackCityCmd.$_createMessage);
  static AttackCityCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get targetCityId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetCityId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetCityId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetCityId() => $_clearField(2);
}

class AttackFortCmd extends $pb.GeneratedMessage {
  factory AttackFortCmd({
    $core.String? cityId,
    $core.String? fortId,
  }) {
    final result = AttackFortCmd._();
    if (cityId != null) result.cityId = cityId;
    if (fortId != null) result.fortId = fortId;
    return result;
  }

  AttackFortCmd._();

  factory AttackFortCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttackFortCmd()..mergeFromBuffer(data, registry);
  factory AttackFortCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttackFortCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttackFortCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: AttackFortCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cityId')
    ..aOS(2, _omitFieldNames ? '' : 'fortId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttackFortCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttackFortCmd copyWith(void Function(AttackFortCmd) updates) =>
      super.copyWith((message) => updates(message as AttackFortCmd))
          as AttackFortCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AttackFortCmd() / AttackFortCmd.new instead')
  static AttackFortCmd create() => AttackFortCmd._();
  static $pb.GeneratedMessage $_createMessage() => AttackFortCmd._();
  @$core.override
  AttackFortCmd createEmptyInstance() => AttackFortCmd._();
  @$core.pragma('dart2js:noInline')
  static AttackFortCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AttackFortCmd>(
          AttackFortCmd.$_createMessage);
  static AttackFortCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fortId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fortId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFortId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFortId() => $_clearField(2);
}

class ReinforceCmd extends $pb.GeneratedMessage {
  factory ReinforceCmd({
    $core.String? cityId,
    $core.String? targetCityId,
    $core.Iterable<TroopSend>? troops,
  }) {
    final result = ReinforceCmd._();
    if (cityId != null) result.cityId = cityId;
    if (targetCityId != null) result.targetCityId = targetCityId;
    if (troops != null) result.troops.addAll(troops);
    return result;
  }

  ReinforceCmd._();

  factory ReinforceCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReinforceCmd()..mergeFromBuffer(data, registry);
  factory ReinforceCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReinforceCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReinforceCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: ReinforceCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cityId')
    ..aOS(2, _omitFieldNames ? '' : 'targetCityId')
    ..pPM<TroopSend>(3, _omitFieldNames ? '' : 'troops',
        subBuilder: TroopSend.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReinforceCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReinforceCmd copyWith(void Function(ReinforceCmd) updates) =>
      super.copyWith((message) => updates(message as ReinforceCmd))
          as ReinforceCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReinforceCmd() / ReinforceCmd.new instead')
  static ReinforceCmd create() => ReinforceCmd._();
  static $pb.GeneratedMessage $_createMessage() => ReinforceCmd._();
  @$core.override
  ReinforceCmd createEmptyInstance() => ReinforceCmd._();
  @$core.pragma('dart2js:noInline')
  static ReinforceCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReinforceCmd>(
          ReinforceCmd.$_createMessage);
  static ReinforceCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get targetCityId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetCityId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetCityId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetCityId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<TroopSend> get troops => $_getList(2);
}

class TransportCmd extends $pb.GeneratedMessage {
  factory TransportCmd({
    $core.String? cityId,
    $core.String? targetCityId,
    Resources? resources,
  }) {
    final result = TransportCmd._();
    if (cityId != null) result.cityId = cityId;
    if (targetCityId != null) result.targetCityId = targetCityId;
    if (resources != null) result.resources = resources;
    return result;
  }

  TransportCmd._();

  factory TransportCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransportCmd()..mergeFromBuffer(data, registry);
  factory TransportCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransportCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransportCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: TransportCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cityId')
    ..aOS(2, _omitFieldNames ? '' : 'targetCityId')
    ..aOM<Resources>(3, _omitFieldNames ? '' : 'resources',
        subBuilder: Resources.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransportCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransportCmd copyWith(void Function(TransportCmd) updates) =>
      super.copyWith((message) => updates(message as TransportCmd))
          as TransportCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransportCmd() / TransportCmd.new instead')
  static TransportCmd create() => TransportCmd._();
  static $pb.GeneratedMessage $_createMessage() => TransportCmd._();
  @$core.override
  TransportCmd createEmptyInstance() => TransportCmd._();
  @$core.pragma('dart2js:noInline')
  static TransportCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransportCmd>(
          TransportCmd.$_createMessage);
  static TransportCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get targetCityId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetCityId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetCityId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetCityId() => $_clearField(2);

  @$pb.TagNumber(3)
  Resources get resources => $_getN(2);
  @$pb.TagNumber(3)
  set resources(Resources value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasResources() => $_has(2);
  @$pb.TagNumber(3)
  void clearResources() => $_clearField(3);
  @$pb.TagNumber(3)
  Resources ensureResources() => $_ensure(2);
}

class RecallCmd extends $pb.GeneratedMessage {
  factory RecallCmd({
    $core.String? marchId,
  }) {
    final result = RecallCmd._();
    if (marchId != null) result.marchId = marchId;
    return result;
  }

  RecallCmd._();

  factory RecallCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecallCmd()..mergeFromBuffer(data, registry);
  factory RecallCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecallCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecallCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: RecallCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'marchId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecallCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecallCmd copyWith(void Function(RecallCmd) updates) =>
      super.copyWith((message) => updates(message as RecallCmd)) as RecallCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RecallCmd() / RecallCmd.new instead')
  static RecallCmd create() => RecallCmd._();
  static $pb.GeneratedMessage $_createMessage() => RecallCmd._();
  @$core.override
  RecallCmd createEmptyInstance() => RecallCmd._();
  @$core.pragma('dart2js:noInline')
  static RecallCmd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecallCmd>(RecallCmd.$_createMessage);
  static RecallCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get marchId => $_getSZ(0);
  @$pb.TagNumber(1)
  set marchId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMarchId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarchId() => $_clearField(1);
}

class SetShieldCmd extends $pb.GeneratedMessage {
  factory SetShieldCmd({
    $core.int? hours,
  }) {
    final result = SetShieldCmd._();
    if (hours != null) result.hours = hours;
    return result;
  }

  SetShieldCmd._();

  factory SetShieldCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetShieldCmd()..mergeFromBuffer(data, registry);
  factory SetShieldCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetShieldCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetShieldCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: SetShieldCmd.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'hours', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetShieldCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetShieldCmd copyWith(void Function(SetShieldCmd) updates) =>
      super.copyWith((message) => updates(message as SetShieldCmd))
          as SetShieldCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetShieldCmd() / SetShieldCmd.new instead')
  static SetShieldCmd create() => SetShieldCmd._();
  static $pb.GeneratedMessage $_createMessage() => SetShieldCmd._();
  @$core.override
  SetShieldCmd createEmptyInstance() => SetShieldCmd._();
  @$core.pragma('dart2js:noInline')
  static SetShieldCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetShieldCmd>(
          SetShieldCmd.$_createMessage);
  static SetShieldCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get hours => $_getIZ(0);
  @$pb.TagNumber(1)
  set hours($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHours() => $_has(0);
  @$pb.TagNumber(1)
  void clearHours() => $_clearField(1);
}

class CreateAllianceCmd extends $pb.GeneratedMessage {
  factory CreateAllianceCmd({
    $core.String? name,
    $core.String? tag,
  }) {
    final result = CreateAllianceCmd._();
    if (name != null) result.name = name;
    if (tag != null) result.tag = tag;
    return result;
  }

  CreateAllianceCmd._();

  factory CreateAllianceCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateAllianceCmd()..mergeFromBuffer(data, registry);
  factory CreateAllianceCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateAllianceCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateAllianceCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: CreateAllianceCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'tag')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAllianceCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAllianceCmd copyWith(void Function(CreateAllianceCmd) updates) =>
      super.copyWith((message) => updates(message as CreateAllianceCmd))
          as CreateAllianceCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateAllianceCmd() / CreateAllianceCmd.new instead')
  static CreateAllianceCmd create() => CreateAllianceCmd._();
  static $pb.GeneratedMessage $_createMessage() => CreateAllianceCmd._();
  @$core.override
  CreateAllianceCmd createEmptyInstance() => CreateAllianceCmd._();
  @$core.pragma('dart2js:noInline')
  static CreateAllianceCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateAllianceCmd>(
          CreateAllianceCmd.$_createMessage);
  static CreateAllianceCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tag => $_getSZ(1);
  @$pb.TagNumber(2)
  set tag($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTag() => $_has(1);
  @$pb.TagNumber(2)
  void clearTag() => $_clearField(2);
}

class AllianceInviteCmd extends $pb.GeneratedMessage {
  factory AllianceInviteCmd({
    $core.String? playerId,
  }) {
    final result = AllianceInviteCmd._();
    if (playerId != null) result.playerId = playerId;
    return result;
  }

  AllianceInviteCmd._();

  factory AllianceInviteCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AllianceInviteCmd()..mergeFromBuffer(data, registry);
  factory AllianceInviteCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AllianceInviteCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AllianceInviteCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: AllianceInviteCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'playerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllianceInviteCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllianceInviteCmd copyWith(void Function(AllianceInviteCmd) updates) =>
      super.copyWith((message) => updates(message as AllianceInviteCmd))
          as AllianceInviteCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AllianceInviteCmd() / AllianceInviteCmd.new instead')
  static AllianceInviteCmd create() => AllianceInviteCmd._();
  static $pb.GeneratedMessage $_createMessage() => AllianceInviteCmd._();
  @$core.override
  AllianceInviteCmd createEmptyInstance() => AllianceInviteCmd._();
  @$core.pragma('dart2js:noInline')
  static AllianceInviteCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AllianceInviteCmd>(
          AllianceInviteCmd.$_createMessage);
  static AllianceInviteCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get playerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set playerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlayerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlayerId() => $_clearField(1);
}

class AllianceAcceptCmd extends $pb.GeneratedMessage {
  factory AllianceAcceptCmd({
    $core.String? allianceId,
  }) {
    final result = AllianceAcceptCmd._();
    if (allianceId != null) result.allianceId = allianceId;
    return result;
  }

  AllianceAcceptCmd._();

  factory AllianceAcceptCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AllianceAcceptCmd()..mergeFromBuffer(data, registry);
  factory AllianceAcceptCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AllianceAcceptCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AllianceAcceptCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: AllianceAcceptCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'allianceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllianceAcceptCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllianceAcceptCmd copyWith(void Function(AllianceAcceptCmd) updates) =>
      super.copyWith((message) => updates(message as AllianceAcceptCmd))
          as AllianceAcceptCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AllianceAcceptCmd() / AllianceAcceptCmd.new instead')
  static AllianceAcceptCmd create() => AllianceAcceptCmd._();
  static $pb.GeneratedMessage $_createMessage() => AllianceAcceptCmd._();
  @$core.override
  AllianceAcceptCmd createEmptyInstance() => AllianceAcceptCmd._();
  @$core.pragma('dart2js:noInline')
  static AllianceAcceptCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AllianceAcceptCmd>(
          AllianceAcceptCmd.$_createMessage);
  static AllianceAcceptCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get allianceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set allianceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAllianceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAllianceId() => $_clearField(1);
}

class AllianceJoinCmd extends $pb.GeneratedMessage {
  factory AllianceJoinCmd({
    $core.String? allianceId,
  }) {
    final result = AllianceJoinCmd._();
    if (allianceId != null) result.allianceId = allianceId;
    return result;
  }

  AllianceJoinCmd._();

  factory AllianceJoinCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AllianceJoinCmd()..mergeFromBuffer(data, registry);
  factory AllianceJoinCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AllianceJoinCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AllianceJoinCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: AllianceJoinCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'allianceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllianceJoinCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllianceJoinCmd copyWith(void Function(AllianceJoinCmd) updates) =>
      super.copyWith((message) => updates(message as AllianceJoinCmd))
          as AllianceJoinCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AllianceJoinCmd() / AllianceJoinCmd.new instead')
  static AllianceJoinCmd create() => AllianceJoinCmd._();
  static $pb.GeneratedMessage $_createMessage() => AllianceJoinCmd._();
  @$core.override
  AllianceJoinCmd createEmptyInstance() => AllianceJoinCmd._();
  @$core.pragma('dart2js:noInline')
  static AllianceJoinCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AllianceJoinCmd>(
          AllianceJoinCmd.$_createMessage);
  static AllianceJoinCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get allianceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set allianceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAllianceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAllianceId() => $_clearField(1);
}

class AllianceLeaveCmd extends $pb.GeneratedMessage {
  factory AllianceLeaveCmd() => AllianceLeaveCmd._();

  AllianceLeaveCmd._();

  factory AllianceLeaveCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AllianceLeaveCmd()..mergeFromBuffer(data, registry);
  factory AllianceLeaveCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AllianceLeaveCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AllianceLeaveCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: AllianceLeaveCmd.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllianceLeaveCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllianceLeaveCmd copyWith(void Function(AllianceLeaveCmd) updates) =>
      super.copyWith((message) => updates(message as AllianceLeaveCmd))
          as AllianceLeaveCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AllianceLeaveCmd() / AllianceLeaveCmd.new instead')
  static AllianceLeaveCmd create() => AllianceLeaveCmd._();
  static $pb.GeneratedMessage $_createMessage() => AllianceLeaveCmd._();
  @$core.override
  AllianceLeaveCmd createEmptyInstance() => AllianceLeaveCmd._();
  @$core.pragma('dart2js:noInline')
  static AllianceLeaveCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AllianceLeaveCmd>(
          AllianceLeaveCmd.$_createMessage);
  static AllianceLeaveCmd? _defaultInstance;
}

class AllianceKickCmd extends $pb.GeneratedMessage {
  factory AllianceKickCmd({
    $core.String? playerId,
  }) {
    final result = AllianceKickCmd._();
    if (playerId != null) result.playerId = playerId;
    return result;
  }

  AllianceKickCmd._();

  factory AllianceKickCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AllianceKickCmd()..mergeFromBuffer(data, registry);
  factory AllianceKickCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AllianceKickCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AllianceKickCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: AllianceKickCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'playerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllianceKickCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllianceKickCmd copyWith(void Function(AllianceKickCmd) updates) =>
      super.copyWith((message) => updates(message as AllianceKickCmd))
          as AllianceKickCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AllianceKickCmd() / AllianceKickCmd.new instead')
  static AllianceKickCmd create() => AllianceKickCmd._();
  static $pb.GeneratedMessage $_createMessage() => AllianceKickCmd._();
  @$core.override
  AllianceKickCmd createEmptyInstance() => AllianceKickCmd._();
  @$core.pragma('dart2js:noInline')
  static AllianceKickCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AllianceKickCmd>(
          AllianceKickCmd.$_createMessage);
  static AllianceKickCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get playerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set playerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlayerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlayerId() => $_clearField(1);
}

class AllianceHelpCmd extends $pb.GeneratedMessage {
  factory AllianceHelpCmd({
    $core.String? targetPlayerId,
  }) {
    final result = AllianceHelpCmd._();
    if (targetPlayerId != null) result.targetPlayerId = targetPlayerId;
    return result;
  }

  AllianceHelpCmd._();

  factory AllianceHelpCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AllianceHelpCmd()..mergeFromBuffer(data, registry);
  factory AllianceHelpCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AllianceHelpCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AllianceHelpCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: AllianceHelpCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'targetPlayerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllianceHelpCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllianceHelpCmd copyWith(void Function(AllianceHelpCmd) updates) =>
      super.copyWith((message) => updates(message as AllianceHelpCmd))
          as AllianceHelpCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AllianceHelpCmd() / AllianceHelpCmd.new instead')
  static AllianceHelpCmd create() => AllianceHelpCmd._();
  static $pb.GeneratedMessage $_createMessage() => AllianceHelpCmd._();
  @$core.override
  AllianceHelpCmd createEmptyInstance() => AllianceHelpCmd._();
  @$core.pragma('dart2js:noInline')
  static AllianceHelpCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AllianceHelpCmd>(
          AllianceHelpCmd.$_createMessage);
  static AllianceHelpCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get targetPlayerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set targetPlayerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetPlayerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetPlayerId() => $_clearField(1);
}

class RallyCreateCmd extends $pb.GeneratedMessage {
  factory RallyCreateCmd({
    $core.String? cityId,
    Vec2? targetPos,
    $fixnum.Int64? startAtUnixMs,
  }) {
    final result = RallyCreateCmd._();
    if (cityId != null) result.cityId = cityId;
    if (targetPos != null) result.targetPos = targetPos;
    if (startAtUnixMs != null) result.startAtUnixMs = startAtUnixMs;
    return result;
  }

  RallyCreateCmd._();

  factory RallyCreateCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RallyCreateCmd()..mergeFromBuffer(data, registry);
  factory RallyCreateCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RallyCreateCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RallyCreateCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: RallyCreateCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cityId')
    ..aOM<Vec2>(2, _omitFieldNames ? '' : 'targetPos',
        subBuilder: Vec2.$_createMessage)
    ..aInt64(3, _omitFieldNames ? '' : 'startAtUnixMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RallyCreateCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RallyCreateCmd copyWith(void Function(RallyCreateCmd) updates) =>
      super.copyWith((message) => updates(message as RallyCreateCmd))
          as RallyCreateCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RallyCreateCmd() / RallyCreateCmd.new instead')
  static RallyCreateCmd create() => RallyCreateCmd._();
  static $pb.GeneratedMessage $_createMessage() => RallyCreateCmd._();
  @$core.override
  RallyCreateCmd createEmptyInstance() => RallyCreateCmd._();
  @$core.pragma('dart2js:noInline')
  static RallyCreateCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RallyCreateCmd>(
          RallyCreateCmd.$_createMessage);
  static RallyCreateCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  Vec2 get targetPos => $_getN(1);
  @$pb.TagNumber(2)
  set targetPos(Vec2 value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetPos() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetPos() => $_clearField(2);
  @$pb.TagNumber(2)
  Vec2 ensureTargetPos() => $_ensure(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get startAtUnixMs => $_getI64(2);
  @$pb.TagNumber(3)
  set startAtUnixMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStartAtUnixMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartAtUnixMs() => $_clearField(3);
}

class RallyJoinCmd extends $pb.GeneratedMessage {
  factory RallyJoinCmd({
    $core.String? rallyId,
    $core.Iterable<TroopSend>? troops,
  }) {
    final result = RallyJoinCmd._();
    if (rallyId != null) result.rallyId = rallyId;
    if (troops != null) result.troops.addAll(troops);
    return result;
  }

  RallyJoinCmd._();

  factory RallyJoinCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RallyJoinCmd()..mergeFromBuffer(data, registry);
  factory RallyJoinCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RallyJoinCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RallyJoinCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: RallyJoinCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'rallyId')
    ..pPM<TroopSend>(2, _omitFieldNames ? '' : 'troops',
        subBuilder: TroopSend.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RallyJoinCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RallyJoinCmd copyWith(void Function(RallyJoinCmd) updates) =>
      super.copyWith((message) => updates(message as RallyJoinCmd))
          as RallyJoinCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RallyJoinCmd() / RallyJoinCmd.new instead')
  static RallyJoinCmd create() => RallyJoinCmd._();
  static $pb.GeneratedMessage $_createMessage() => RallyJoinCmd._();
  @$core.override
  RallyJoinCmd createEmptyInstance() => RallyJoinCmd._();
  @$core.pragma('dart2js:noInline')
  static RallyJoinCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RallyJoinCmd>(
          RallyJoinCmd.$_createMessage);
  static RallyJoinCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get rallyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set rallyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRallyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRallyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<TroopSend> get troops => $_getList(1);
}

class RallyCancelCmd extends $pb.GeneratedMessage {
  factory RallyCancelCmd({
    $core.String? rallyId,
  }) {
    final result = RallyCancelCmd._();
    if (rallyId != null) result.rallyId = rallyId;
    return result;
  }

  RallyCancelCmd._();

  factory RallyCancelCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RallyCancelCmd()..mergeFromBuffer(data, registry);
  factory RallyCancelCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RallyCancelCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RallyCancelCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: RallyCancelCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'rallyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RallyCancelCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RallyCancelCmd copyWith(void Function(RallyCancelCmd) updates) =>
      super.copyWith((message) => updates(message as RallyCancelCmd))
          as RallyCancelCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RallyCancelCmd() / RallyCancelCmd.new instead')
  static RallyCancelCmd create() => RallyCancelCmd._();
  static $pb.GeneratedMessage $_createMessage() => RallyCancelCmd._();
  @$core.override
  RallyCancelCmd createEmptyInstance() => RallyCancelCmd._();
  @$core.pragma('dart2js:noInline')
  static RallyCancelCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RallyCancelCmd>(
          RallyCancelCmd.$_createMessage);
  static RallyCancelCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get rallyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set rallyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRallyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRallyId() => $_clearField(1);
}

class ChatCmd extends $pb.GeneratedMessage {
  factory ChatCmd({
    $core.String? scope,
    $core.String? text,
    $core.String? targetId,
  }) {
    final result = ChatCmd._();
    if (scope != null) result.scope = scope;
    if (text != null) result.text = text;
    if (targetId != null) result.targetId = targetId;
    return result;
  }

  ChatCmd._();

  factory ChatCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatCmd()..mergeFromBuffer(data, registry);
  factory ChatCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: ChatCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'scope')
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..aOS(3, _omitFieldNames ? '' : 'targetId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatCmd copyWith(void Function(ChatCmd) updates) =>
      super.copyWith((message) => updates(message as ChatCmd)) as ChatCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChatCmd() / ChatCmd.new instead')
  static ChatCmd create() => ChatCmd._();
  static $pb.GeneratedMessage $_createMessage() => ChatCmd._();
  @$core.override
  ChatCmd createEmptyInstance() => ChatCmd._();
  @$core.pragma('dart2js:noInline')
  static ChatCmd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatCmd>(ChatCmd.$_createMessage);
  static ChatCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get scope => $_getSZ(0);
  @$pb.TagNumber(1)
  set scope($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScope() => $_has(0);
  @$pb.TagNumber(1)
  void clearScope() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get targetId => $_getSZ(2);
  @$pb.TagNumber(3)
  set targetId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetId() => $_clearField(3);
}

class SwitchCapitalCmd extends $pb.GeneratedMessage {
  factory SwitchCapitalCmd({
    $core.String? cityId,
  }) {
    final result = SwitchCapitalCmd._();
    if (cityId != null) result.cityId = cityId;
    return result;
  }

  SwitchCapitalCmd._();

  factory SwitchCapitalCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SwitchCapitalCmd()..mergeFromBuffer(data, registry);
  factory SwitchCapitalCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SwitchCapitalCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SwitchCapitalCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: SwitchCapitalCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cityId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SwitchCapitalCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SwitchCapitalCmd copyWith(void Function(SwitchCapitalCmd) updates) =>
      super.copyWith((message) => updates(message as SwitchCapitalCmd))
          as SwitchCapitalCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SwitchCapitalCmd() / SwitchCapitalCmd.new instead')
  static SwitchCapitalCmd create() => SwitchCapitalCmd._();
  static $pb.GeneratedMessage $_createMessage() => SwitchCapitalCmd._();
  @$core.override
  SwitchCapitalCmd createEmptyInstance() => SwitchCapitalCmd._();
  @$core.pragma('dart2js:noInline')
  static SwitchCapitalCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SwitchCapitalCmd>(
          SwitchCapitalCmd.$_createMessage);
  static SwitchCapitalCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityId() => $_clearField(1);
}

class RecruitHeroCmd extends $pb.GeneratedMessage {
  factory RecruitHeroCmd({
    $core.String? hero,
  }) {
    final result = RecruitHeroCmd._();
    if (hero != null) result.hero = hero;
    return result;
  }

  RecruitHeroCmd._();

  factory RecruitHeroCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecruitHeroCmd()..mergeFromBuffer(data, registry);
  factory RecruitHeroCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecruitHeroCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecruitHeroCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: RecruitHeroCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'hero')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecruitHeroCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecruitHeroCmd copyWith(void Function(RecruitHeroCmd) updates) =>
      super.copyWith((message) => updates(message as RecruitHeroCmd))
          as RecruitHeroCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RecruitHeroCmd() / RecruitHeroCmd.new instead')
  static RecruitHeroCmd create() => RecruitHeroCmd._();
  static $pb.GeneratedMessage $_createMessage() => RecruitHeroCmd._();
  @$core.override
  RecruitHeroCmd createEmptyInstance() => RecruitHeroCmd._();
  @$core.pragma('dart2js:noInline')
  static RecruitHeroCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RecruitHeroCmd>(
          RecruitHeroCmd.$_createMessage);
  static RecruitHeroCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hero => $_getSZ(0);
  @$pb.TagNumber(1)
  set hero($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHero() => $_has(0);
  @$pb.TagNumber(1)
  void clearHero() => $_clearField(1);
}

class DemolishBuildingCmd extends $pb.GeneratedMessage {
  factory DemolishBuildingCmd({
    $core.String? cityId,
    $core.String? building,
  }) {
    final result = DemolishBuildingCmd._();
    if (cityId != null) result.cityId = cityId;
    if (building != null) result.building = building;
    return result;
  }

  DemolishBuildingCmd._();

  factory DemolishBuildingCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DemolishBuildingCmd()..mergeFromBuffer(data, registry);
  factory DemolishBuildingCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DemolishBuildingCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DemolishBuildingCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: DemolishBuildingCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'cityId')
    ..aOS(2, _omitFieldNames ? '' : 'building')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DemolishBuildingCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DemolishBuildingCmd copyWith(void Function(DemolishBuildingCmd) updates) =>
      super.copyWith((message) => updates(message as DemolishBuildingCmd))
          as DemolishBuildingCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use DemolishBuildingCmd() / DemolishBuildingCmd.new instead')
  static DemolishBuildingCmd create() => DemolishBuildingCmd._();
  static $pb.GeneratedMessage $_createMessage() => DemolishBuildingCmd._();
  @$core.override
  DemolishBuildingCmd createEmptyInstance() => DemolishBuildingCmd._();
  @$core.pragma('dart2js:noInline')
  static DemolishBuildingCmd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DemolishBuildingCmd>(
          DemolishBuildingCmd.$_createMessage);
  static DemolishBuildingCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get building => $_getSZ(1);
  @$pb.TagNumber(2)
  set building($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBuilding() => $_has(1);
  @$pb.TagNumber(2)
  void clearBuilding() => $_clearField(2);
}

class MarketBuyCmd extends $pb.GeneratedMessage {
  factory MarketBuyCmd({
    $core.String? item,
    $core.int? qty,
  }) {
    final result = MarketBuyCmd._();
    if (item != null) result.item = item;
    if (qty != null) result.qty = qty;
    return result;
  }

  MarketBuyCmd._();

  factory MarketBuyCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketBuyCmd()..mergeFromBuffer(data, registry);
  factory MarketBuyCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketBuyCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarketBuyCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: MarketBuyCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'item')
    ..aI(2, _omitFieldNames ? '' : 'qty', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketBuyCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketBuyCmd copyWith(void Function(MarketBuyCmd) updates) =>
      super.copyWith((message) => updates(message as MarketBuyCmd))
          as MarketBuyCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketBuyCmd() / MarketBuyCmd.new instead')
  static MarketBuyCmd create() => MarketBuyCmd._();
  static $pb.GeneratedMessage $_createMessage() => MarketBuyCmd._();
  @$core.override
  MarketBuyCmd createEmptyInstance() => MarketBuyCmd._();
  @$core.pragma('dart2js:noInline')
  static MarketBuyCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketBuyCmd>(
          MarketBuyCmd.$_createMessage);
  static MarketBuyCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get item => $_getSZ(0);
  @$pb.TagNumber(1)
  set item($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasItem() => $_has(0);
  @$pb.TagNumber(1)
  void clearItem() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get qty => $_getIZ(1);
  @$pb.TagNumber(2)
  set qty($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQty() => $_has(1);
  @$pb.TagNumber(2)
  void clearQty() => $_clearField(2);
}

class MarketSellCmd extends $pb.GeneratedMessage {
  factory MarketSellCmd({
    $core.String? item,
    $core.int? qty,
  }) {
    final result = MarketSellCmd._();
    if (item != null) result.item = item;
    if (qty != null) result.qty = qty;
    return result;
  }

  MarketSellCmd._();

  factory MarketSellCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketSellCmd()..mergeFromBuffer(data, registry);
  factory MarketSellCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarketSellCmd()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarketSellCmd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: MarketSellCmd.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'item')
    ..aI(2, _omitFieldNames ? '' : 'qty', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketSellCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketSellCmd copyWith(void Function(MarketSellCmd) updates) =>
      super.copyWith((message) => updates(message as MarketSellCmd))
          as MarketSellCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarketSellCmd() / MarketSellCmd.new instead')
  static MarketSellCmd create() => MarketSellCmd._();
  static $pb.GeneratedMessage $_createMessage() => MarketSellCmd._();
  @$core.override
  MarketSellCmd createEmptyInstance() => MarketSellCmd._();
  @$core.pragma('dart2js:noInline')
  static MarketSellCmd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarketSellCmd>(
          MarketSellCmd.$_createMessage);
  static MarketSellCmd? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get item => $_getSZ(0);
  @$pb.TagNumber(1)
  set item($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasItem() => $_has(0);
  @$pb.TagNumber(1)
  void clearItem() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get qty => $_getIZ(1);
  @$pb.TagNumber(2)
  set qty($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQty() => $_has(1);
  @$pb.TagNumber(2)
  void clearQty() => $_clearField(2);
}

class TroopSend extends $pb.GeneratedMessage {
  factory TroopSend({
    $core.String? unit,
    $core.int? tier,
    $core.int? count,
  }) {
    final result = TroopSend._();
    if (unit != null) result.unit = unit;
    if (tier != null) result.tier = tier;
    if (count != null) result.count = count;
    return result;
  }

  TroopSend._();

  factory TroopSend.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TroopSend()..mergeFromBuffer(data, registry);
  factory TroopSend.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TroopSend()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TroopSend',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: TroopSend.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'unit')
    ..aI(2, _omitFieldNames ? '' : 'tier', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'count', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TroopSend clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TroopSend copyWith(void Function(TroopSend) updates) =>
      super.copyWith((message) => updates(message as TroopSend)) as TroopSend;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TroopSend() / TroopSend.new instead')
  static TroopSend create() => TroopSend._();
  static $pb.GeneratedMessage $_createMessage() => TroopSend._();
  @$core.override
  TroopSend createEmptyInstance() => TroopSend._();
  @$core.pragma('dart2js:noInline')
  static TroopSend getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TroopSend>(TroopSend.$_createMessage);
  static TroopSend? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get unit => $_getSZ(0);
  @$pb.TagNumber(1)
  set unit($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUnit() => $_has(0);
  @$pb.TagNumber(1)
  void clearUnit() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get tier => $_getIZ(1);
  @$pb.TagNumber(2)
  set tier($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTier() => $_has(1);
  @$pb.TagNumber(2)
  void clearTier() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get count => $_getIZ(2);
  @$pb.TagNumber(3)
  set count($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCount() => $_clearField(3);
}

enum WsEnvelope_Body {
  hello,
  command,
  commandResult,
  delta,
  snapshot,
  heartbeat,
  error,
  subscription,
  notSet
}

/// ---------------------- gateway <-> client ------------------------
class WsEnvelope extends $pb.GeneratedMessage {
  factory WsEnvelope({
    $fixnum.Int64? seq,
    WsHello? hello,
    SubmitCommandRequest? command,
    CommandResult? commandResult,
    DeltaEvent? delta,
    Snapshot? snapshot,
    Heartbeat? heartbeat,
    ErrorMessage? error,
    SubscriptionUpdate? subscription,
  }) {
    final result = WsEnvelope._();
    if (seq != null) result.seq = seq;
    if (hello != null) result.hello = hello;
    if (command != null) result.command = command;
    if (commandResult != null) result.commandResult = commandResult;
    if (delta != null) result.delta = delta;
    if (snapshot != null) result.snapshot = snapshot;
    if (heartbeat != null) result.heartbeat = heartbeat;
    if (error != null) result.error = error;
    if (subscription != null) result.subscription = subscription;
    return result;
  }

  WsEnvelope._();

  factory WsEnvelope.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WsEnvelope()..mergeFromBuffer(data, registry);
  factory WsEnvelope.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WsEnvelope()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, WsEnvelope_Body> _WsEnvelope_BodyByTag = {
    2: WsEnvelope_Body.hello,
    3: WsEnvelope_Body.command,
    4: WsEnvelope_Body.commandResult,
    5: WsEnvelope_Body.delta,
    6: WsEnvelope_Body.snapshot,
    7: WsEnvelope_Body.heartbeat,
    8: WsEnvelope_Body.error,
    9: WsEnvelope_Body.subscription,
    0: WsEnvelope_Body.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WsEnvelope',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: WsEnvelope.$_createMessage)
    ..oo(0, [2, 3, 4, 5, 6, 7, 8, 9])
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'seq', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<WsHello>(2, _omitFieldNames ? '' : 'hello',
        subBuilder: WsHello.$_createMessage)
    ..aOM<SubmitCommandRequest>(3, _omitFieldNames ? '' : 'command',
        subBuilder: SubmitCommandRequest.$_createMessage)
    ..aOM<CommandResult>(4, _omitFieldNames ? '' : 'commandResult',
        subBuilder: CommandResult.$_createMessage)
    ..aOM<DeltaEvent>(5, _omitFieldNames ? '' : 'delta',
        subBuilder: DeltaEvent.$_createMessage)
    ..aOM<Snapshot>(6, _omitFieldNames ? '' : 'snapshot',
        subBuilder: Snapshot.$_createMessage)
    ..aOM<Heartbeat>(7, _omitFieldNames ? '' : 'heartbeat',
        subBuilder: Heartbeat.$_createMessage)
    ..aOM<ErrorMessage>(8, _omitFieldNames ? '' : 'error',
        subBuilder: ErrorMessage.$_createMessage)
    ..aOM<SubscriptionUpdate>(9, _omitFieldNames ? '' : 'subscription',
        subBuilder: SubscriptionUpdate.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WsEnvelope clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WsEnvelope copyWith(void Function(WsEnvelope) updates) =>
      super.copyWith((message) => updates(message as WsEnvelope)) as WsEnvelope;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WsEnvelope() / WsEnvelope.new instead')
  static WsEnvelope create() => WsEnvelope._();
  static $pb.GeneratedMessage $_createMessage() => WsEnvelope._();
  @$core.override
  WsEnvelope createEmptyInstance() => WsEnvelope._();
  @$core.pragma('dart2js:noInline')
  static WsEnvelope getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WsEnvelope>(WsEnvelope.$_createMessage);
  static WsEnvelope? _defaultInstance;

  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  WsEnvelope_Body whichBody() => _WsEnvelope_BodyByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  void clearBody() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $fixnum.Int64 get seq => $_getI64(0);
  @$pb.TagNumber(1)
  set seq($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeq() => $_clearField(1);

  @$pb.TagNumber(2)
  WsHello get hello => $_getN(1);
  @$pb.TagNumber(2)
  set hello(WsHello value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasHello() => $_has(1);
  @$pb.TagNumber(2)
  void clearHello() => $_clearField(2);
  @$pb.TagNumber(2)
  WsHello ensureHello() => $_ensure(1);

  @$pb.TagNumber(3)
  SubmitCommandRequest get command => $_getN(2);
  @$pb.TagNumber(3)
  set command(SubmitCommandRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCommand() => $_has(2);
  @$pb.TagNumber(3)
  void clearCommand() => $_clearField(3);
  @$pb.TagNumber(3)
  SubmitCommandRequest ensureCommand() => $_ensure(2);

  @$pb.TagNumber(4)
  CommandResult get commandResult => $_getN(3);
  @$pb.TagNumber(4)
  set commandResult(CommandResult value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCommandResult() => $_has(3);
  @$pb.TagNumber(4)
  void clearCommandResult() => $_clearField(4);
  @$pb.TagNumber(4)
  CommandResult ensureCommandResult() => $_ensure(3);

  @$pb.TagNumber(5)
  DeltaEvent get delta => $_getN(4);
  @$pb.TagNumber(5)
  set delta(DeltaEvent value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDelta() => $_has(4);
  @$pb.TagNumber(5)
  void clearDelta() => $_clearField(5);
  @$pb.TagNumber(5)
  DeltaEvent ensureDelta() => $_ensure(4);

  @$pb.TagNumber(6)
  Snapshot get snapshot => $_getN(5);
  @$pb.TagNumber(6)
  set snapshot(Snapshot value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSnapshot() => $_has(5);
  @$pb.TagNumber(6)
  void clearSnapshot() => $_clearField(6);
  @$pb.TagNumber(6)
  Snapshot ensureSnapshot() => $_ensure(5);

  @$pb.TagNumber(7)
  Heartbeat get heartbeat => $_getN(6);
  @$pb.TagNumber(7)
  set heartbeat(Heartbeat value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasHeartbeat() => $_has(6);
  @$pb.TagNumber(7)
  void clearHeartbeat() => $_clearField(7);
  @$pb.TagNumber(7)
  Heartbeat ensureHeartbeat() => $_ensure(6);

  @$pb.TagNumber(8)
  ErrorMessage get error => $_getN(7);
  @$pb.TagNumber(8)
  set error(ErrorMessage value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasError() => $_has(7);
  @$pb.TagNumber(8)
  void clearError() => $_clearField(8);
  @$pb.TagNumber(8)
  ErrorMessage ensureError() => $_ensure(7);

  @$pb.TagNumber(9)
  SubscriptionUpdate get subscription => $_getN(8);
  @$pb.TagNumber(9)
  set subscription(SubscriptionUpdate value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasSubscription() => $_has(8);
  @$pb.TagNumber(9)
  void clearSubscription() => $_clearField(9);
  @$pb.TagNumber(9)
  SubscriptionUpdate ensureSubscription() => $_ensure(8);
}

class WsHello extends $pb.GeneratedMessage {
  factory WsHello({
    $core.String? token,
    $core.String? realmId,
    $core.Iterable<Vec2>? chunks,
    $core.String? cursor,
  }) {
    final result = WsHello._();
    if (token != null) result.token = token;
    if (realmId != null) result.realmId = realmId;
    if (chunks != null) result.chunks.addAll(chunks);
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  WsHello._();

  factory WsHello.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WsHello()..mergeFromBuffer(data, registry);
  factory WsHello.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WsHello()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WsHello',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: WsHello.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..aOS(2, _omitFieldNames ? '' : 'realmId')
    ..pPM<Vec2>(3, _omitFieldNames ? '' : 'chunks',
        subBuilder: Vec2.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WsHello clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WsHello copyWith(void Function(WsHello) updates) =>
      super.copyWith((message) => updates(message as WsHello)) as WsHello;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WsHello() / WsHello.new instead')
  static WsHello create() => WsHello._();
  static $pb.GeneratedMessage $_createMessage() => WsHello._();
  @$core.override
  WsHello createEmptyInstance() => WsHello._();
  @$core.pragma('dart2js:noInline')
  static WsHello getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WsHello>(WsHello.$_createMessage);
  static WsHello? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get realmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set realmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRealmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRealmId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<Vec2> get chunks => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get cursor => $_getSZ(3);
  @$pb.TagNumber(4)
  set cursor($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearCursor() => $_clearField(4);
}

class Heartbeat extends $pb.GeneratedMessage {
  factory Heartbeat({
    $fixnum.Int64? clientTimeUnixMs,
  }) {
    final result = Heartbeat._();
    if (clientTimeUnixMs != null) result.clientTimeUnixMs = clientTimeUnixMs;
    return result;
  }

  Heartbeat._();

  factory Heartbeat.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Heartbeat()..mergeFromBuffer(data, registry);
  factory Heartbeat.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Heartbeat()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Heartbeat',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: Heartbeat.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'clientTimeUnixMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Heartbeat clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Heartbeat copyWith(void Function(Heartbeat) updates) =>
      super.copyWith((message) => updates(message as Heartbeat)) as Heartbeat;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Heartbeat() / Heartbeat.new instead')
  static Heartbeat create() => Heartbeat._();
  static $pb.GeneratedMessage $_createMessage() => Heartbeat._();
  @$core.override
  Heartbeat createEmptyInstance() => Heartbeat._();
  @$core.pragma('dart2js:noInline')
  static Heartbeat getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Heartbeat>(Heartbeat.$_createMessage);
  static Heartbeat? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get clientTimeUnixMs => $_getI64(0);
  @$pb.TagNumber(1)
  set clientTimeUnixMs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientTimeUnixMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientTimeUnixMs() => $_clearField(1);
}

class ErrorMessage extends $pb.GeneratedMessage {
  factory ErrorMessage({
    ErrorCode? code,
    $core.String? message,
  }) {
    final result = ErrorMessage._();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  ErrorMessage._();

  factory ErrorMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ErrorMessage()..mergeFromBuffer(data, registry);
  factory ErrorMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ErrorMessage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ErrorMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: ErrorMessage.$_createMessage)
    ..aE<ErrorCode>(1, _omitFieldNames ? '' : 'code',
        enumValues: ErrorCode.values)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ErrorMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ErrorMessage copyWith(void Function(ErrorMessage) updates) =>
      super.copyWith((message) => updates(message as ErrorMessage))
          as ErrorMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ErrorMessage() / ErrorMessage.new instead')
  static ErrorMessage create() => ErrorMessage._();
  static $pb.GeneratedMessage $_createMessage() => ErrorMessage._();
  @$core.override
  ErrorMessage createEmptyInstance() => ErrorMessage._();
  @$core.pragma('dart2js:noInline')
  static ErrorMessage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ErrorMessage>(
          ErrorMessage.$_createMessage);
  static ErrorMessage? _defaultInstance;

  @$pb.TagNumber(1)
  ErrorCode get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(ErrorCode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class SubscriptionUpdate extends $pb.GeneratedMessage {
  factory SubscriptionUpdate({
    $core.Iterable<Vec2>? chunks,
    $core.bool? allPrivate,
    $core.String? cursor,
  }) {
    final result = SubscriptionUpdate._();
    if (chunks != null) result.chunks.addAll(chunks);
    if (allPrivate != null) result.allPrivate = allPrivate;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  SubscriptionUpdate._();

  factory SubscriptionUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscriptionUpdate()..mergeFromBuffer(data, registry);
  factory SubscriptionUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscriptionUpdate()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscriptionUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: SubscriptionUpdate.$_createMessage)
    ..pPM<Vec2>(1, _omitFieldNames ? '' : 'chunks',
        subBuilder: Vec2.$_createMessage)
    ..aOB(2, _omitFieldNames ? '' : 'allPrivate')
    ..aOS(3, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscriptionUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscriptionUpdate copyWith(void Function(SubscriptionUpdate) updates) =>
      super.copyWith((message) => updates(message as SubscriptionUpdate))
          as SubscriptionUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubscriptionUpdate() / SubscriptionUpdate.new instead')
  static SubscriptionUpdate create() => SubscriptionUpdate._();
  static $pb.GeneratedMessage $_createMessage() => SubscriptionUpdate._();
  @$core.override
  SubscriptionUpdate createEmptyInstance() => SubscriptionUpdate._();
  @$core.pragma('dart2js:noInline')
  static SubscriptionUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscriptionUpdate>(
          SubscriptionUpdate.$_createMessage);
  static SubscriptionUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Vec2> get chunks => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get allPrivate => $_getBF(1);
  @$pb.TagNumber(2)
  set allPrivate($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAllPrivate() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllPrivate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get cursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set cursor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => $_clearField(3);
}

class DeltaEvent extends $pb.GeneratedMessage {
  factory DeltaEvent({
    $core.String? eventId,
    $core.String? realmId,
    $core.String? eventType,
    Vec2? pos,
    $core.String? ownerPlayerId,
    $core.bool? private,
    $core.Iterable<$core.String>? visiblePlayers,
    $fixnum.Int64? serverTimeUnixMs,
    $core.List<$core.int>? payloadJson,
    $core.String? cursor,
    $core.bool? hasPos_12,
  }) {
    final result = DeltaEvent._();
    if (eventId != null) result.eventId = eventId;
    if (realmId != null) result.realmId = realmId;
    if (eventType != null) result.eventType = eventType;
    if (pos != null) result.pos = pos;
    if (ownerPlayerId != null) result.ownerPlayerId = ownerPlayerId;
    if (private != null) result.private = private;
    if (visiblePlayers != null) result.visiblePlayers.addAll(visiblePlayers);
    if (serverTimeUnixMs != null) result.serverTimeUnixMs = serverTimeUnixMs;
    if (payloadJson != null) result.payloadJson = payloadJson;
    if (cursor != null) result.cursor = cursor;
    if (hasPos_12 != null) result.hasPos_12 = hasPos_12;
    return result;
  }

  DeltaEvent._();

  factory DeltaEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeltaEvent()..mergeFromBuffer(data, registry);
  factory DeltaEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeltaEvent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeltaEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: DeltaEvent.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'eventId')
    ..aOS(2, _omitFieldNames ? '' : 'realmId')
    ..aOS(3, _omitFieldNames ? '' : 'eventType')
    ..aOM<Vec2>(4, _omitFieldNames ? '' : 'pos',
        subBuilder: Vec2.$_createMessage)
    ..aOS(5, _omitFieldNames ? '' : 'ownerPlayerId')
    ..aOB(6, _omitFieldNames ? '' : 'private')
    ..pPS(7, _omitFieldNames ? '' : 'visiblePlayers')
    ..aInt64(8, _omitFieldNames ? '' : 'serverTimeUnixMs')
    ..a<$core.List<$core.int>>(
        9, _omitFieldNames ? '' : 'payloadJson', $pb.PbFieldType.OY)
    ..aOS(10, _omitFieldNames ? '' : 'cursor')
    ..aOB(12, _omitFieldNames ? '' : 'hasPos')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeltaEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeltaEvent copyWith(void Function(DeltaEvent) updates) =>
      super.copyWith((message) => updates(message as DeltaEvent)) as DeltaEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeltaEvent() / DeltaEvent.new instead')
  static DeltaEvent create() => DeltaEvent._();
  static $pb.GeneratedMessage $_createMessage() => DeltaEvent._();
  @$core.override
  DeltaEvent createEmptyInstance() => DeltaEvent._();
  @$core.pragma('dart2js:noInline')
  static DeltaEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeltaEvent>(DeltaEvent.$_createMessage);
  static DeltaEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventId => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get realmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set realmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRealmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRealmId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get eventType => $_getSZ(2);
  @$pb.TagNumber(3)
  set eventType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEventType() => $_has(2);
  @$pb.TagNumber(3)
  void clearEventType() => $_clearField(3);

  @$pb.TagNumber(4)
  Vec2 get pos => $_getN(3);
  @$pb.TagNumber(4)
  set pos(Vec2 value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPos() => $_has(3);
  @$pb.TagNumber(4)
  void clearPos() => $_clearField(4);
  @$pb.TagNumber(4)
  Vec2 ensurePos() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get ownerPlayerId => $_getSZ(4);
  @$pb.TagNumber(5)
  set ownerPlayerId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOwnerPlayerId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOwnerPlayerId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get private => $_getBF(5);
  @$pb.TagNumber(6)
  set private($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPrivate() => $_has(5);
  @$pb.TagNumber(6)
  void clearPrivate() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get visiblePlayers => $_getList(6);

  @$pb.TagNumber(8)
  $fixnum.Int64 get serverTimeUnixMs => $_getI64(7);
  @$pb.TagNumber(8)
  set serverTimeUnixMs($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasServerTimeUnixMs() => $_has(7);
  @$pb.TagNumber(8)
  void clearServerTimeUnixMs() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.List<$core.int> get payloadJson => $_getN(8);
  @$pb.TagNumber(9)
  set payloadJson($core.List<$core.int> value) => $_setBytes(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPayloadJson() => $_has(8);
  @$pb.TagNumber(9)
  void clearPayloadJson() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get cursor => $_getSZ(9);
  @$pb.TagNumber(10)
  set cursor($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCursor() => $_has(9);
  @$pb.TagNumber(10)
  void clearCursor() => $_clearField(10);

  @$pb.TagNumber(12)
  $core.bool get hasPos_12 => $_getBF(10);
  @$pb.TagNumber(12)
  set hasPos_12($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(12)
  $core.bool hasHasPos_12() => $_has(10);
  @$pb.TagNumber(12)
  void clearHasPos_12() => $_clearField(12);
}

/// A convenience client-facing snapshot mirroring SnapshotResponse but embedded in WS.
class Snapshot extends $pb.GeneratedMessage {
  factory Snapshot({
    $core.String? realmId,
    $fixnum.Int64? version,
    $core.List<$core.int>? stateJson,
    $core.List<$core.int>? mapJson,
    $fixnum.Int64? serverTimeUnixMs,
    $core.String? cursor,
  }) {
    final result = Snapshot._();
    if (realmId != null) result.realmId = realmId;
    if (version != null) result.version = version;
    if (stateJson != null) result.stateJson = stateJson;
    if (mapJson != null) result.mapJson = mapJson;
    if (serverTimeUnixMs != null) result.serverTimeUnixMs = serverTimeUnixMs;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  Snapshot._();

  factory Snapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Snapshot()..mergeFromBuffer(data, registry);
  factory Snapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Snapshot()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Snapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'kd.v1'),
      createEmptyInstance: Snapshot.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'realmId')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'stateJson', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'mapJson', $pb.PbFieldType.OY)
    ..aInt64(5, _omitFieldNames ? '' : 'serverTimeUnixMs')
    ..aOS(6, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Snapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Snapshot copyWith(void Function(Snapshot) updates) =>
      super.copyWith((message) => updates(message as Snapshot)) as Snapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Snapshot() / Snapshot.new instead')
  static Snapshot create() => Snapshot._();
  static $pb.GeneratedMessage $_createMessage() => Snapshot._();
  @$core.override
  Snapshot createEmptyInstance() => Snapshot._();
  @$core.pragma('dart2js:noInline')
  static Snapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Snapshot>(Snapshot.$_createMessage);
  static Snapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get realmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set realmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRealmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRealmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get version => $_getI64(1);
  @$pb.TagNumber(2)
  set version($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get stateJson => $_getN(2);
  @$pb.TagNumber(3)
  set stateJson($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStateJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearStateJson() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get mapJson => $_getN(3);
  @$pb.TagNumber(4)
  set mapJson($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMapJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearMapJson() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get serverTimeUnixMs => $_getI64(4);
  @$pb.TagNumber(5)
  set serverTimeUnixMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasServerTimeUnixMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearServerTimeUnixMs() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get cursor => $_getSZ(5);
  @$pb.TagNumber(6)
  set cursor($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearCursor() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
