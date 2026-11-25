// This is a generated file - do not edit.
//
// Generated from kd.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use errorCodeDescriptor instead')
const ErrorCode$json = {
  '1': 'ErrorCode',
  '2': [
    {'1': 'ERROR_CODE_UNSPECIFIED', '2': 0},
    {'1': 'OK', '2': 1},
    {'1': 'UNAUTHENTICATED', '2': 2},
    {'1': 'PERMISSION_DENIED', '2': 3},
    {'1': 'NOT_FOUND', '2': 4},
    {'1': 'INVALID_ARGUMENT', '2': 5},
    {'1': 'CONFLICT', '2': 6},
    {'1': 'INSUFFICIENT_RESOURCES', '2': 7},
    {'1': 'INSUFFICIENT_TROOPS', '2': 8},
    {'1': 'PREREQUISITE_UNMET', '2': 9},
    {'1': 'QUEUE_FULL', '2': 10},
    {'1': 'BUSY', '2': 11},
    {'1': 'STALE_VERSION', '2': 12},
    {'1': 'CROSS_REALM', '2': 13},
    {'1': 'RATE_LIMITED', '2': 14},
    {'1': 'SHIELDED', '2': 15},
    {'1': 'NO_TARGET', '2': 16},
    {'1': 'INTERNAL', '2': 17},
    {'1': 'DUPLICATE', '2': 18},
    {'1': 'NOT_OWNER', '2': 19},
  ],
};

/// Descriptor for `ErrorCode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errorCodeDescriptor = $convert.base64Decode(
    'CglFcnJvckNvZGUSGgoWRVJST1JfQ09ERV9VTlNQRUNJRklFRBAAEgYKAk9LEAESEwoPVU5BVV'
    'RIRU5USUNBVEVEEAISFQoRUEVSTUlTU0lPTl9ERU5JRUQQAxINCglOT1RfRk9VTkQQBBIUChBJ'
    'TlZBTElEX0FSR1VNRU5UEAUSDAoIQ09ORkxJQ1QQBhIaChZJTlNVRkZJQ0lFTlRfUkVTT1VSQ0'
    'VTEAcSFwoTSU5TVUZGSUNJRU5UX1RST09QUxAIEhYKElBSRVJFUVVJU0lURV9VTk1FVBAJEg4K'
    'ClFVRVVFX0ZVTEwQChIICgRCVVNZEAsSEQoNU1RBTEVfVkVSU0lPThAMEg8KC0NST1NTX1JFQU'
    'xNEA0SEAoMUkFURV9MSU1JVEVEEA4SDAoIU0hJRUxERUQQDxINCglOT19UQVJHRVQQEBIMCghJ'
    'TlRFUk5BTBAREg0KCURVUExJQ0FURRASEg0KCU5PVF9PV05FUhAT');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');

@$core.Deprecated('Use vec2Descriptor instead')
const Vec2$json = {
  '1': 'Vec2',
  '2': [
    {'1': 'x', '3': 1, '4': 1, '5': 5, '10': 'x'},
    {'1': 'y', '3': 2, '4': 1, '5': 5, '10': 'y'},
  ],
};

/// Descriptor for `Vec2`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List vec2Descriptor =
    $convert.base64Decode('CgRWZWMyEgwKAXgYASABKAVSAXgSDAoBeRgCIAEoBVIBeQ==');

@$core.Deprecated('Use resourcesDescriptor instead')
const Resources$json = {
  '1': 'Resources',
  '2': [
    {'1': 'food', '3': 1, '4': 1, '5': 3, '10': 'food'},
    {'1': 'wood', '3': 2, '4': 1, '5': 3, '10': 'wood'},
    {'1': 'stone', '3': 3, '4': 1, '5': 3, '10': 'stone'},
    {'1': 'iron', '3': 4, '4': 1, '5': 3, '10': 'iron'},
    {'1': 'gold', '3': 5, '4': 1, '5': 3, '10': 'gold'},
  ],
};

/// Descriptor for `Resources`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resourcesDescriptor = $convert.base64Decode(
    'CglSZXNvdXJjZXMSEgoEZm9vZBgBIAEoA1IEZm9vZBISCgR3b29kGAIgASgDUgR3b29kEhQKBX'
    'N0b25lGAMgASgDUgVzdG9uZRISCgRpcm9uGAQgASgDUgRpcm9uEhIKBGdvbGQYBSABKANSBGdv'
    'bGQ=');

@$core.Deprecated('Use registerRequestDescriptor instead')
const RegisterRequest$json = {
  '1': 'RegisterRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
  ],
};

/// Descriptor for `RegisterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerRequestDescriptor = $convert.base64Decode(
    'Cg9SZWdpc3RlclJlcXVlc3QSGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1lEhoKCHBhc3N3b3'
    'JkGAIgASgJUghwYXNzd29yZBIhCgxkaXNwbGF5X25hbWUYAyABKAlSC2Rpc3BsYXlOYW1l');

@$core.Deprecated('Use registerResponseDescriptor instead')
const RegisterResponse$json = {
  '1': 'RegisterResponse',
  '2': [
    {'1': 'account_id', '3': 1, '4': 1, '5': 9, '10': 'accountId'},
  ],
};

/// Descriptor for `RegisterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerResponseDescriptor = $convert.base64Decode(
    'ChBSZWdpc3RlclJlc3BvbnNlEh0KCmFjY291bnRfaWQYASABKAlSCWFjY291bnRJZA==');

@$core.Deprecated('Use loginRequestDescriptor instead')
const LoginRequest$json = {
  '1': 'LoginRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlcXVlc3QSGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1lEhoKCHBhc3N3b3JkGA'
    'IgASgJUghwYXNzd29yZA==');

@$core.Deprecated('Use loginResponseDescriptor instead')
const LoginResponse$json = {
  '1': 'LoginResponse',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {'1': 'expires_at_unix', '3': 2, '4': 1, '5': 3, '10': 'expiresAtUnix'},
    {'1': 'account_id', '3': 3, '4': 1, '5': 9, '10': 'accountId'},
  ],
};

/// Descriptor for `LoginResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginResponseDescriptor = $convert.base64Decode(
    'Cg1Mb2dpblJlc3BvbnNlEhQKBXRva2VuGAEgASgJUgV0b2tlbhImCg9leHBpcmVzX2F0X3VuaX'
    'gYAiABKANSDWV4cGlyZXNBdFVuaXgSHQoKYWNjb3VudF9pZBgDIAEoCVIJYWNjb3VudElk');

@$core.Deprecated('Use logoutRequestDescriptor instead')
const LogoutRequest$json = {
  '1': 'LogoutRequest',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `LogoutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logoutRequestDescriptor = $convert
    .base64Decode('Cg1Mb2dvdXRSZXF1ZXN0EhQKBXRva2VuGAEgASgJUgV0b2tlbg==');

@$core.Deprecated('Use realmInfoDescriptor instead')
const RealmInfo$json = {
  '1': 'RealmInfo',
  '2': [
    {'1': 'realm_id', '3': 1, '4': 1, '5': 9, '10': 'realmId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'status', '3': 3, '4': 1, '5': 9, '10': 'status'},
    {'1': 'players', '3': 4, '4': 1, '5': 13, '10': 'players'},
    {'1': 'shard', '3': 5, '4': 1, '5': 9, '10': 'shard'},
  ],
};

/// Descriptor for `RealmInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List realmInfoDescriptor = $convert.base64Decode(
    'CglSZWFsbUluZm8SGQoIcmVhbG1faWQYASABKAlSB3JlYWxtSWQSEgoEbmFtZRgCIAEoCVIEbm'
    'FtZRIWCgZzdGF0dXMYAyABKAlSBnN0YXR1cxIYCgdwbGF5ZXJzGAQgASgNUgdwbGF5ZXJzEhQK'
    'BXNoYXJkGAUgASgJUgVzaGFyZA==');

@$core.Deprecated('Use listRealmsResponseDescriptor instead')
const ListRealmsResponse$json = {
  '1': 'ListRealmsResponse',
  '2': [
    {
      '1': 'realms',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.kd.v1.RealmInfo',
      '10': 'realms'
    },
  ],
};

/// Descriptor for `ListRealmsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRealmsResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0UmVhbG1zUmVzcG9uc2USKAoGcmVhbG1zGAEgAygLMhAua2QudjEuUmVhbG1JbmZvUg'
    'ZyZWFsbXM=');

