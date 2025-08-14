# qb-livery

Simple QBCore resource that lets players change their current vehicle's livery using `/livery`.
Supports both native liveries (GET_VEHICLE_LIVERY_COUNT / SET_VEHICLE_LIVERY) and mod-type liveries (vehicle mod type 48).

## Requirements
- QBCore
- qb-menu (for the menu UI)

## Installation
1. Drop the `qb-livery` folder into your server's `[qb]` (or any) resources directory.
2. Ensure it in your `server.cfg` after qb-core and qb-menu:
   ```
   ensure qb-core
   ensure qb-menu
   ensure qb-livery
   ```
3. (Optional) Configure `config.lua`:
   - `RequireDriver` (default: true): require driver seat.
   - `AllowedJobs` (default: empty): restrict usage by job, e.g. `{ police = 0, mechanic = 0 }`.
   - `ShowStockForModType` (default: true): show a "Stock" option for mod-type liveries.

## Usage
- Sit in the driver seat of a vehicle and type `/livery` to open the menu.
- If your car uses native liveries, they'll be listed as "Livery 1", "Livery 2", etc.
- If it uses mod-type liveries (type 48), you'll see a "Stock" option plus numbered liveries.

## Notes
- This changes the livery on the current vehicle entity. It does not persist across stored/respawned vehicles.
- Some vehicles have both systems; this script prioritizes native liveries first.
- If you want job-only access, populate `Config.AllowedJobs` with the jobs and minimum grades.

## Troubleshooting
- "This vehicle has no liveries.": The model might not have liveries or they are locked behind tuning parts.
- Menu not opening: make sure `qb-menu` is started and up-to-date.
- Nothing happens when selecting: ensure you are in the driver seat (or set `RequireDriver=false`).


## Extras Feature
- `/extras` opens a menu to toggle available extras on the current vehicle.
- Lists extras 0-20 if they exist, shows ON/OFF state.
- Click to toggle them live.
- No persistence; only affects the current vehicle until it's despawned.

## Extras
- Use `/extras` to open a list of available extras (1–20) on your current vehicle.
- Items show a ✓ if currently enabled; select to toggle ON/OFF.
- Only extras that actually exist on the model are listed.
