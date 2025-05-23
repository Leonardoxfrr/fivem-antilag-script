# FiveM Antilag Script

## Deutsch

Dieses Script ermöglicht es, in FiveM per Befehl `/antilag true` und `/antilag false` ein Antilag-System für Fahrzeuge zu aktivieren oder zu deaktivieren. Ist das Antilag aktiv, werden beim Gasgeben laute Backfire-Sounds und große Flammen am Auspuff erzeugt. Zusätzlich erscheint eine dauerhafte Bildschirmbenachrichtigung, solange das Antilag aktiv ist.

### Features
- Aktivierung/Deaktivierung per Command: `/antilag true` und `/antilag false`
- 15-facher Backfire-Effekt (Flammen + Sound) beim Gasgeben
- Deutlich lauterer Motorsound
- Dauerhafte Notify-Anzeige, solange Antilag aktiv ist
- Client- und Server-seitige Trennung

### Installation
1. Lege den Ordner `fivem-antilag-script` in deinen `resources`-Ordner.
2. Füge die Resource zu deiner `server.cfg` hinzu:
   ```
   ensure fivem-antilag-script
   ```
3. Starte den Server neu.

### Nutzung
- Steige in ein Fahrzeug ein.
- Aktiviere Antilag mit `/antilag true`.
- Deaktiviere Antilag mit `/antilag false`.
- Solange Antilag aktiv ist, werden beim Gasgeben Flammen und laute Backfire-Sounds erzeugt.

### Hinweise
- Die Effekte funktionieren nur, wenn du im Fahrzeug sitzt.
- Die Partikeleffekte und Sounds nutzen FiveM natives und funktionieren nur im Spiel.
- Für weitere Anpassungen (z.B. andere Sounds oder Effekte) kann das Script erweitert werden.

---

## English

This script allows you to enable or disable an Antilag system for vehicles in FiveM using the `/antilag true` and `/antilag false` commands. When Antilag is active, loud backfire sounds and large flames are produced at the exhaust when accelerating. A persistent on-screen notification is also displayed as long as Antilag is active.

### Features
- Enable/disable via command: `/antilag true` and `/antilag false`
- 15x backfire effect (flames + sound) when accelerating
- Noticeably louder engine sound
- Persistent notification while Antilag is active
- Client and server side separation

### Installation
1. Place the `fivem-antilag-script` folder in your `resources` directory.
2. Add the resource to your `server.cfg`:
   ```
   ensure fivem-antilag-script
   ```
3. Restart your server.

### Usage
- Enter a vehicle.
- Enable Antilag with `/antilag true`.
- Disable Antilag with `/antilag false`.
- While Antilag is active, flames and loud backfire sounds will be produced when accelerating.

### Notes
- Effects only work while you are in a vehicle.
- Particle effects and sounds use FiveM natives and only work in-game.
- For further customization (e.g. different sounds or effects), the script can be extended.