@$core.Deprecated('Use joinRealmRequestDescriptor instead')
const JoinRealmRequest$json = {
  '1': 'JoinRealmRequest',
  '2': [
    {'1': 'realm_id', '3': 1, '4': 1, '5': 9, '10': 'realmId'},
  ],
};

/// Descriptor for `JoinRealmRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRealmRequestDescriptor = $convert.base64Decode(
    'ChBKb2luUmVhbG1SZXF1ZXN0EhkKCHJlYWxtX2lkGAEgASgJUgdyZWFsbUlk');

@$core.Deprecated('Use joinRealmResponseDescriptor instead')
const JoinRealmResponse$json = {
  '1': 'JoinRealmResponse',
  '2': [
    {'1': 'player_id', '3': 1, '4': 1, '5': 9, '10': 'playerId'},
    {'1': 'created_city', '3': 2, '4': 1, '5': 8, '10': 'createdCity'},
  ],
};

/// Descriptor for `JoinRealmResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRealmResponseDescriptor = $convert.base64Decode(
    'ChFKb2luUmVhbG1SZXNwb25zZRIbCglwbGF5ZXJfaWQYASABKAlSCHBsYXllcklkEiEKDGNyZW'
    'F0ZWRfY2l0eRgCIAEoCFILY3JlYXRlZENpdHk=');

@$core.Deprecated('Use createRealmRequestDescriptor instead')
const CreateRealmRequest$json = {
  '1': 'CreateRealmRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'shard', '3': 2, '4': 1, '5': 9, '10': 'shard'},
  ],
};

/// Descriptor for `CreateRealmRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRealmRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVSZWFsbVJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIUCgVzaGFyZBgCIAEoCV'
    'IFc2hhcmQ=');

@$core.Deprecated('Use createRealmResponseDescriptor instead')
const CreateRealmResponse$json = {
  '1': 'CreateRealmResponse',
  '2': [
    {'1': 'realm_id', '3': 1, '4': 1, '5': 9, '10': 'realmId'},
  ],
};

/// Descriptor for `CreateRealmResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRealmResponseDescriptor =
    $convert.base64Decode(
        'ChNDcmVhdGVSZWFsbVJlc3BvbnNlEhkKCHJlYWxtX2lkGAEgASgJUgdyZWFsbUlk');

@$core.Deprecated('Use realmMembershipDescriptor instead')
const RealmMembership$json = {
  '1': 'RealmMembership',
  '2': [
    {'1': 'realm_id', '3': 1, '4': 1, '5': 9, '10': 'realmId'},
    {'1': 'player_id', '3': 2, '4': 1, '5': 9, '10': 'playerId'},
  ],
};

/// Descriptor for `RealmMembership`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List realmMembershipDescriptor = $convert.base64Decode(
    'Cg9SZWFsbU1lbWJlcnNoaXASGQoIcmVhbG1faWQYASABKAlSB3JlYWxtSWQSGwoJcGxheWVyX2'
    'lkGAIgASgJUghwbGF5ZXJJZA==');

@$core.Deprecated('Use validateRequestDescriptor instead')
const ValidateRequest$json = {
  '1': 'ValidateRequest',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `ValidateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateRequestDescriptor = $convert
    .base64Decode('Cg9WYWxpZGF0ZVJlcXVlc3QSFAoFdG9rZW4YASABKAlSBXRva2Vu');

@$core.Deprecated('Use validateResponseDescriptor instead')
const ValidateResponse$json = {
  '1': 'ValidateResponse',
  '2': [
    {'1': 'account_id', '3': 1, '4': 1, '5': 9, '10': 'accountId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {
      '1': 'memberships',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.kd.v1.RealmMembership',
      '10': 'memberships'
    },
  ],
};

/// Descriptor for `ValidateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateResponseDescriptor = $convert.base64Decode(
    'ChBWYWxpZGF0ZVJlc3BvbnNlEh0KCmFjY291bnRfaWQYASABKAlSCWFjY291bnRJZBIaCgh1c2'
    'VybmFtZRgCIAEoCVIIdXNlcm5hbWUSOAoLbWVtYmVyc2hpcHMYAyADKAsyFi5rZC52MS5SZWFs'
    'bU1lbWJlcnNoaXBSC21lbWJlcnNoaXBz');

@$core.Deprecated('Use getRealmRouteRequestDescriptor instead')
const GetRealmRouteRequest$json = {
  '1': 'GetRealmRouteRequest',
  '2': [
    {'1': 'realm_id', '3': 1, '4': 1, '5': 9, '10': 'realmId'},
  ],
};

/// Descriptor for `GetRealmRouteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRealmRouteRequestDescriptor =
    $convert.base64Decode(
        'ChRHZXRSZWFsbVJvdXRlUmVxdWVzdBIZCghyZWFsbV9pZBgBIAEoCVIHcmVhbG1JZA==');

@$core.Deprecated('Use getRealmRouteResponseDescriptor instead')
const GetRealmRouteResponse$json = {
  '1': 'GetRealmRouteResponse',
  '2': [
    {'1': 'realm_id', '3': 1, '4': 1, '5': 9, '10': 'realmId'},
    {'1': 'shard', '3': 2, '4': 1, '5': 9, '10': 'shard'},
    {'1': 'worker_address', '3': 3, '4': 1, '5': 9, '10': 'workerAddress'},
  ],
};

/// Descriptor for `GetRealmRouteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRealmRouteResponseDescriptor = $convert.base64Decode(
    'ChVHZXRSZWFsbVJvdXRlUmVzcG9uc2USGQoIcmVhbG1faWQYASABKAlSB3JlYWxtSWQSFAoFc2'
    'hhcmQYAiABKAlSBXNoYXJkEiUKDndvcmtlcl9hZGRyZXNzGAMgASgJUg13b3JrZXJBZGRyZXNz');

@$core.Deprecated('Use submitCommandRequestDescriptor instead')
const SubmitCommandRequest$json = {
  '1': 'SubmitCommandRequest',
  '2': [
    {'1': 'realm_id', '3': 1, '4': 1, '5': 9, '10': 'realmId'},
    {
      '1': 'principal_player_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'principalPlayerId'
    },
    {'1': 'command_id', '3': 3, '4': 1, '5': 9, '10': 'commandId'},
    {
      '1': 'payload',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.CommandPayload',
      '10': 'payload'
    },
  ],
};

/// Descriptor for `SubmitCommandRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitCommandRequestDescriptor = $convert.base64Decode(
    'ChRTdWJtaXRDb21tYW5kUmVxdWVzdBIZCghyZWFsbV9pZBgBIAEoCVIHcmVhbG1JZBIuChNwcm'
    'luY2lwYWxfcGxheWVyX2lkGAIgASgJUhFwcmluY2lwYWxQbGF5ZXJJZBIdCgpjb21tYW5kX2lk'
    'GAMgASgJUgljb21tYW5kSWQSLwoHcGF5bG9hZBgEIAEoCzIVLmtkLnYxLkNvbW1hbmRQYXlsb2'
    'FkUgdwYXlsb2Fk');

@$core.Deprecated('Use commandResultDescriptor instead')
const CommandResult$json = {
  '1': 'CommandResult',
  '2': [
    {'1': 'command_id', '3': 1, '4': 1, '5': 9, '10': 'commandId'},
    {
      '1': 'code',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.kd.v1.ErrorCode',
      '10': 'code'
    },
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    {'1': 'state_version', '3': 4, '4': 1, '5': 4, '10': 'stateVersion'},
    {
      '1': 'server_time_unix_ms',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'serverTimeUnixMs'
    },
    {'1': 'state_json', '3': 6, '4': 1, '5': 12, '10': 'stateJson'},
  ],
};

