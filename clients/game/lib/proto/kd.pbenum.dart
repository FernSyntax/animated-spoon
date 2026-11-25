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

import 'package:protobuf/protobuf.dart' as $pb;

class ErrorCode extends $pb.ProtobufEnum {
  static const ErrorCode ERROR_CODE_UNSPECIFIED =
      ErrorCode._(0, _omitEnumNames ? '' : 'ERROR_CODE_UNSPECIFIED');
  static const ErrorCode OK = ErrorCode._(1, _omitEnumNames ? '' : 'OK');
  static const ErrorCode UNAUTHENTICATED =
      ErrorCode._(2, _omitEnumNames ? '' : 'UNAUTHENTICATED');
  static const ErrorCode PERMISSION_DENIED =
      ErrorCode._(3, _omitEnumNames ? '' : 'PERMISSION_DENIED');
  static const ErrorCode NOT_FOUND =
      ErrorCode._(4, _omitEnumNames ? '' : 'NOT_FOUND');
  static const ErrorCode INVALID_ARGUMENT =
      ErrorCode._(5, _omitEnumNames ? '' : 'INVALID_ARGUMENT');
  static const ErrorCode CONFLICT =
      ErrorCode._(6, _omitEnumNames ? '' : 'CONFLICT');
  static const ErrorCode INSUFFICIENT_RESOURCES =
      ErrorCode._(7, _omitEnumNames ? '' : 'INSUFFICIENT_RESOURCES');
  static const ErrorCode INSUFFICIENT_TROOPS =
      ErrorCode._(8, _omitEnumNames ? '' : 'INSUFFICIENT_TROOPS');
  static const ErrorCode PREREQUISITE_UNMET =
      ErrorCode._(9, _omitEnumNames ? '' : 'PREREQUISITE_UNMET');
  static const ErrorCode QUEUE_FULL =
      ErrorCode._(10, _omitEnumNames ? '' : 'QUEUE_FULL');
  static const ErrorCode BUSY = ErrorCode._(11, _omitEnumNames ? '' : 'BUSY');
  static const ErrorCode STALE_VERSION =
      ErrorCode._(12, _omitEnumNames ? '' : 'STALE_VERSION');
  static const ErrorCode CROSS_REALM =
      ErrorCode._(13, _omitEnumNames ? '' : 'CROSS_REALM');
  static const ErrorCode RATE_LIMITED =
      ErrorCode._(14, _omitEnumNames ? '' : 'RATE_LIMITED');
  static const ErrorCode SHIELDED =
      ErrorCode._(15, _omitEnumNames ? '' : 'SHIELDED');
  static const ErrorCode NO_TARGET =
      ErrorCode._(16, _omitEnumNames ? '' : 'NO_TARGET');
  static const ErrorCode INTERNAL =
      ErrorCode._(17, _omitEnumNames ? '' : 'INTERNAL');
  static const ErrorCode DUPLICATE =
      ErrorCode._(18, _omitEnumNames ? '' : 'DUPLICATE');
  static const ErrorCode NOT_OWNER =
      ErrorCode._(19, _omitEnumNames ? '' : 'NOT_OWNER');

  static const $core.List<ErrorCode> values = <ErrorCode>[
    ERROR_CODE_UNSPECIFIED,
    OK,
    UNAUTHENTICATED,
    PERMISSION_DENIED,
    NOT_FOUND,
    INVALID_ARGUMENT,
    CONFLICT,
    INSUFFICIENT_RESOURCES,
    INSUFFICIENT_TROOPS,
    PREREQUISITE_UNMET,
    QUEUE_FULL,
    BUSY,
    STALE_VERSION,
    CROSS_REALM,
    RATE_LIMITED,
    SHIELDED,
    NO_TARGET,
    INTERNAL,
    DUPLICATE,
    NOT_OWNER,
  ];

  static final $core.List<ErrorCode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 19);
  static ErrorCode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ErrorCode._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
