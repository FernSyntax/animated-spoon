import 'game_config.dart';

/// Client-side presentation catalog. Server remains authoritative for costs,
/// effects, prerequisites and timing; these are labels only.
const buildings = buildingsLabels;
const buildingLore = {
  'town_hall': 'Your seat of power. Raises your city’s level ceiling.',
  'farm': 'Feeds the city and keeps the army in the field.',
  'lumber_mill': 'Turns the surrounding forest into building timber.',
  'quarry': 'Produces stone for walls and civic works.',
  'iron_mine': 'Supplies the metal behind stronger armies.',
  'market': 'Expands your treasury and the reach of trade.',
  'warehouse': 'Protects the stores that fuel your next campaign.',
  'barracks': 'Trains the soldiers who defend and conquer.',
  'academy': 'Unlocks research that strengthens your realm.',
  'wall': 'Makes every attack on your city more costly.',
  'hospital': 'Gives wounded defenders a chance to return.',
  'embassy': 'Coordinates allied support and rallying forces.',
};
const techs = techsLabels;
const units = unitLabels;
const heroes = heroesLabels;
const heroRecruitGold = {
  'aurora': 1200,
  'borin': 1000,
  'cinder': 1800,
  'dalia': 1500,
  'eorin': 1600,
  'faye': 1700,
};
const items = {
  'bundle_small': 'Small Supply Bundle',
  'bundle_large': 'Large Supply Bundle',
  'speed_5m': '5 Minute Speedup',
  'speed_1h': '1 Hour Speedup',
  'shield_1d': '1 Day Shield',
  'scout_kit': 'Scout Kit',
};
const missions = {
  'scout': 'Scout',
  'monster': 'Hunt',
  'gather': 'Gather',
  'attack_city': 'Attack City',
  'attack_fort': 'Attack Fort',
  'rally_attack': 'Rally',
  'reinforce': 'Reinforce',
  'transport': 'Transport',
};
