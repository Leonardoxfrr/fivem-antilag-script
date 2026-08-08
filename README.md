# FiveM Anti-Lag Script

Experimentelle FiveM-Ressource für Anti-Lag-Effekte an Fahrzeugen. Sie enthält Konfigurationen für Partikeleffekte, Sound, NUI-Fallback und einen temporären Fahrzeug-Boost. Der aktuelle Stand ist ein **unfertiger Prototyp** und nicht für den produktiven Einsatz geeignet.

## Abhängigkeiten

- FiveM/FXServer
- ESX auf der Serverseite (`ESX.GetPlayerFromId` wird verwendet)
- optional eine Sound-Ressource, falls die konfigurierte Soundausgabe genutzt wird

Das Manifest deklariert ESX derzeit nicht explizit als Abhängigkeit und importiert ESX auch nicht automatisch. Die Einbindung muss vor einem Test überprüft und an die verwendete ESX-Version angepasst werden.

## Installation für die Entwicklung

1. Ordner als `fivem-antilag-script` in das Ressourcenverzeichnis kopieren.
2. ESX-Initialisierung und erforderliche Abhängigkeiten im Manifest ergänzen.
3. Werte in `config.lua` anpassen.
4. Die bekannten Blocker unten beheben.
5. Ressource in einer lokalen Testumgebung starten:

```cfg
ensure fivem-antilag-script
```

## Befehl

```text
/antilag <true|false|toggle>
```

Akzeptierte Varianten sind unter anderem:

- aktivieren: `true`, `on`, `1`, `enable`
- deaktivieren: `false`, `off`, `0`, `2`, `disable`
- umschalten: `toggle`, `t`

## Konfiguration

Die Konfiguration umfasst Partikel- und Soundeinstellungen, NUI- beziehungsweise Fallback-Ausgabe sowie Stärke und Dauer eines möglichen Boosts.

## Bekannte Blocker

- Im aktiven Client-Loop wird die Variable `veh` verwendet, ohne dort zuverlässig gesetzt zu sein.
- Auch ältere Testlogik enthält einen Zugriff auf `veh`, der zu Laufzeitfehlern führen kann.
- Der konfigurierte Ablauf zum Erkennen und Auslösen des Anti-Lag-Effekts ist im aktiven Loop noch nicht vollständig verdrahtet.
- Serverevents und clientseitig gemeldete Zustände benötigen vor produktiver Nutzung zusätzliche Validierung und Rate-Limits.
- ESX ist faktisch erforderlich, obwohl frühere Dokumentation die Ressource als frameworkunabhängig beschrieben hat.

## Entwicklungsstatus

Nicht fertig. Die Ressource sollte erst dann als funktionsfähig dokumentiert werden, wenn der vollständige Ablauf reproduzierbar getestet, die ESX-Integration geklärt und die Eventgrenzen abgesichert wurden.
