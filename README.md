This script provides a simple Antilag system for FiveM servers.



# FiveM Antilag Script

## Deutsch

Dieses Script aktiviert/deaktiviert ein Antilag-System pro Spieler ueber einen Chat-Befehl.
Bei aktivem Antilag werden beim Beschleunigen Flammen und Backfire-Sound am Fahrzeug erzeugt.

### Features
- Toggle ohne Argument: `/antilag`
- Aktivieren: `/antilag true`, `/antilag on`, `/antilag 1`
- Deaktivieren: `/antilag false`, `/antilag off`, `/antilag 0`, `/antilag 2`
- Dauerhafte Anzeige `Antilag Aktiv` auf dem Bildschirm
- Automatische Deaktivierung beim Aussteigen
- Konfigurierbarer Backfire-Burst mit Cooldown
- Exhaust-Bone FX + Fallback, damit der Effekt auf mehr Fahrzeugen sichtbar ist
- Debug-Logs fuer Client und Server
- Framework-unabhaengig (kein ESX zwingend noetig)

### Installation
1. Lege den Ordner `fivem-antilag-script` in deinen `resources`-Ordner.
2. Fuege in der `server.cfg` hinzu:
   ```cfg
   ensure fivem-antilag-script
   ```
3. Server neu starten.

### Konfiguration
Alle Werte sind in `config.lua`.

Wichtige Schalter:
- `Config.Debug = true` aktiviert Debug-Logs
- `Config.CommandName` setzt den Chat-Befehl (Default: `antilag`)
- `Config.Client.TriggerMode` (`hold`, `rise`, `liftoff`)
- `Config.Client.OnlyDriverCanTrigger` blockt Trigger als Beifahrer (Safety)
- `Config.Client.RequireRpm`, `RequireSpeed` fuer strikte Trigger
- `Config.Client.MinRpm` fuer hohe Drehzahl (nur wenn `RequireRpm = true`)
- `Config.Client.RpmZeroFallback`, `RpmZeroMinSpeed` fuer Fahrzeuge mit `rpm=0.0`
- `Config.Client.CooldownMs`, `BurstCount`, `BurstDelayMs`
- `Config.Client.Boost` fuer Leistungsplus (default: aus, Safety gegen Anti-Cheat)
- `Config.Client.Fx.Names` (mehrere FX-Namen als Fallback)
- `Config.Client.Sound.Events`, `CoordRange`, `FrontendFallback`, `NuiFallback`, `ExplosionFallback`

### Debug / Fehlersuche
Wenn nur der Text angezeigt wird, aber keine Flammen kommen:
1. `Config.Debug = true` setzen.
2. Resource neu starten: `restart fivem-antilag-script`.
3. F8-Konsole pruefen (Client-Logs mit Prefix `[Antilag][Client]`).
4. Server-Konsole pruefen (Logs mit Prefix `[Antilag][Server]`).
5. In `config.lua` ggf. `Fx.Names`, `MinRpm`, `TriggerThreshold` anpassen.

## English

This script enables/disables an antilag system per player via chat command.
When antilag is active, flames and backfire sound are produced while accelerating.

### Features
- Toggle without argument: `/antilag`
- Enable: `/antilag true`, `/antilag on`, `/antilag 1`
- Disable: `/antilag false`, `/antilag off`, `/antilag 0`, `/antilag 2`
- Persistent on-screen `Antilag Aktiv` status text
- Auto-disable when leaving the vehicle
- Configurable backfire burst with cooldown
- Exhaust-bone FX with fallback for better vehicle compatibility
- Debug logs for client and server
- Framework-agnostic (ESX not required)

### Installation
1. Place `fivem-antilag-script` in your `resources` folder.
2. Add to `server.cfg`:
   ```cfg
   ensure fivem-antilag-script
   ```
3. Restart the server.

### Usage
- Enter a vehicle.
- Enable Antilag with `/antilag true`.
- Disable Antilag with `/antilag false`.
- While Antilag is active, flames and loud backfire sounds will be produced when accelerating.

### Notes
- Effects only work while you are in a vehicle.
- Particle effects and sounds use FiveM natives and only work in-game.
- For further customization (e.g. different sounds or effects), the script can be extended.




NICHT FERTIG
