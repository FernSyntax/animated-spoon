# Kingdoms of Dominion client

Flutter + Flame client for the persistent realm game. The home screen, map,
city, construction, troop, research and hero views share the original low-poly
kingdom art in `assets/art/`.

## Local web build

```sh
flutter pub get
flutter build web --release --dart-define=KD_GATEWAY=http://localhost:8080
cd build/web && python3 -m http.server 8090 --bind 0.0.0.0
```

Open `http://localhost:8090/`. Sign in with a local development account and
enter a realm. On the World Map, drag to pan, pinch or use the zoom controls,
then tap monsters, player cities, forts or resource nodes to open their game
actions. Panning loads the surrounding server chunks. Scout a player city
before attacking it.

Use **City → Manage buildings** for construction upgrades. Each city has one
durable server queue; the city and building screens show its current target and
countdown. Progress continues while the client is closed.
