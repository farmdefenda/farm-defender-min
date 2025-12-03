## 🧑‍🌾 User Journey: Farm Defender Mini

This guide describes the expected flow and real-time feedback for a standard user playing Level 1.

---

## 1. Entering the Game (The Shell)

**1. App Launch**
User taps the app icon.
The game opens in **landscape mode**.
The **Main Menu** displays the title *Farm Defender Mini* with a big **Start** button.
Handled by **Flutter (Shell)**.

**2. Start Game**
User taps **Start**.
A **Loading Screen** appears and shows a random *Farm Fact*.
Background music (`bgm_farm.mp3`) begins.
Handled by **Flutter (Shell)**.

**3. Level Entry**
After loading, the **Map** appears.
The game starts **Paused**.
HUD shows **5 Hearts** and **$150**.
Handled by **Flame (Engine)** + **Flutter (HUD)**.

---

## 2. Setting Up Defenses (The Core Loop)

**1. Choose Location**
User taps a **Grass Tile** (a buildable zone).
A small **Build Menu** appears showing available towers, e.g., *Chicken – $50*.
Handled by **Flame Input / Flutter Overlay**.

**2. Select Tower**
User taps **Chicken ($50)**.
$50 is deducted (new total: $100).
A **Chicken sprite** appears on the tapped tile.
Sound plays: `sfx_place_tower.wav`.
Handled by **Flame / Provider State**.

**3. Place Another Tower**
User taps another valid Grass Tile and repeats purchase.
Money decreases and tower is placed.
Handled by **Flame / Provider State**.

**4. Invalid Location Check**
User taps a **Dirt Path Tile** (non-buildable).
No build menu appears.
A brief visual such as “Cannot Build Here!” may appear.
Handled by **Flame Input / Grid Logic**.

---

## 3. Engaging the Enemy (The Action Phase)

**1. Start Wave**
User taps **Start Wave**.
The button disappears or becomes **Next Wave**.
Wave timer begins.
Handled by **Flutter / Wave Manager**.

**2. Enemy Spawn**
Enemies spawn automatically from the **SpawnPoint**.
First enemy: **Fox** begins walking along dirt path waypoints.
Handled by **Flame Enemy Component**.

**3. Combat Trigger**
When the Fox enters a Chicken tower’s **100px range**,
the tower fires an **Egg Projectile** every 1 second.
Sound: `sfx_chicken_cluck.wav`.
Handled by **Flame Tower Logic**.

**4. Enemy Hit**
When the projectile connects, the Fox’s **HP (30)** decreases.
Sound: `sfx_egg_splat.wav`.
Projectile disappears.
Handled by **Flame Collision Callback**.

**5. Enemy Defeat**
If HP reaches 0:
The Fox vanishes, player gains **$10**,
and `sfx_coin_collect.wav` plays.
Handled by **Flame / Provider State**.

**6. Enemy Leak**
If the Fox reaches the **EndPoint**:
It disappears and player loses **1 Heart** (new total: 4).
Handled by **Flame End-of-Path Logic**.

---

## 4. Game End States (The Outcome)

**1. Wave Complete**
When all enemies are defeated:
A banner appears: **Wave Complete!**
A button shows: **Start Next Wave**.
Handled by **Wave Manager / Flutter Overlay**.

**2. Loss Condition**
If Hearts drop to 0:
The game freezes.
Sound: `sfx_game_over.wav`.
A large **Game Over** screen appears with final stats and a **Try Again** button.
Handled by **Provider State / Flutter Overlay**.

---