/// Descriptor for `CommandResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandResultDescriptor = $convert.base64Decode(
    'Cg1Db21tYW5kUmVzdWx0Eh0KCmNvbW1hbmRfaWQYASABKAlSCWNvbW1hbmRJZBIkCgRjb2RlGA'
    'IgASgOMhAua2QudjEuRXJyb3JDb2RlUgRjb2RlEhgKB21lc3NhZ2UYAyABKAlSB21lc3NhZ2US'
    'IwoNc3RhdGVfdmVyc2lvbhgEIAEoBFIMc3RhdGVWZXJzaW9uEi0KE3NlcnZlcl90aW1lX3VuaX'
    'hfbXMYBSABKANSEHNlcnZlclRpbWVVbml4TXMSHQoKc3RhdGVfanNvbhgGIAEoDFIJc3RhdGVK'
    'c29u');

@$core.Deprecated('Use snapshotRequestDescriptor instead')
const SnapshotRequest$json = {
  '1': 'SnapshotRequest',
  '2': [
    {'1': 'realm_id', '3': 1, '4': 1, '5': 9, '10': 'realmId'},
    {
      '1': 'principal_player_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'principalPlayerId'
    },
    {
      '1': 'chunks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.kd.v1.Vec2',
      '10': 'chunks'
    },
  ],
};

/// Descriptor for `SnapshotRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List snapshotRequestDescriptor = $convert.base64Decode(
    'Cg9TbmFwc2hvdFJlcXVlc3QSGQoIcmVhbG1faWQYASABKAlSB3JlYWxtSWQSLgoTcHJpbmNpcG'
    'FsX3BsYXllcl9pZBgCIAEoCVIRcHJpbmNpcGFsUGxheWVySWQSIwoGY2h1bmtzGAMgAygLMgsu'
    'a2QudjEuVmVjMlIGY2h1bmtz');

@$core.Deprecated('Use snapshotResponseDescriptor instead')
const SnapshotResponse$json = {
  '1': 'SnapshotResponse',
  '2': [
    {'1': 'realm_id', '3': 1, '4': 1, '5': 9, '10': 'realmId'},
    {'1': 'version', '3': 2, '4': 1, '5': 4, '10': 'version'},
    {'1': 'state_json', '3': 3, '4': 1, '5': 12, '10': 'stateJson'},
    {'1': 'map_json', '3': 4, '4': 1, '5': 12, '10': 'mapJson'},
    {
      '1': 'server_time_unix_ms',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'serverTimeUnixMs'
    },
    {'1': 'cursor', '3': 6, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `SnapshotResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List snapshotResponseDescriptor = $convert.base64Decode(
    'ChBTbmFwc2hvdFJlc3BvbnNlEhkKCHJlYWxtX2lkGAEgASgJUgdyZWFsbUlkEhgKB3ZlcnNpb2'
    '4YAiABKARSB3ZlcnNpb24SHQoKc3RhdGVfanNvbhgDIAEoDFIJc3RhdGVKc29uEhkKCG1hcF9q'
    'c29uGAQgASgMUgdtYXBKc29uEi0KE3NlcnZlcl90aW1lX3VuaXhfbXMYBSABKANSEHNlcnZlcl'
    'RpbWVVbml4TXMSFgoGY3Vyc29yGAYgASgJUgZjdXJzb3I=');

@$core.Deprecated('Use workerHealthDescriptor instead')
const WorkerHealth$json = {
  '1': 'WorkerHealth',
  '2': [
    {'1': 'worker_id', '3': 1, '4': 1, '5': 9, '10': 'workerId'},
    {'1': 'realms', '3': 2, '4': 3, '5': 9, '10': 'realms'},
    {'1': 'ready', '3': 3, '4': 1, '5': 8, '10': 'ready'},
  ],
};

/// Descriptor for `WorkerHealth`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workerHealthDescriptor = $convert.base64Decode(
    'CgxXb3JrZXJIZWFsdGgSGwoJd29ya2VyX2lkGAEgASgJUgh3b3JrZXJJZBIWCgZyZWFsbXMYAi'
    'ADKAlSBnJlYWxtcxIUCgVyZWFkeRgDIAEoCFIFcmVhZHk=');

@$core.Deprecated('Use ensurePlayerRequestDescriptor instead')
const EnsurePlayerRequest$json = {
  '1': 'EnsurePlayerRequest',
  '2': [
    {'1': 'realm_id', '3': 1, '4': 1, '5': 9, '10': 'realmId'},
    {'1': 'account_id', '3': 2, '4': 1, '5': 9, '10': 'accountId'},
    {'1': 'player_id', '3': 3, '4': 1, '5': 9, '10': 'playerId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `EnsurePlayerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ensurePlayerRequestDescriptor = $convert.base64Decode(
    'ChNFbnN1cmVQbGF5ZXJSZXF1ZXN0EhkKCHJlYWxtX2lkGAEgASgJUgdyZWFsbUlkEh0KCmFjY2'
    '91bnRfaWQYAiABKAlSCWFjY291bnRJZBIbCglwbGF5ZXJfaWQYAyABKAlSCHBsYXllcklkEhIK'
    'BG5hbWUYBCABKAlSBG5hbWU=');

@$core.Deprecated('Use ensurePlayerResponseDescriptor instead')
const EnsurePlayerResponse$json = {
  '1': 'EnsurePlayerResponse',
  '2': [
    {'1': 'player_id', '3': 1, '4': 1, '5': 9, '10': 'playerId'},
    {'1': 'created', '3': 2, '4': 1, '5': 8, '10': 'created'},
  ],
};

/// Descriptor for `EnsurePlayerResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ensurePlayerResponseDescriptor = $convert.base64Decode(
    'ChRFbnN1cmVQbGF5ZXJSZXNwb25zZRIbCglwbGF5ZXJfaWQYASABKAlSCHBsYXllcklkEhgKB2'
    'NyZWF0ZWQYAiABKAhSB2NyZWF0ZWQ=');

@$core.Deprecated('Use advanceClockRequestDescriptor instead')
const AdvanceClockRequest$json = {
  '1': 'AdvanceClockRequest',
  '2': [
    {'1': 'realm_id', '3': 1, '4': 1, '5': 9, '10': 'realmId'},
    {'1': 'delta_micros', '3': 2, '4': 1, '5': 3, '10': 'deltaMicros'},
  ],
};

/// Descriptor for `AdvanceClockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List advanceClockRequestDescriptor = $convert.base64Decode(
    'ChNBZHZhbmNlQ2xvY2tSZXF1ZXN0EhkKCHJlYWxtX2lkGAEgASgJUgdyZWFsbUlkEiEKDGRlbH'
    'RhX21pY3JvcxgCIAEoA1ILZGVsdGFNaWNyb3M=');

@$core.Deprecated('Use advanceClockResponseDescriptor instead')
const AdvanceClockResponse$json = {
  '1': 'AdvanceClockResponse',
  '2': [
    {'1': 'clock_now_ms', '3': 1, '4': 1, '5': 3, '10': 'clockNowMs'},
  ],
};

/// Descriptor for `AdvanceClockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List advanceClockResponseDescriptor = $convert.base64Decode(
    'ChRBZHZhbmNlQ2xvY2tSZXNwb25zZRIgCgxjbG9ja19ub3dfbXMYASABKANSCmNsb2NrTm93TX'
    'M=');

