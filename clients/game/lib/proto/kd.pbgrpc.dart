// This is a generated file - do not edit.
//
// Generated from kd.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'kd.pb.dart' as $0;

export 'kd.pb.dart';

@$pb.GrpcServiceName('kd.v1.ControlPlane')
class ControlPlaneClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ControlPlaneClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.RegisterResponse> register(
    $0.RegisterRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$register, request, options: options);
  }

  $grpc.ResponseFuture<$0.LoginResponse> login(
    $0.LoginRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$login, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> logout(
    $0.LogoutRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$logout, request, options: options);
  }

  $grpc.ResponseFuture<$0.ValidateResponse> validate(
    $0.ValidateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$validate, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListRealmsResponse> listRealms(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listRealms, request, options: options);
  }

  $grpc.ResponseFuture<$0.JoinRealmResponse> joinRealm(
    $0.JoinRealmRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$joinRealm, request, options: options);
  }

  $grpc.ResponseFuture<$0.CreateRealmResponse> createRealm(
    $0.CreateRealmRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createRealm, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetRealmRouteResponse> getRealmRoute(
    $0.GetRealmRouteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getRealmRoute, request, options: options);
  }

  // method descriptors

  static final _$register =
      $grpc.ClientMethod<$0.RegisterRequest, $0.RegisterResponse>(
          '/kd.v1.ControlPlane/Register',
          ($0.RegisterRequest value) => value.writeToBuffer(),
          $0.RegisterResponse.fromBuffer);
  static final _$login = $grpc.ClientMethod<$0.LoginRequest, $0.LoginResponse>(
      '/kd.v1.ControlPlane/Login',
      ($0.LoginRequest value) => value.writeToBuffer(),
      $0.LoginResponse.fromBuffer);
  static final _$logout = $grpc.ClientMethod<$0.LogoutRequest, $0.Empty>(
      '/kd.v1.ControlPlane/Logout',
      ($0.LogoutRequest value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
  static final _$validate =
      $grpc.ClientMethod<$0.ValidateRequest, $0.ValidateResponse>(
          '/kd.v1.ControlPlane/Validate',
          ($0.ValidateRequest value) => value.writeToBuffer(),
          $0.ValidateResponse.fromBuffer);
  static final _$listRealms =
      $grpc.ClientMethod<$0.Empty, $0.ListRealmsResponse>(
          '/kd.v1.ControlPlane/ListRealms',
          ($0.Empty value) => value.writeToBuffer(),
          $0.ListRealmsResponse.fromBuffer);
  static final _$joinRealm =
      $grpc.ClientMethod<$0.JoinRealmRequest, $0.JoinRealmResponse>(
          '/kd.v1.ControlPlane/JoinRealm',
          ($0.JoinRealmRequest value) => value.writeToBuffer(),
          $0.JoinRealmResponse.fromBuffer);
  static final _$createRealm =
      $grpc.ClientMethod<$0.CreateRealmRequest, $0.CreateRealmResponse>(
          '/kd.v1.ControlPlane/CreateRealm',
          ($0.CreateRealmRequest value) => value.writeToBuffer(),
          $0.CreateRealmResponse.fromBuffer);
  static final _$getRealmRoute =
      $grpc.ClientMethod<$0.GetRealmRouteRequest, $0.GetRealmRouteResponse>(
          '/kd.v1.ControlPlane/GetRealmRoute',
          ($0.GetRealmRouteRequest value) => value.writeToBuffer(),
          $0.GetRealmRouteResponse.fromBuffer);
}

@$pb.GrpcServiceName('kd.v1.ControlPlane')
abstract class ControlPlaneServiceBase extends $grpc.Service {
  $core.String get $name => 'kd.v1.ControlPlane';

  ControlPlaneServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.RegisterRequest, $0.RegisterResponse>(
        'Register',
        register_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RegisterRequest.fromBuffer(value),
        ($0.RegisterResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LoginRequest, $0.LoginResponse>(
        'Login',
        login_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LoginRequest.fromBuffer(value),
        ($0.LoginResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LogoutRequest, $0.Empty>(
        'Logout',
        logout_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LogoutRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ValidateRequest, $0.ValidateResponse>(
        'Validate',
        validate_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ValidateRequest.fromBuffer(value),
        ($0.ValidateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ListRealmsResponse>(
        'ListRealms',
        listRealms_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ListRealmsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.JoinRealmRequest, $0.JoinRealmResponse>(
        'JoinRealm',
        joinRealm_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.JoinRealmRequest.fromBuffer(value),
        ($0.JoinRealmResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CreateRealmRequest, $0.CreateRealmResponse>(
            'CreateRealm',
            createRealm_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateRealmRequest.fromBuffer(value),
            ($0.CreateRealmResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetRealmRouteRequest, $0.GetRealmRouteResponse>(
            'GetRealmRoute',
            getRealmRoute_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetRealmRouteRequest.fromBuffer(value),
            ($0.GetRealmRouteResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.RegisterResponse> register_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RegisterRequest> $request) async {
    return register($call, await $request);
  }

  $async.Future<$0.RegisterResponse> register(
      $grpc.ServiceCall call, $0.RegisterRequest request);

  $async.Future<$0.LoginResponse> login_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LoginRequest> $request) async {
    return login($call, await $request);
  }

  $async.Future<$0.LoginResponse> login(
      $grpc.ServiceCall call, $0.LoginRequest request);

  $async.Future<$0.Empty> logout_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LogoutRequest> $request) async {
    return logout($call, await $request);
  }

  $async.Future<$0.Empty> logout(
      $grpc.ServiceCall call, $0.LogoutRequest request);

  $async.Future<$0.ValidateResponse> validate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ValidateRequest> $request) async {
    return validate($call, await $request);
  }

  $async.Future<$0.ValidateResponse> validate(
      $grpc.ServiceCall call, $0.ValidateRequest request);

  $async.Future<$0.ListRealmsResponse> listRealms_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return listRealms($call, await $request);
  }

  $async.Future<$0.ListRealmsResponse> listRealms(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.JoinRealmResponse> joinRealm_Pre($grpc.ServiceCall $call,
      $async.Future<$0.JoinRealmRequest> $request) async {
    return joinRealm($call, await $request);
  }

  $async.Future<$0.JoinRealmResponse> joinRealm(
      $grpc.ServiceCall call, $0.JoinRealmRequest request);

  $async.Future<$0.CreateRealmResponse> createRealm_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateRealmRequest> $request) async {
    return createRealm($call, await $request);
  }

  $async.Future<$0.CreateRealmResponse> createRealm(
      $grpc.ServiceCall call, $0.CreateRealmRequest request);

  $async.Future<$0.GetRealmRouteResponse> getRealmRoute_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetRealmRouteRequest> $request) async {
    return getRealmRoute($call, await $request);
  }

  $async.Future<$0.GetRealmRouteResponse> getRealmRoute(
      $grpc.ServiceCall call, $0.GetRealmRouteRequest request);
}

@$pb.GrpcServiceName('kd.v1.RealmService')
class RealmServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  RealmServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.CommandResult> submitCommand(
    $0.SubmitCommandRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$submitCommand, request, options: options);
  }

  $grpc.ResponseFuture<$0.SnapshotResponse> getSnapshot(
    $0.SnapshotRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSnapshot, request, options: options);
  }

  $grpc.ResponseFuture<$0.WorkerHealth> health(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$health, request, options: options);
  }

  $grpc.ResponseFuture<$0.EnsurePlayerResponse> ensurePlayer(
    $0.EnsurePlayerRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$ensurePlayer, request, options: options);
  }

  /// Dev/test only: disabled in production builds and when dev_mode=false.
  $grpc.ResponseFuture<$0.AdvanceClockResponse> advanceClock(
    $0.AdvanceClockRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$advanceClock, request, options: options);
  }

  // method descriptors

  static final _$submitCommand =
      $grpc.ClientMethod<$0.SubmitCommandRequest, $0.CommandResult>(
          '/kd.v1.RealmService/SubmitCommand',
          ($0.SubmitCommandRequest value) => value.writeToBuffer(),
          $0.CommandResult.fromBuffer);
  static final _$getSnapshot =
      $grpc.ClientMethod<$0.SnapshotRequest, $0.SnapshotResponse>(
          '/kd.v1.RealmService/GetSnapshot',
          ($0.SnapshotRequest value) => value.writeToBuffer(),
          $0.SnapshotResponse.fromBuffer);
  static final _$health = $grpc.ClientMethod<$0.Empty, $0.WorkerHealth>(
      '/kd.v1.RealmService/Health',
      ($0.Empty value) => value.writeToBuffer(),
      $0.WorkerHealth.fromBuffer);
  static final _$ensurePlayer =
      $grpc.ClientMethod<$0.EnsurePlayerRequest, $0.EnsurePlayerResponse>(
          '/kd.v1.RealmService/EnsurePlayer',
          ($0.EnsurePlayerRequest value) => value.writeToBuffer(),
          $0.EnsurePlayerResponse.fromBuffer);
  static final _$advanceClock =
      $grpc.ClientMethod<$0.AdvanceClockRequest, $0.AdvanceClockResponse>(
          '/kd.v1.RealmService/AdvanceClock',
          ($0.AdvanceClockRequest value) => value.writeToBuffer(),
          $0.AdvanceClockResponse.fromBuffer);
}

@$pb.GrpcServiceName('kd.v1.RealmService')
abstract class RealmServiceBase extends $grpc.Service {
  $core.String get $name => 'kd.v1.RealmService';

  RealmServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SubmitCommandRequest, $0.CommandResult>(
        'SubmitCommand',
        submitCommand_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SubmitCommandRequest.fromBuffer(value),
        ($0.CommandResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SnapshotRequest, $0.SnapshotResponse>(
        'GetSnapshot',
        getSnapshot_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SnapshotRequest.fromBuffer(value),
        ($0.SnapshotResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.WorkerHealth>(
        'Health',
        health_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.WorkerHealth value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.EnsurePlayerRequest, $0.EnsurePlayerResponse>(
            'EnsurePlayer',
            ensurePlayer_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.EnsurePlayerRequest.fromBuffer(value),
            ($0.EnsurePlayerResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AdvanceClockRequest, $0.AdvanceClockResponse>(
            'AdvanceClock',
            advanceClock_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AdvanceClockRequest.fromBuffer(value),
            ($0.AdvanceClockResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.CommandResult> submitCommand_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SubmitCommandRequest> $request) async {
    return submitCommand($call, await $request);
  }

  $async.Future<$0.CommandResult> submitCommand(
      $grpc.ServiceCall call, $0.SubmitCommandRequest request);

  $async.Future<$0.SnapshotResponse> getSnapshot_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SnapshotRequest> $request) async {
    return getSnapshot($call, await $request);
  }

  $async.Future<$0.SnapshotResponse> getSnapshot(
      $grpc.ServiceCall call, $0.SnapshotRequest request);

  $async.Future<$0.WorkerHealth> health_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return health($call, await $request);
  }

  $async.Future<$0.WorkerHealth> health(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.EnsurePlayerResponse> ensurePlayer_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.EnsurePlayerRequest> $request) async {
    return ensurePlayer($call, await $request);
  }

  $async.Future<$0.EnsurePlayerResponse> ensurePlayer(
      $grpc.ServiceCall call, $0.EnsurePlayerRequest request);

  $async.Future<$0.AdvanceClockResponse> advanceClock_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AdvanceClockRequest> $request) async {
    return advanceClock($call, await $request);
  }

  $async.Future<$0.AdvanceClockResponse> advanceClock(
      $grpc.ServiceCall call, $0.AdvanceClockRequest request);
}
