/// Feature screens for the Flutter client.
///
/// Every screen is a thin, declarative view over [GameState]. The server is
/// authoritative: screens only render snapshots and submit typed commands.
/// Navigation is centralised in [HomeShell]; mutating widgets call
/// `GameState.submit` rather than changing gameplay state locally.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:fixnum/fixnum.dart';
import 'package:flame/game.dart' as flame;
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'catalog.dart';
import 'game_config.dart';
import 'map.dart';
import 'proto/kd.pb.dart';
import 'state.dart';

part 'ui/theme.dart';
part 'ui/widgets.dart';
part 'ui/shell.dart';
part 'ui/city.dart';
part 'ui/city_widgets.dart';
part 'ui/buildings.dart';
part 'ui/research.dart';
part 'ui/troops.dart';
part 'ui/heroes_items.dart';
part 'ui/market.dart';
part 'ui/world.dart';
part 'ui/marches.dart';
part 'ui/alliance.dart';
part 'ui/chat.dart';
part 'ui/reports.dart';
part 'ui/rankings.dart';
part 'ui/settings.dart';
part 'ui/shop.dart';