@$core.Deprecated('Use commandPayloadDescriptor instead')
const CommandPayload$json = {
  '1': 'CommandPayload',
  '2': [
    {
      '1': 'create_city',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.CreateCityCmd',
      '9': 0,
      '10': 'createCity'
    },
    {
      '1': 'upgrade_building',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.UpgradeBuildingCmd',
      '9': 0,
      '10': 'upgradeBuilding'
    },
    {
      '1': 'start_research',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.StartResearchCmd',
      '9': 0,
      '10': 'startResearch'
    },
    {
      '1': 'train_troops',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.TrainTroopsCmd',
      '9': 0,
      '10': 'trainTroops'
    },
    {
      '1': 'heal_troops',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.HealTroopsCmd',
      '9': 0,
      '10': 'healTroops'
    },
    {
      '1': 'use_item',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.UseItemCmd',
      '9': 0,
      '10': 'useItem'
    },
    {
      '1': 'scout_tile',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.ScoutTileCmd',
      '9': 0,
      '10': 'scoutTile'
    },
    {
      '1': 'attack_monster',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.AttackMonsterCmd',
      '9': 0,
      '10': 'attackMonster'
    },
    {
      '1': 'gather',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.GatherCmd',
      '9': 0,
      '10': 'gather'
    },
    {
      '1': 'attack_city',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.AttackCityCmd',
      '9': 0,
      '10': 'attackCity'
    },
    {
      '1': 'attack_fort',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.AttackFortCmd',
      '9': 0,
      '10': 'attackFort'
    },
    {
      '1': 'reinforce',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.ReinforceCmd',
      '9': 0,
      '10': 'reinforce'
    },
    {
      '1': 'transport',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.TransportCmd',
      '9': 0,
      '10': 'transport'
    },
    {
      '1': 'recall',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.RecallCmd',
      '9': 0,
      '10': 'recall'
    },
    {
      '1': 'set_shield',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.SetShieldCmd',
      '9': 0,
      '10': 'setShield'
    },
    {
      '1': 'create_alliance',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.CreateAllianceCmd',
      '9': 0,
      '10': 'createAlliance'
    },
    {
      '1': 'alliance_invite',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.AllianceInviteCmd',
      '9': 0,
      '10': 'allianceInvite'
    },
    {
      '1': 'alliance_accept',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.AllianceAcceptCmd',
      '9': 0,
      '10': 'allianceAccept'
    },
    {
      '1': 'alliance_join',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.AllianceJoinCmd',
      '9': 0,
      '10': 'allianceJoin'
    },
    {
      '1': 'alliance_leave',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.AllianceLeaveCmd',
      '9': 0,
      '10': 'allianceLeave'
    },
    {
      '1': 'alliance_kick',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.AllianceKickCmd',
      '9': 0,
      '10': 'allianceKick'
    },
    {
      '1': 'alliance_help',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.AllianceHelpCmd',
      '9': 0,
      '10': 'allianceHelp'
    },
    {
      '1': 'rally_create',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.RallyCreateCmd',
      '9': 0,
      '10': 'rallyCreate'
    },
    {
      '1': 'rally_join',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.RallyJoinCmd',
      '9': 0,
      '10': 'rallyJoin'
    },
    {
      '1': 'rally_cancel',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.RallyCancelCmd',
      '9': 0,
      '10': 'rallyCancel'
    },
    {
      '1': 'chat',
      '3': 26,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.ChatCmd',
      '9': 0,
      '10': 'chat'
    },
    {
      '1': 'switch_capital',
      '3': 27,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.SwitchCapitalCmd',
      '9': 0,
      '10': 'switchCapital'
    },
    {
      '1': 'recruit_hero',
      '3': 28,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.RecruitHeroCmd',
      '9': 0,
      '10': 'recruitHero'
    },
    {
      '1': 'demolish_building',
      '3': 29,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.DemolishBuildingCmd',
      '9': 0,
      '10': 'demolishBuilding'
    },
    {
      '1': 'market_buy',
      '3': 30,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.MarketBuyCmd',
      '9': 0,
      '10': 'marketBuy'
    },
    {
      '1': 'market_sell',
      '3': 31,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.MarketSellCmd',
      '9': 0,
      '10': 'marketSell'
    },
  ],
  '8': [
    {'1': 'action'},
  ],
};

/// Descriptor for `CommandPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandPayloadDescriptor = $convert.base64Decode(
    'Cg5Db21tYW5kUGF5bG9hZBI3CgtjcmVhdGVfY2l0eRgBIAEoCzIULmtkLnYxLkNyZWF0ZUNpdH'
    'lDbWRIAFIKY3JlYXRlQ2l0eRJGChB1cGdyYWRlX2J1aWxkaW5nGAIgASgLMhkua2QudjEuVXBn'
    'cmFkZUJ1aWxkaW5nQ21kSABSD3VwZ3JhZGVCdWlsZGluZxJACg5zdGFydF9yZXNlYXJjaBgDIA'
    'EoCzIXLmtkLnYxLlN0YXJ0UmVzZWFyY2hDbWRIAFINc3RhcnRSZXNlYXJjaBI6Cgx0cmFpbl90'
    'cm9vcHMYBCABKAsyFS5rZC52MS5UcmFpblRyb29wc0NtZEgAUgt0cmFpblRyb29wcxI3CgtoZW'
    'FsX3Ryb29wcxgFIAEoCzIULmtkLnYxLkhlYWxUcm9vcHNDbWRIAFIKaGVhbFRyb29wcxIuCgh1'
    'c2VfaXRlbRgGIAEoCzIRLmtkLnYxLlVzZUl0ZW1DbWRIAFIHdXNlSXRlbRI0CgpzY291dF90aW'
    'xlGAcgASgLMhMua2QudjEuU2NvdXRUaWxlQ21kSABSCXNjb3V0VGlsZRJACg5hdHRhY2tfbW9u'
    'c3RlchgIIAEoCzIXLmtkLnYxLkF0dGFja01vbnN0ZXJDbWRIAFINYXR0YWNrTW9uc3RlchIqCg'
    'ZnYXRoZXIYCSABKAsyEC5rZC52MS5HYXRoZXJDbWRIAFIGZ2F0aGVyEjcKC2F0dGFja19jaXR5'
    'GAogASgLMhQua2QudjEuQXR0YWNrQ2l0eUNtZEgAUgphdHRhY2tDaXR5EjcKC2F0dGFja19mb3'
    'J0GAsgASgLMhQua2QudjEuQXR0YWNrRm9ydENtZEgAUgphdHRhY2tGb3J0EjMKCXJlaW5mb3Jj'
    'ZRgMIAEoCzITLmtkLnYxLlJlaW5mb3JjZUNtZEgAUglyZWluZm9yY2USMwoJdHJhbnNwb3J0GA'
    '0gASgLMhMua2QudjEuVHJhbnNwb3J0Q21kSABSCXRyYW5zcG9ydBIqCgZyZWNhbGwYDiABKAsy'
    'EC5rZC52MS5SZWNhbGxDbWRIAFIGcmVjYWxsEjQKCnNldF9zaGllbGQYDyABKAsyEy5rZC52MS'
    '5TZXRTaGllbGRDbWRIAFIJc2V0U2hpZWxkEkMKD2NyZWF0ZV9hbGxpYW5jZRgQIAEoCzIYLmtk'
    'LnYxLkNyZWF0ZUFsbGlhbmNlQ21kSABSDmNyZWF0ZUFsbGlhbmNlEkMKD2FsbGlhbmNlX2ludm'
    'l0ZRgRIAEoCzIYLmtkLnYxLkFsbGlhbmNlSW52aXRlQ21kSABSDmFsbGlhbmNlSW52aXRlEkMK'
    'D2FsbGlhbmNlX2FjY2VwdBgSIAEoCzIYLmtkLnYxLkFsbGlhbmNlQWNjZXB0Q21kSABSDmFsbG'
    'lhbmNlQWNjZXB0Ej0KDWFsbGlhbmNlX2pvaW4YEyABKAsyFi5rZC52MS5BbGxpYW5jZUpvaW5D'
    'bWRIAFIMYWxsaWFuY2VKb2luEkAKDmFsbGlhbmNlX2xlYXZlGBQgASgLMhcua2QudjEuQWxsaW'
    'FuY2VMZWF2ZUNtZEgAUg1hbGxpYW5jZUxlYXZlEj0KDWFsbGlhbmNlX2tpY2sYFSABKAsyFi5r'
    'ZC52MS5BbGxpYW5jZUtpY2tDbWRIAFIMYWxsaWFuY2VLaWNrEj0KDWFsbGlhbmNlX2hlbHAYFi'
    'ABKAsyFi5rZC52MS5BbGxpYW5jZUhlbHBDbWRIAFIMYWxsaWFuY2VIZWxwEjoKDHJhbGx5X2Ny'
    'ZWF0ZRgXIAEoCzIVLmtkLnYxLlJhbGx5Q3JlYXRlQ21kSABSC3JhbGx5Q3JlYXRlEjQKCnJhbG'
    'x5X2pvaW4YGCABKAsyEy5rZC52MS5SYWxseUpvaW5DbWRIAFIJcmFsbHlKb2luEjoKDHJhbGx5'
    'X2NhbmNlbBgZIAEoCzIVLmtkLnYxLlJhbGx5Q2FuY2VsQ21kSABSC3JhbGx5Q2FuY2VsEiQKBG'
    'NoYXQYGiABKAsyDi5rZC52MS5DaGF0Q21kSABSBGNoYXQSQAoOc3dpdGNoX2NhcGl0YWwYGyAB'
    'KAsyFy5rZC52MS5Td2l0Y2hDYXBpdGFsQ21kSABSDXN3aXRjaENhcGl0YWwSOgoMcmVjcnVpdF'
    '9oZXJvGBwgASgLMhUua2QudjEuUmVjcnVpdEhlcm9DbWRIAFILcmVjcnVpdEhlcm8SSQoRZGVt'
    'b2xpc2hfYnVpbGRpbmcYHSABKAsyGi5rZC52MS5EZW1vbGlzaEJ1aWxkaW5nQ21kSABSEGRlbW'
    '9saXNoQnVpbGRpbmcSNAoKbWFya2V0X2J1eRgeIAEoCzITLmtkLnYxLk1hcmtldEJ1eUNtZEgA'
    'UgltYXJrZXRCdXkSNwoLbWFya2V0X3NlbGwYHyABKAsyFC5rZC52MS5NYXJrZXRTZWxsQ21kSA'
    'BSCm1hcmtldFNlbGxCCAoGYWN0aW9u');

