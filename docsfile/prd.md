### **Project Architecture Overview**

We are using a **Hybrid Architecture**:

  * **Flutter (The Shell):** Handles the Main Menu, HUD (Heads Up Display), Game Over screens, and Level Select.
  * **Flame (The Engine):** Handles the Map, Entities (Towers/Enemies), Physics, and Input inside the game view.

-----

### **Phase 1: Project Setup & Asset Configuration (Day 1)**

**Goal:** A compile-ready repo with all assets in place.

1.  **Dependencies (`pubspec.yaml`):**
      * `flame: ^1.x.x`
      * `flame_tiled: ^1.x.x` (For maps)
      * `flame_audio: ^1.x.x` (For SFX)
      * `provider` or `riverpod` (For state management between Flutter and Flame).
      * `shared_preferences` (For saving unlocked levels).
2.  **Screen Config:**
      * Force **Landscape Mode** only in `AndroidManifest.xml` and `Info.plist`.
      * Flame `CameraComponent`: Set to `FixedResolutionViewport` (Target: 640x360 pixels - pixel art style).
3.  **Asset Folder Structure:**
    ```text
    assets/
      images/
        tilemap_packed.png  (The spritesheet)
        chicken_tower.png
        fox_enemy.png
        egg_projectile.png
      audio/
        bgm_farm.mp3
        sfx_pop.wav
        sfx_cluck.wav
      tiles/
        level1.tmx (Created in Tiled Editor)
    ```

-----

### **Phase 2: The Map & Data Layer (Day 2)**

**Goal:** Render the level and define the grid.

1.  **Tiled Editor Work:**
      * Create a 20x12 grid map (fit for mobile aspect ratio).
      * **Layer 1 (Ground):** Grass tiles everywhere.
      * **Layer 2 (Path):** Dirt tiles forming a path from Left to Right.
      * **Layer 3 (Object Layer):** Add "Point Objects" named `SpawnPoint`, `Corner1`, `Corner2`, `EndPoint`.
2.  **Code Implementation:**
      * Load map: `await TiledComponent.load('level1.tmx', Vector2.all(32));`
      * **Grid Logic:** Create a 2D Array `int grid[rows][cols]` in memory.
          * Iterate through the Tiled map. If a tile ID matches "Path", mark `grid[x][y] = 0` (Non-buildable). If "Grass", mark `grid[x][y] = 1` (Buildable).

-----

### **Phase 3: The Enemy Loop (Days 3-4)**

**Goal:** Enemies spawn, follow the path, and handle "Game Over" logic.

1.  **Class: `Enemy` (extends `SpriteAnimationComponent`)**

      * **Stats:** `hp = 20`, `speed = 80`.
      * **Movement Logic:**
          * On `onLoad`, read the `Object Layer` from Tiled.
          * Create a list of `Vector2` waypoints: `[SpawnPoint, Corner1, Corner2, EndPoint]`.
          * Use Flame’s `MoveToEffect` to move from current point to next point.
      * **End of Path Logic:**
          * If `distanceTo(EndPoint) < 5px`:
              * Trigger `gameState.decrementLives()`.
              * `removeFromParent()`.

2.  **Wave Manager:**

      * Create a `Timer` loop.
      * **Wave 1 Data:** `[Fox, Fox, Fox]` (Spawn every 2 seconds).
      * **Wave 2 Data:** `[Fox, Wolf, Fox, Wolf]` (Spawn every 1.5 seconds).

-----

### **Phase 4: The Defense Loop (Days 5-6)**

**Goal:** Player can place towers and towers shoot.

1.  **Input Handling:**

      * Use `TapCallbacks` mixin on the `Game` class.
      * **Formula:** `onTapUp(info)`:
          * `clickedRow = info.eventPosition.y / 32`
          * `clickedCol = info.eventPosition.x / 32`
      * **Check:** Is `grid[clickedRow][clickedCol] == Buildable` AND `Money >= 50`?
      * **Action:**
          * Subtract 50 Money.
          * Add `ChickenTower` component at those coordinates.
          * Mark grid as `Occupied`.

2.  **Class: `ChickenTower` (extends `SpriteComponent`)**

      * **Stats:** `range = 100px`, `fireRate = 1.0s`.
      * **Update Loop:**
          * `gameRef.children.whereType<Enemy>()`.
          * Find closest enemy where `distance < range`.
          * If found and `cooldown == 0`:
              * `spawnProjectile(target)`.
              * `resetCooldown()`.

3.  **Class: `Projectile` (extends `SpriteComponent`)**

      * **Behavior:** Moves toward the `target` Vector.
      * **Collision:** Use Flame `CollisionCallbacks`.
          * `onCollision(Enemy)`:
              * `Enemy.takeDamage(10)`.
              * `Projectile.removeFromParent()`.
              * Play `sfx_pop`.

-----

### **Phase 5: The "App" Wrapper (UI) (Day 7)**

**Goal:** Make it feel like a polished app, not a tech demo.

1.  **HUD (Flutter Overlay):**
      * Top Left: Heart Icon + `gameState.lives`.
      * Top Right: Coin Icon + `gameState.money`.
      * Bottom: "Wave Start" Button (Starts the timer).
2.  **State Management (Provider/Riverpod):**
      * Create a `GameNotifier` class.
      * When Flame event happens (Enemy dies), call `gameNotifier.addMoney(10)`.
      * The Flutter HUD listens to this and updates automatically.
3.  **Educational Tip (The "Useful" Aspect):**
      * On the Loading Screen (between levels), display a static card:
      * *"Farm Fact: Chickens need calcium to lay strong eggs\!"*
      * (This satisfies your requirement for the app to be "Useful" and not spammy).

-----

### **The "Don't Think, Just Build" Data Sheet**

Use these hard numbers to avoid balancing headaches during dev.

| Object | HP | Damage | Speed | Cost | Reward |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Chicken (Tower 1)** | N/A | 10 | 1.0s (Fire Rate) | $50 | N/A |
| **Goose (Tower 2)** | N/A | 25 | 2.0s (Fire Rate) | $120 | N/A |
| **Fox (Enemy 1)** | 30 | -1 Life | 80 px/s | N/A | $10 |
| **Wolf (Enemy 2)** | 80 | -2 Lives | 60 px/s | N/A | $25 |
| **Starting Stats** | 5 Lives | N/A | N/A | $150 | N/A |

### **dependencies:**

  flutter:

    sdk: flutter

  # --- FLAME CORE ---

  flame: ^1.34.0

  # --- FLAME BRIDGE PACKAGES ---

  flame_tiled: ^3.0.9      # For loading your Tiled map

  flame_audio: ^2.11.12    # For music and sound effects

  # --- FLUTTER UTILITIES ---

  riverpod: ^3.0.3         

  shared_preferences: ^2.2.2 # For saving progress and high scores