@$core.Deprecated('Use createCityCmdDescriptor instead')
const CreateCityCmd$json = {
  '1': 'CreateCityCmd',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'pos', '3': 2, '4': 1, '5': 11, '6': '.kd.v1.Vec2', '10': 'pos'},
  ],
};

/// Descriptor for `CreateCityCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCityCmdDescriptor = $convert.base64Decode(
    'Cg1DcmVhdGVDaXR5Q21kEhIKBG5hbWUYASABKAlSBG5hbWUSHQoDcG9zGAIgASgLMgsua2Qudj'
    'EuVmVjMlIDcG9z');

@$core.Deprecated('Use upgradeBuildingCmdDescriptor instead')
const UpgradeBuildingCmd$json = {
  '1': 'UpgradeBuildingCmd',
  '2': [
    {'1': 'city_id', '3': 1, '4': 1, '5': 9, '10': 'cityId'},
    {'1': 'building', '3': 2, '4': 1, '5': 9, '10': 'building'},
  ],
};

/// Descriptor for `UpgradeBuildingCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List upgradeBuildingCmdDescriptor = $convert.base64Decode(
    'ChJVcGdyYWRlQnVpbGRpbmdDbWQSFwoHY2l0eV9pZBgBIAEoCVIGY2l0eUlkEhoKCGJ1aWxkaW'
    '5nGAIgASgJUghidWlsZGluZw==');

@$core.Deprecated('Use startResearchCmdDescriptor instead')
const StartResearchCmd$json = {
  '1': 'StartResearchCmd',
  '2': [
    {'1': 'tech', '3': 1, '4': 1, '5': 9, '10': 'tech'},
  ],
};

/// Descriptor for `StartResearchCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startResearchCmdDescriptor = $convert
    .base64Decode('ChBTdGFydFJlc2VhcmNoQ21kEhIKBHRlY2gYASABKAlSBHRlY2g=');

@$core.Deprecated('Use trainTroopsCmdDescriptor instead')
const TrainTroopsCmd$json = {
  '1': 'TrainTroopsCmd',
  '2': [
    {'1': 'city_id', '3': 1, '4': 1, '5': 9, '10': 'cityId'},
    {'1': 'unit', '3': 2, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'tier', '3': 3, '4': 1, '5': 13, '10': 'tier'},
    {'1': 'count', '3': 4, '4': 1, '5': 13, '10': 'count'},
  ],
};

/// Descriptor for `TrainTroopsCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trainTroopsCmdDescriptor = $convert.base64Decode(
    'Cg5UcmFpblRyb29wc0NtZBIXCgdjaXR5X2lkGAEgASgJUgZjaXR5SWQSEgoEdW5pdBgCIAEoCV'
    'IEdW5pdBISCgR0aWVyGAMgASgNUgR0aWVyEhQKBWNvdW50GAQgASgNUgVjb3VudA==');

@$core.Deprecated('Use healTroopsCmdDescriptor instead')
const HealTroopsCmd$json = {
  '1': 'HealTroopsCmd',
  '2': [
    {'1': 'city_id', '3': 1, '4': 1, '5': 9, '10': 'cityId'},
    {'1': 'unit', '3': 2, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'tier', '3': 3, '4': 1, '5': 13, '10': 'tier'},
    {'1': 'count', '3': 4, '4': 1, '5': 13, '10': 'count'},
  ],
};

/// Descriptor for `HealTroopsCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healTroopsCmdDescriptor = $convert.base64Decode(
    'Cg1IZWFsVHJvb3BzQ21kEhcKB2NpdHlfaWQYASABKAlSBmNpdHlJZBISCgR1bml0GAIgASgJUg'
    'R1bml0EhIKBHRpZXIYAyABKA1SBHRpZXISFAoFY291bnQYBCABKA1SBWNvdW50');

@$core.Deprecated('Use useItemCmdDescriptor instead')
const UseItemCmd$json = {
  '1': 'UseItemCmd',
  '2': [
    {'1': 'item', '3': 1, '4': 1, '5': 9, '10': 'item'},
    {'1': 'target_city_id', '3': 2, '4': 1, '5': 9, '10': 'targetCityId'},
  ],
};

/// Descriptor for `UseItemCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List useItemCmdDescriptor = $convert.base64Decode(
    'CgpVc2VJdGVtQ21kEhIKBGl0ZW0YASABKAlSBGl0ZW0SJAoOdGFyZ2V0X2NpdHlfaWQYAiABKA'
    'lSDHRhcmdldENpdHlJZA==');

@$core.Deprecated('Use scoutTileCmdDescriptor instead')
const ScoutTileCmd$json = {
  '1': 'ScoutTileCmd',
  '2': [
    {'1': 'pos', '3': 1, '4': 1, '5': 11, '6': '.kd.v1.Vec2', '10': 'pos'},
  ],
};

/// Descriptor for `ScoutTileCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scoutTileCmdDescriptor = $convert.base64Decode(
    'CgxTY291dFRpbGVDbWQSHQoDcG9zGAEgASgLMgsua2QudjEuVmVjMlIDcG9z');

@$core.Deprecated('Use attackMonsterCmdDescriptor instead')
const AttackMonsterCmd$json = {
  '1': 'AttackMonsterCmd',
  '2': [
    {'1': 'city_id', '3': 1, '4': 1, '5': 9, '10': 'cityId'},
    {'1': 'monster_id', '3': 2, '4': 1, '5': 9, '10': 'monsterId'},
  ],
};

/// Descriptor for `AttackMonsterCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attackMonsterCmdDescriptor = $convert.base64Decode(
    'ChBBdHRhY2tNb25zdGVyQ21kEhcKB2NpdHlfaWQYASABKAlSBmNpdHlJZBIdCgptb25zdGVyX2'
    'lkGAIgASgJUgltb25zdGVySWQ=');

@$core.Deprecated('Use gatherCmdDescriptor instead')
const GatherCmd$json = {
  '1': 'GatherCmd',
  '2': [
    {'1': 'city_id', '3': 1, '4': 1, '5': 9, '10': 'cityId'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `GatherCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gatherCmdDescriptor = $convert.base64Decode(
    'CglHYXRoZXJDbWQSFwoHY2l0eV9pZBgBIAEoCVIGY2l0eUlkEhcKB25vZGVfaWQYAiABKAlSBm'
    '5vZGVJZA==');

@$core.Deprecated('Use attackCityCmdDescriptor instead')
const AttackCityCmd$json = {
  '1': 'AttackCityCmd',
  '2': [
    {'1': 'city_id', '3': 1, '4': 1, '5': 9, '10': 'cityId'},
    {'1': 'target_city_id', '3': 2, '4': 1, '5': 9, '10': 'targetCityId'},
  ],
};

/// Descriptor for `AttackCityCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attackCityCmdDescriptor = $convert.base64Decode(
    'Cg1BdHRhY2tDaXR5Q21kEhcKB2NpdHlfaWQYASABKAlSBmNpdHlJZBIkCg50YXJnZXRfY2l0eV'
    '9pZBgCIAEoCVIMdGFyZ2V0Q2l0eUlk');

@$core.Deprecated('Use attackFortCmdDescriptor instead')
const AttackFortCmd$json = {
  '1': 'AttackFortCmd',
  '2': [
    {'1': 'city_id', '3': 1, '4': 1, '5': 9, '10': 'cityId'},
    {'1': 'fort_id', '3': 2, '4': 1, '5': 9, '10': 'fortId'},
  ],
};

/// Descriptor for `AttackFortCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attackFortCmdDescriptor = $convert.base64Decode(
    'Cg1BdHRhY2tGb3J0Q21kEhcKB2NpdHlfaWQYASABKAlSBmNpdHlJZBIXCgdmb3J0X2lkGAIgAS'
    'gJUgZmb3J0SWQ=');

@$core.Deprecated('Use reinforceCmdDescriptor instead')
const ReinforceCmd$json = {
  '1': 'ReinforceCmd',
  '2': [
    {'1': 'city_id', '3': 1, '4': 1, '5': 9, '10': 'cityId'},
    {'1': 'target_city_id', '3': 2, '4': 1, '5': 9, '10': 'targetCityId'},
    {
      '1': 'troops',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.kd.v1.TroopSend',
      '10': 'troops'
    },
  ],
};

/// Descriptor for `ReinforceCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reinforceCmdDescriptor = $convert.base64Decode(
    'CgxSZWluZm9yY2VDbWQSFwoHY2l0eV9pZBgBIAEoCVIGY2l0eUlkEiQKDnRhcmdldF9jaXR5X2'
    'lkGAIgASgJUgx0YXJnZXRDaXR5SWQSKAoGdHJvb3BzGAMgAygLMhAua2QudjEuVHJvb3BTZW5k'
    'UgZ0cm9vcHM=');

@$core.Deprecated('Use transportCmdDescriptor instead')
const TransportCmd$json = {
  '1': 'TransportCmd',
  '2': [
    {'1': 'city_id', '3': 1, '4': 1, '5': 9, '10': 'cityId'},
    {'1': 'target_city_id', '3': 2, '4': 1, '5': 9, '10': 'targetCityId'},
    {
      '1': 'resources',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.Resources',
      '10': 'resources'
    },
  ],
};

/// Descriptor for `TransportCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transportCmdDescriptor = $convert.base64Decode(
    'CgxUcmFuc3BvcnRDbWQSFwoHY2l0eV9pZBgBIAEoCVIGY2l0eUlkEiQKDnRhcmdldF9jaXR5X2'
    'lkGAIgASgJUgx0YXJnZXRDaXR5SWQSLgoJcmVzb3VyY2VzGAMgASgLMhAua2QudjEuUmVzb3Vy'
    'Y2VzUglyZXNvdXJjZXM=');

@$core.Deprecated('Use recallCmdDescriptor instead')
const RecallCmd$json = {
  '1': 'RecallCmd',
  '2': [
    {'1': 'march_id', '3': 1, '4': 1, '5': 9, '10': 'marchId'},
  ],
};

/// Descriptor for `RecallCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recallCmdDescriptor = $convert
    .base64Decode('CglSZWNhbGxDbWQSGQoIbWFyY2hfaWQYASABKAlSB21hcmNoSWQ=');

@$core.Deprecated('Use setShieldCmdDescriptor instead')
const SetShieldCmd$json = {
  '1': 'SetShieldCmd',
  '2': [
    {'1': 'hours', '3': 1, '4': 1, '5': 13, '10': 'hours'},
  ],
};

/// Descriptor for `SetShieldCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setShieldCmdDescriptor =
    $convert.base64Decode('CgxTZXRTaGllbGRDbWQSFAoFaG91cnMYASABKA1SBWhvdXJz');

@$core.Deprecated('Use createAllianceCmdDescriptor instead')
const CreateAllianceCmd$json = {
  '1': 'CreateAllianceCmd',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'tag', '3': 2, '4': 1, '5': 9, '10': 'tag'},
  ],
};

/// Descriptor for `CreateAllianceCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createAllianceCmdDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVBbGxpYW5jZUNtZBISCgRuYW1lGAEgASgJUgRuYW1lEhAKA3RhZxgCIAEoCVIDdG'
    'Fn');

@$core.Deprecated('Use allianceInviteCmdDescriptor instead')
const AllianceInviteCmd$json = {
  '1': 'AllianceInviteCmd',
  '2': [
    {'1': 'player_id', '3': 1, '4': 1, '5': 9, '10': 'playerId'},
  ],
};

/// Descriptor for `AllianceInviteCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allianceInviteCmdDescriptor = $convert.base64Decode(
    'ChFBbGxpYW5jZUludml0ZUNtZBIbCglwbGF5ZXJfaWQYASABKAlSCHBsYXllcklk');

@$core.Deprecated('Use allianceAcceptCmdDescriptor instead')
const AllianceAcceptCmd$json = {
  '1': 'AllianceAcceptCmd',
  '2': [
    {'1': 'alliance_id', '3': 1, '4': 1, '5': 9, '10': 'allianceId'},
  ],
};

/// Descriptor for `AllianceAcceptCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allianceAcceptCmdDescriptor = $convert.base64Decode(
    'ChFBbGxpYW5jZUFjY2VwdENtZBIfCgthbGxpYW5jZV9pZBgBIAEoCVIKYWxsaWFuY2VJZA==');

@$core.Deprecated('Use allianceJoinCmdDescriptor instead')
const AllianceJoinCmd$json = {
  '1': 'AllianceJoinCmd',
  '2': [
    {'1': 'alliance_id', '3': 1, '4': 1, '5': 9, '10': 'allianceId'},
  ],
};

/// Descriptor for `AllianceJoinCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allianceJoinCmdDescriptor = $convert.base64Decode(
    'Cg9BbGxpYW5jZUpvaW5DbWQSHwoLYWxsaWFuY2VfaWQYASABKAlSCmFsbGlhbmNlSWQ=');

@$core.Deprecated('Use allianceLeaveCmdDescriptor instead')
const AllianceLeaveCmd$json = {
  '1': 'AllianceLeaveCmd',
};

/// Descriptor for `AllianceLeaveCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allianceLeaveCmdDescriptor =
    $convert.base64Decode('ChBBbGxpYW5jZUxlYXZlQ21k');

@$core.Deprecated('Use allianceKickCmdDescriptor instead')
const AllianceKickCmd$json = {
  '1': 'AllianceKickCmd',
  '2': [
    {'1': 'player_id', '3': 1, '4': 1, '5': 9, '10': 'playerId'},
  ],
};

/// Descriptor for `AllianceKickCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allianceKickCmdDescriptor = $convert.base64Decode(
    'Cg9BbGxpYW5jZUtpY2tDbWQSGwoJcGxheWVyX2lkGAEgASgJUghwbGF5ZXJJZA==');

@$core.Deprecated('Use allianceHelpCmdDescriptor instead')
const AllianceHelpCmd$json = {
  '1': 'AllianceHelpCmd',
  '2': [
    {'1': 'target_player_id', '3': 1, '4': 1, '5': 9, '10': 'targetPlayerId'},
  ],
};

/// Descriptor for `AllianceHelpCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allianceHelpCmdDescriptor = $convert.base64Decode(
    'Cg9BbGxpYW5jZUhlbHBDbWQSKAoQdGFyZ2V0X3BsYXllcl9pZBgBIAEoCVIOdGFyZ2V0UGxheW'
    'VySWQ=');

@$core.Deprecated('Use rallyCreateCmdDescriptor instead')
const RallyCreateCmd$json = {
  '1': 'RallyCreateCmd',
  '2': [
    {'1': 'city_id', '3': 1, '4': 1, '5': 9, '10': 'cityId'},
    {
      '1': 'target_pos',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.Vec2',
      '10': 'targetPos'
    },
    {'1': 'start_at_unix_ms', '3': 3, '4': 1, '5': 3, '10': 'startAtUnixMs'},
  ],
};

/// Descriptor for `RallyCreateCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rallyCreateCmdDescriptor = $convert.base64Decode(
    'Cg5SYWxseUNyZWF0ZUNtZBIXCgdjaXR5X2lkGAEgASgJUgZjaXR5SWQSKgoKdGFyZ2V0X3Bvcx'
    'gCIAEoCzILLmtkLnYxLlZlYzJSCXRhcmdldFBvcxInChBzdGFydF9hdF91bml4X21zGAMgASgD'
    'Ug1zdGFydEF0VW5peE1z');

@$core.Deprecated('Use rallyJoinCmdDescriptor instead')
const RallyJoinCmd$json = {
  '1': 'RallyJoinCmd',
  '2': [
    {'1': 'rally_id', '3': 1, '4': 1, '5': 9, '10': 'rallyId'},
    {
      '1': 'troops',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.kd.v1.TroopSend',
      '10': 'troops'
    },
  ],
};

/// Descriptor for `RallyJoinCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rallyJoinCmdDescriptor = $convert.base64Decode(
    'CgxSYWxseUpvaW5DbWQSGQoIcmFsbHlfaWQYASABKAlSB3JhbGx5SWQSKAoGdHJvb3BzGAIgAy'
    'gLMhAua2QudjEuVHJvb3BTZW5kUgZ0cm9vcHM=');

@$core.Deprecated('Use rallyCancelCmdDescriptor instead')
const RallyCancelCmd$json = {
  '1': 'RallyCancelCmd',
  '2': [
    {'1': 'rally_id', '3': 1, '4': 1, '5': 9, '10': 'rallyId'},
  ],
};

/// Descriptor for `RallyCancelCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rallyCancelCmdDescriptor = $convert.base64Decode(
    'Cg5SYWxseUNhbmNlbENtZBIZCghyYWxseV9pZBgBIAEoCVIHcmFsbHlJZA==');

@$core.Deprecated('Use chatCmdDescriptor instead')
const ChatCmd$json = {
  '1': 'ChatCmd',
  '2': [
    {'1': 'scope', '3': 1, '4': 1, '5': 9, '10': 'scope'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    {'1': 'target_id', '3': 3, '4': 1, '5': 9, '10': 'targetId'},
  ],
};

/// Descriptor for `ChatCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatCmdDescriptor = $convert.base64Decode(
    'CgdDaGF0Q21kEhQKBXNjb3BlGAEgASgJUgVzY29wZRISCgR0ZXh0GAIgASgJUgR0ZXh0EhsKCX'
    'RhcmdldF9pZBgDIAEoCVIIdGFyZ2V0SWQ=');

@$core.Deprecated('Use switchCapitalCmdDescriptor instead')
const SwitchCapitalCmd$json = {
  '1': 'SwitchCapitalCmd',
  '2': [
    {'1': 'city_id', '3': 1, '4': 1, '5': 9, '10': 'cityId'},
  ],
};

/// Descriptor for `SwitchCapitalCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List switchCapitalCmdDescriptor = $convert.base64Decode(
    'ChBTd2l0Y2hDYXBpdGFsQ21kEhcKB2NpdHlfaWQYASABKAlSBmNpdHlJZA==');

@$core.Deprecated('Use recruitHeroCmdDescriptor instead')
const RecruitHeroCmd$json = {
  '1': 'RecruitHeroCmd',
  '2': [
    {'1': 'hero', '3': 1, '4': 1, '5': 9, '10': 'hero'},
  ],
};

/// Descriptor for `RecruitHeroCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recruitHeroCmdDescriptor =
    $convert.base64Decode('Cg5SZWNydWl0SGVyb0NtZBISCgRoZXJvGAEgASgJUgRoZXJv');

@$core.Deprecated('Use demolishBuildingCmdDescriptor instead')
const DemolishBuildingCmd$json = {
  '1': 'DemolishBuildingCmd',
  '2': [
    {'1': 'city_id', '3': 1, '4': 1, '5': 9, '10': 'cityId'},
    {'1': 'building', '3': 2, '4': 1, '5': 9, '10': 'building'},
  ],
};

/// Descriptor for `DemolishBuildingCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List demolishBuildingCmdDescriptor = $convert.base64Decode(
    'ChNEZW1vbGlzaEJ1aWxkaW5nQ21kEhcKB2NpdHlfaWQYASABKAlSBmNpdHlJZBIaCghidWlsZG'
    'luZxgCIAEoCVIIYnVpbGRpbmc=');

@$core.Deprecated('Use marketBuyCmdDescriptor instead')
const MarketBuyCmd$json = {
  '1': 'MarketBuyCmd',
  '2': [
    {'1': 'item', '3': 1, '4': 1, '5': 9, '10': 'item'},
    {'1': 'qty', '3': 2, '4': 1, '5': 13, '10': 'qty'},
  ],
};

/// Descriptor for `MarketBuyCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketBuyCmdDescriptor = $convert.base64Decode(
    'CgxNYXJrZXRCdXlDbWQSEgoEaXRlbRgBIAEoCVIEaXRlbRIQCgNxdHkYAiABKA1SA3F0eQ==');

@$core.Deprecated('Use marketSellCmdDescriptor instead')
const MarketSellCmd$json = {
  '1': 'MarketSellCmd',
  '2': [
    {'1': 'item', '3': 1, '4': 1, '5': 9, '10': 'item'},
    {'1': 'qty', '3': 2, '4': 1, '5': 13, '10': 'qty'},
  ],
};

/// Descriptor for `MarketSellCmd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketSellCmdDescriptor = $convert.base64Decode(
    'Cg1NYXJrZXRTZWxsQ21kEhIKBGl0ZW0YASABKAlSBGl0ZW0SEAoDcXR5GAIgASgNUgNxdHk=');

@$core.Deprecated('Use troopSendDescriptor instead')
const TroopSend$json = {
  '1': 'TroopSend',
  '2': [
    {'1': 'unit', '3': 1, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'tier', '3': 2, '4': 1, '5': 13, '10': 'tier'},
    {'1': 'count', '3': 3, '4': 1, '5': 13, '10': 'count'},
  ],
};

/// Descriptor for `TroopSend`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List troopSendDescriptor = $convert.base64Decode(
    'CglUcm9vcFNlbmQSEgoEdW5pdBgBIAEoCVIEdW5pdBISCgR0aWVyGAIgASgNUgR0aWVyEhQKBW'
    'NvdW50GAMgASgNUgVjb3VudA==');

@$core.Deprecated('Use wsEnvelopeDescriptor instead')
const WsEnvelope$json = {
  '1': 'WsEnvelope',
  '2': [
    {'1': 'seq', '3': 1, '4': 1, '5': 4, '10': 'seq'},
    {
      '1': 'hello',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.WsHello',
      '9': 0,
      '10': 'hello'
    },
    {
      '1': 'command',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.SubmitCommandRequest',
      '9': 0,
      '10': 'command'
    },
    {
      '1': 'command_result',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.CommandResult',
      '9': 0,
      '10': 'commandResult'
    },
    {
      '1': 'delta',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.DeltaEvent',
      '9': 0,
      '10': 'delta'
    },
    {
      '1': 'snapshot',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.Snapshot',
      '9': 0,
      '10': 'snapshot'
    },
    {
      '1': 'heartbeat',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.Heartbeat',
      '9': 0,
      '10': 'heartbeat'
    },
    {
      '1': 'error',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.ErrorMessage',
      '9': 0,
      '10': 'error'
    },
    {
      '1': 'subscription',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.kd.v1.SubscriptionUpdate',
      '9': 0,
      '10': 'subscription'
    },
  ],
  '8': [
    {'1': 'body'},
  ],
};

/// Descriptor for `WsEnvelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wsEnvelopeDescriptor = $convert.base64Decode(
    'CgpXc0VudmVsb3BlEhAKA3NlcRgBIAEoBFIDc2VxEiYKBWhlbGxvGAIgASgLMg4ua2QudjEuV3'
    'NIZWxsb0gAUgVoZWxsbxI3Cgdjb21tYW5kGAMgASgLMhsua2QudjEuU3VibWl0Q29tbWFuZFJl'
    'cXVlc3RIAFIHY29tbWFuZBI9Cg5jb21tYW5kX3Jlc3VsdBgEIAEoCzIULmtkLnYxLkNvbW1hbm'
    'RSZXN1bHRIAFINY29tbWFuZFJlc3VsdBIpCgVkZWx0YRgFIAEoCzIRLmtkLnYxLkRlbHRhRXZl'
    'bnRIAFIFZGVsdGESLQoIc25hcHNob3QYBiABKAsyDy5rZC52MS5TbmFwc2hvdEgAUghzbmFwc2'
    'hvdBIwCgloZWFydGJlYXQYByABKAsyEC5rZC52MS5IZWFydGJlYXRIAFIJaGVhcnRiZWF0EisK'
    'BWVycm9yGAggASgLMhMua2QudjEuRXJyb3JNZXNzYWdlSABSBWVycm9yEj8KDHN1YnNjcmlwdG'
    'lvbhgJIAEoCzIZLmtkLnYxLlN1YnNjcmlwdGlvblVwZGF0ZUgAUgxzdWJzY3JpcHRpb25CBgoE'
    'Ym9keQ==');

@$core.Deprecated('Use wsHelloDescriptor instead')
const WsHello$json = {
  '1': 'WsHello',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {'1': 'realm_id', '3': 2, '4': 1, '5': 9, '10': 'realmId'},
    {
      '1': 'chunks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.kd.v1.Vec2',
      '10': 'chunks'
    },
    {'1': 'cursor', '3': 4, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `WsHello`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wsHelloDescriptor = $convert.base64Decode(
    'CgdXc0hlbGxvEhQKBXRva2VuGAEgASgJUgV0b2tlbhIZCghyZWFsbV9pZBgCIAEoCVIHcmVhbG'
    '1JZBIjCgZjaHVua3MYAyADKAsyCy5rZC52MS5WZWMyUgZjaHVua3MSFgoGY3Vyc29yGAQgASgJ'
    'UgZjdXJzb3I=');

@$core.Deprecated('Use heartbeatDescriptor instead')
const Heartbeat$json = {
  '1': 'Heartbeat',
  '2': [
    {
      '1': 'client_time_unix_ms',
      '3': 1,
      '4': 1,
      '5': 3,
      '10': 'clientTimeUnixMs'
    },
  ],
};

/// Descriptor for `Heartbeat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List heartbeatDescriptor = $convert.base64Decode(
    'CglIZWFydGJlYXQSLQoTY2xpZW50X3RpbWVfdW5peF9tcxgBIAEoA1IQY2xpZW50VGltZVVuaX'
    'hNcw==');

@$core.Deprecated('Use errorMessageDescriptor instead')
const ErrorMessage$json = {
  '1': 'ErrorMessage',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.kd.v1.ErrorCode',
      '10': 'code'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ErrorMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errorMessageDescriptor = $convert.base64Decode(
    'CgxFcnJvck1lc3NhZ2USJAoEY29kZRgBIAEoDjIQLmtkLnYxLkVycm9yQ29kZVIEY29kZRIYCg'
    'dtZXNzYWdlGAIgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use subscriptionUpdateDescriptor instead')
const SubscriptionUpdate$json = {
  '1': 'SubscriptionUpdate',
  '2': [
    {
      '1': 'chunks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.kd.v1.Vec2',
      '10': 'chunks'
    },
    {'1': 'all_private', '3': 2, '4': 1, '5': 8, '10': 'allPrivate'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `SubscriptionUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscriptionUpdateDescriptor = $convert.base64Decode(
    'ChJTdWJzY3JpcHRpb25VcGRhdGUSIwoGY2h1bmtzGAEgAygLMgsua2QudjEuVmVjMlIGY2h1bm'
    'tzEh8KC2FsbF9wcml2YXRlGAIgASgIUgphbGxQcml2YXRlEhYKBmN1cnNvchgDIAEoCVIGY3Vy'
    'c29y');

@$core.Deprecated('Use deltaEventDescriptor instead')
const DeltaEvent$json = {
  '1': 'DeltaEvent',
  '2': [
    {'1': 'event_id', '3': 1, '4': 1, '5': 9, '10': 'eventId'},
    {'1': 'realm_id', '3': 2, '4': 1, '5': 9, '10': 'realmId'},
    {'1': 'event_type', '3': 3, '4': 1, '5': 9, '10': 'eventType'},
    {'1': 'pos', '3': 4, '4': 1, '5': 11, '6': '.kd.v1.Vec2', '10': 'pos'},
    {'1': 'has_pos', '3': 12, '4': 1, '5': 8, '10': 'hasPos'},
    {'1': 'owner_player_id', '3': 5, '4': 1, '5': 9, '10': 'ownerPlayerId'},
    {'1': 'private', '3': 6, '4': 1, '5': 8, '10': 'private'},
    {'1': 'visible_players', '3': 7, '4': 3, '5': 9, '10': 'visiblePlayers'},
    {
      '1': 'server_time_unix_ms',
      '3': 8,
      '4': 1,
      '5': 3,
      '10': 'serverTimeUnixMs'
    },
    {'1': 'payload_json', '3': 9, '4': 1, '5': 12, '10': 'payloadJson'},
    {'1': 'cursor', '3': 10, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `DeltaEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deltaEventDescriptor = $convert.base64Decode(
    'CgpEZWx0YUV2ZW50EhkKCGV2ZW50X2lkGAEgASgJUgdldmVudElkEhkKCHJlYWxtX2lkGAIgAS'
    'gJUgdyZWFsbUlkEh0KCmV2ZW50X3R5cGUYAyABKAlSCWV2ZW50VHlwZRIdCgNwb3MYBCABKAsy'
    'Cy5rZC52MS5WZWMyUgNwb3MSFwoHaGFzX3BvcxgMIAEoCFIGaGFzUG9zEiYKD293bmVyX3BsYX'
    'llcl9pZBgFIAEoCVINb3duZXJQbGF5ZXJJZBIYCgdwcml2YXRlGAYgASgIUgdwcml2YXRlEicK'
    'D3Zpc2libGVfcGxheWVycxgHIAMoCVIOdmlzaWJsZVBsYXllcnMSLQoTc2VydmVyX3RpbWVfdW'
    '5peF9tcxgIIAEoA1IQc2VydmVyVGltZVVuaXhNcxIhCgxwYXlsb2FkX2pzb24YCSABKAxSC3Bh'
    'eWxvYWRKc29uEhYKBmN1cnNvchgKIAEoCVIGY3Vyc29y');

@$core.Deprecated('Use snapshotDescriptor instead')
const Snapshot$json = {
  '1': 'Snapshot',
  '2': [
    {'1': 'realm_id', '3': 1, '4': 1, '5': 9, '10': 'realmId'},
    {'1': 'version', '3': 2, '4': 1, '5': 4, '10': 'version'},
    {'1': 'state_json', '3': 3, '4': 1, '5': 12, '10': 'stateJson'},
    {'1': 'map_json', '3': 4, '4': 1, '5': 12, '10': 'mapJson'},
    {
      '1': 'server_time_unix_ms',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'serverTimeUnixMs'
    },
    {'1': 'cursor', '3': 6, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `Snapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List snapshotDescriptor = $convert.base64Decode(
    'CghTbmFwc2hvdBIZCghyZWFsbV9pZBgBIAEoCVIHcmVhbG1JZBIYCgd2ZXJzaW9uGAIgASgEUg'
    'd2ZXJzaW9uEh0KCnN0YXRlX2pzb24YAyABKAxSCXN0YXRlSnNvbhIZCghtYXBfanNvbhgEIAEo'
    'DFIHbWFwSnNvbhItChNzZXJ2ZXJfdGltZV91bml4X21zGAUgASgDUhBzZXJ2ZXJUaW1lVW5peE'
    '1zEhYKBmN1cnNvchgGIAEoCVIGY3Vyc29y');
