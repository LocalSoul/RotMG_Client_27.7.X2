# Game Server Packets (TCP) – RotMG Client 27.7.X2

Dokumentation aller Gameplay-Packets, die der Client über **TCP** mit dem Game-Server
austauscht (Port 2050). HTTP/AppEngine-Packets sind hier nicht enthalten.

---

## Frame-Format

Jede Nachricht über das TCP-Socket hat folgendes Format:

```
[4 Byte  Message-Länge (Big-Endian) = Payload + 5]
[1 Byte  Opcode]
[N Byte  Payload]
```

- Die Länge zählt also **Opcode + Payload + 4 reserviert** (Gesamtlänge = Payload + 5).
- Der Opcode bestimmt den Packet-Typ (siehe Tabellen unten).
- Alle Werte sind **Big-Endian**.

## Datentypen (Größen)

| Typ | Größe | Beschreibung |
|---|---|---|
| `byte` / `int8` | 1 | vorzeichenbehaftete 8-Bit-Ganzzahl |
| `ubyte` / `uint8` | 1 | vorzeichenlose 8-Bit-Ganzzahl |
| `short` / `int16` | 2 | vorzeichenbehaftete 16-Bit-Ganzzahl |
| `ushort` / `uint16` | 2 | vorzeichenlose 16-Bit-Ganzzahl |
| `int` / `int32` | 4 | vorzeichenbehaftete 32-Bit-Ganzzahl |
| `uint` / `uint32` | 4 | vorzeichenlose 32-Bit-Ganzzahl |
| `float` | 4 | IEEE-754 Single-Precision |
| `bool` | 1 | `0` = false, `1` = true |
| `string` | 2+N | 2-Byte-Länge + UTF-8-Bytes |
| `bytes` | N | Rohe Bytes (Länge explizit vorher angegeben) |

## Zusammengesetzte Datentypen (Hilfsklassen)

Diese Strukturen tauchen in mehreren Packets auf (`kabam/rotmg/messaging/impl/data/`).

### WorldPosData
| Feld | Typ | Beschreibung |
|---|---|---|
| x | `float` | X-Position auf der Karte |
| y | `float` | Y-Position auf der Karte |

### SlotObjectData
| Feld | Typ | Beschreibung |
|---|---|---|
| objectId | `int` | Objekt, dessen Inventar betroffen ist |
| slotId | `ubyte` | Slot-Index im Inventar |
| objectType | `short` | Item-Typ |

### MoveRecord
| Feld | Typ | Beschreibung |
|---|---|---|
| time | `int` | Zeitstempel (ms) |
| x | `float` | X-Position |
| y | `float` | Y-Position |

### ObjectData
| Feld | Typ | Beschreibung |
|---|---|---|
| objectType | `short` | Objekt-/Entity-Typ |
| status | `ObjectStatusData` | Status des Objekts |

### ObjectStatusData
| Feld | Typ | Beschreibung |
|---|---|---|
| objectId | `int` | Objekt-ID |
| pos | `WorldPosData` | aktuelle Position |
| statsCount | `short` | Anzahl der Stats |
| stats | `StatData[statsCount]` | Stat-Werte |

### StatData
| Feld | Typ | Beschreibung |
|---|---|---|
| statType | `ubyte` | Stat-ID (siehe Stat-Liste unten) |
| statValue | `int` **ODER** `string` | `int` bei numerischen Stats, `string` bei NAME/GUILD_NAME/PET_NAME/ACCOUNT_ID/OWNER_ACCOUNT_ID |

### GroundTileData
| Feld | Typ | Beschreibung |
|---|---|---|
| x | `short` | X-Kachel |
| y | `short` | Y-Kachel |
| type | `ushort` | Tile-Typ |

### TradeItem
| Feld | Typ | Beschreibung |
|---|---|---|
| item | `int` | Item-Typ |
| slotType | `int` | Slot-Typ |
| tradeable | `bool` | ist handelbar |
| included | `bool` | ist im Angebot enthalten |

---

# C->S Packets (Client → Server)

| Opcode | Name | Beschreibung |
|---|---|---|
| 86 | HELLO | Verbindungsaufbau/Login auf dem Game-Server |
| 63 | LOAD | Charakter laden |
| 48 | CREATE | neuen Charakter erstellen |
| 24 | MOVE | Bewegung senden |
| 41 | PLAYERSHOOT | Spieler schießt |
| 3 | USEITEM | Item benutzen |
| 64 | INVSWAP | Item im Inventar tauschen |
| 97 | INVDROP | Item droppen |
| 9 | PLAYERTEXT | Chat-Nachricht senden |
| 96 | UPDATEACK | Bestätigung eines UPDATE |
| 83 | PONG | Antwort auf PING |
| 8 | (—) | siehe PING (S->C) |
| 36 | SETCONDITION | Bedingung (ConditionEffect) setzen |
| 5 | TELEPORT | Teleport zu Spieler |
| 23 | USEPORTAL | Portal benutzen |
| 77 | BUY | Item kaufen |
| 37 | PLAYERHIT | Spieler wurde von Bullet getroffen |
| 94 | ENEMYHIT | Bullet trifft Gegner |
| 6 | OTHERHIT | Bullet trifft anderes Objekt |
| 59 | SQUAREHIT | Bullet trifft Wand/Tile |
| 10 | SHOOTACK | Bestätigung des Schusses |
| 89 | AOEACK | Bestätigung einer AOE |
| 99 | GOTOACK | Bestätigung von GOTO |
| 84 | GROUNDDAMAGE | Boden-Schaden erlitten |
| 25 | CHOOSENAME | Namen wählen |
| 11 | CREATEGUILD | Gilde erstellen |
| 75 | GUILDREMOVE | Spieler aus Gilde entfernen |
| 85 | GUILDINVITE | Spieler in Gilde einladen |
| 67 | JOINGUILD | Gilde beitreten |
| 81 | CHANGEGUILDRANK | Gilden-Rang ändern |
| 82 | REQUESTTRADE | Handel anfragen |
| 101 | CHANGETRADE | Angebot ändern |
| 26 | ACCEPTTRADE | Handel akzeptieren |
| 22 | CANCELTRADE | Handel abbrechen |
| 27 | CHECKCREDITS | Credits anfragen |
| 16 | ESCAPE | zu Nexus fliehen |
| 87 | EDITACCOUNTLIST | Ignorier-/Freundesliste ändern |
| 47 | ACTIVE_PET_UPDATE_REQUEST | aktives Pet setzen |
| 79 | PETUPGRADEREQUEST | Pet upgraden/füttern |
| 42 | PET_CHANGE_FORM_MSG | Pet umskinnen (Reskin) |
| 45 | ENTER_ARENA | Arena betreten |
| 15 | ACCEPT_ARENA_DEATH | Arenatod akzeptieren (Wiederbelebung) |
| 91 | QUEST_FETCH_ASK | Questdaten anfragen |
| 98 | QUEST_REDEEM | Quest-Item einlösen |

## Detaillierte C->S Packets

### HELLO (86)
Begrüßung/Login direkt nach TCP-Verbindungsaufbau. `guid_` (Account-Name) und
`password_` sind mit dem RSA-Public-Key verschlüsselt (Hex-String), daher ist das
Passwortfeld zufällig `0` in `Parameters`.

| Feld | Typ | Beschreibung |
|---|---|---|
| buildVersion | `string` | z. B. `"27.7.X2"` |
| gameId | `int` | Spiel-Modus/Map (Nexus, Realm, …) |
| guid | `string` | RSA-verschlüsselter Account-Name (Hex) |
| randomInt1 | `int` | Zufallswert (ohne Bedeutung) |
| password | `string` | RSA-verschlüsseltes Passwort (Hex) |
| randomInt2 | `int` | Zufallswert (ohne Bedeutung) |
| secret | `string` | Sitzungs-Secret |
| keyTime | `int` | Zeitstempel des Map-Keys |
| keyLen | `short` | Länge des Keys |
| key | `bytes[keyLen]` | Map-Decryption-Key |
| mapJsonLen | `int` | Länge des Map-JSON |
| mapJSON | `bytes` | Map-Daten (JSON), leer beim Normalbetrieb |
| entrytag | `string` | Einstiegstag (leer) |
| gameNet | `string` | z. B. `"rotmg"` |
| gameNetUserId | `string` | User-ID im GameNet |
| playPlatform | `string` | Plattform (z. B. `"rotmg"`) |
| platformToken | `string` | Plattform-Token |

### LOAD (63)
Lädt einen bereits existierenden Charakter ins Spiel.

| Feld | Typ | Beschreibung |
|---|---|---|
| charId | `int` | Charakter-ID |
| isFromArena | `bool` | kommt aus der Arena |

### CREATE (48)
Erstellt einen neuen Charakter und betritt das Spiel.

| Feld | Typ | Beschreibung |
|---|---|---|
| classType | `short` | Klassen-Typ (z. B. 782 = Wizard) |
| skinType | `short` | Skin-Typ |

### MOVE (24)
Aktuelle Position und Bewegungsverlauf des Spielers.

| Feld | Typ | Beschreibung |
|---|---|---|
| tickId | `int` | letzter verarbeiteter NEWTICK |
| time | `int` | Zeitstempel |
| newPosition | `WorldPosData` | aktuelle Position |
| recordsCount | `short` | Anzahl der Bewegungsrecords |
| records | `MoveRecord[recordsCount]` | Positionsverlauf seit letztem TICK |

### PLAYERSHOOT (41)
| Feld | Typ | Beschreibung |
|---|---|---|
| time | `int` | Zeitstempel |
| bulletId | `ubyte` | Bullet-ID (steigend) |
| containerType | `short` | Item-Typ der Waffe |
| startingPos | `WorldPosData` | Startposition des Schusses |
| angle | `float` | Schusswinkel (Radiant) |

### USEITEM (3)
| Feld | Typ | Beschreibung |
|---|---|---|
| time | `int` | Zeitstempel |
| slotObject | `SlotObjectData` | benutztes Item |
| itemUsePos | `WorldPosData` | Position, auf die das Item zielt |
| useType | `ubyte` | Benutzungsart |

### INVSWAP (64)
| Feld | Typ | Beschreibung |
|---|---|---|
| time | `int` | Zeitstempel |
| position | `WorldPosData` | Position des Spielers |
| slotObject1 | `SlotObjectData` | Quelle (Objekt, Slot, Item) |
| slotObject2 | `SlotObjectData` | Ziel |

### INVDROP (97)
| Feld | Typ | Beschreibung |
|---|---|---|
| slotObject | `SlotObjectData` | zu droppendes Item |

### PLAYERTEXT (9)
| Feld | Typ | Beschreibung |
|---|---|---|
| text | `string` | Chat-Text (ohne `/`-Commands) |

### UPDATEACK (96)
Keine Felder. Wird nach jedem UPDATE gesendet, damit der Server weiter schickt.

### PONG (83)
| Feld | Typ | Beschreibung |
|---|---|---|
| serial | `int` | Seriennummer aus dem PING |
| time | `int` | lokale Zeit beim Empfang |

### SETCONDITION (36)
| Feld | Typ | Beschreibung |
|---|---|---|
| conditionEffect | `ubyte` | ConditionEffect-ID |
| conditionDuration | `float` | Dauer in Sekunden |

### TELEPORT (5)
| Feld | Typ | Beschreibung |
|---|---|---|
| objectId | `int` | Ziel-Spieler |

### USEPORTAL (23)
| Feld | Typ | Beschreibung |
|---|---|---|
| objectId | `int` | Portal-Objekt |

### BUY (77)
| Feld | Typ | Beschreibung |
|---|---|---|
| objectId | `int` | Verkäufer/Item-Objekt |
| quantity | `int` | Menge |

### PLAYERHIT (37)
| Feld | Typ | Beschreibung |
|---|---|---|
| bulletId | `ubyte` | Bullet-ID des feindlichen Geschosses |
| objectId | `int` | Schütze (Gegner) |

### ENEMYHIT (94)
| Feld | Typ | Beschreibung |
|---|---|---|
| time | `int` | Zeitstempel |
| bulletId | `ubyte` | eigene Bullet-ID |
| targetId | `int` | getroffener Gegner |
| kill | `bool` | Bullet hat getötet / verschwunden |

### OTHERHIT (6)
| Feld | Typ | Beschreibung |
|---|---|---|
| time | `int` | Zeitstempel |
| bulletId | `ubyte` | eigene Bullet-ID |
| objectId | `int` | Bullet-Objekt |
| targetId | `int` | getroffenes Objekt |

### SQUAREHIT (59)
| Feld | Typ | Beschreibung |
|---|---|---|
| time | `int` | Zeitstempel |
| bulletId | `ubyte` | eigene Bullet-ID |
| objectId | `int` | Wand-/Tile-Objekt |

### SHOOTACK (10)
| Feld | Typ | Beschreibung |
|---|---|---|
| time | `int` | Zeitstempel des Schusses |

### AOEACK (89)
| Feld | Typ | Beschreibung |
|---|---|---|
| time | `int` | Zeitstempel |
| position | `WorldPosData` | Position des Spielers |

### GOTOACK (99)
| Feld | Typ | Beschreibung |
|---|---|---|
| time | `int` | Zeitstempel |

### GROUNDDAMAGE (84)
| Feld | Typ | Beschreibung |
|---|---|---|
| time | `int` | Zeitstempel |
| position | `WorldPosData` | Position des Schadens |

### CHOOSENAME (25)
| Feld | Typ | Beschreibung |
|---|---|---|
| name | `string` | gewählter Name |

### CREATEGUILD (11)
| Feld | Typ | Beschreibung |
|---|---|---|
| name | `string` | Gildenname |

### GUILDREMOVE (75)
| Feld | Typ | Beschreibung |
|---|---|---|
| name | `string` | zu entfernender Spieler |

### GUILDINVITE (85)
| Feld | Typ | Beschreibung |
|---|---|---|
| name | `string` | einzuladender Spieler |

### JOINGUILD (67)
| Feld | Typ | Beschreibung |
|---|---|---|
| guildName | `string` | Gildenname |

### CHANGEGUILDRANK (81)
| Feld | Typ | Beschreibung |
|---|---|---|
| name | `string` | Spielername |
| guildRank | `int` | neuer Rang (0=Initiate … 3=Leader) |

### REQUESTTRADE (82)
| Feld | Typ | Beschreibung |
|---|---|---|
| name | `string` | Handelspartner |

### CHANGETRADE (101)
| Feld | Typ | Beschreibung |
|---|---|---|
| offerCount | `short` | Anzahl Slots |
| offer | `bool[offerCount]` | Angebot je Slot (true = drin) |

### ACCEPTTRADE (26)
| Feld | Typ | Beschreibung |
|---|---|---|
| myOfferCount | `short` | Anzahl eigener Slots |
| myOffer | `bool[myOfferCount]` | eigenes finales Angebot |
| yourOfferCount | `short` | Anzahl fremder Slots |
| yourOffer | `bool[yourOfferCount]` | bestätigtes Gegenangebot |

### CANCELTRADE (22)
Keine Felder. Bricht den Handel ab.

### CHECKCREDITS (27)
Keine Felder. Fragt den Kontostand (Credits) an.

### ESCAPE (16)
Keine Felder. Bringt den Spieler in den Nexus.

### EDITACCOUNTLIST (87)
| Feld | Typ | Beschreibung |
|---|---|---|
| accountListId | `int` | Liste (0 = Ignore, 1 = Friends) |
| add | `bool` | true = hinzufügen, false = entfernen |
| objectId | `int` | betroffener Spieler |

### ACTIVE_PET_UPDATE_REQUEST (47)
| Feld | Typ | Beschreibung |
|---|---|---|
| commandtype | `ubyte` | Befehl (0 = set active) |
| instanceid | `int` | Pet-Instanz-ID |

### PETUPGRADEREQUEST (79)
| Feld | Typ | Beschreibung |
|---|---|---|
| petTransType | `ubyte` | Transaktionstyp (0 = feed, 1 = fuse) |
| PIDOne | `int` | Pet 1 |
| PIDTwo | `int` | Pet 2 (nur bei Fuse) |
| objectId | `int` | Futter-Objekt |
| slotObject | `SlotObjectData` | benutztes Item |
| paymentTransType | `ubyte` | 0 = Gold, 1 = Fame |

### PET_CHANGE_FORM_MSG (42) / ReskinPet
| Feld | Typ | Beschreibung |
|---|---|---|
| petInstanceId | `int` | Pet-Instanz-ID |
| pickedNewPetType | `int` | neuer Pet-Typ/Skin |
| item | `SlotObjectData` | für Skin nötiges Item |

### ENTER_ARENA (45)
| Feld | Typ | Beschreibung |
|---|---|---|
| currency | `int` | Bezahlung (0 = Gold, 1 = Fame) |

### ACCEPT_ARENA_DEATH (15)
Keine Felder. Bestätigt den Tod in der Arena (z. B. Wiederbelebung).

### QUEST_FETCH_ASK (91)
Keine Felder. Fragt aktuelle Quest-Daten an.

### QUEST_REDEEM (98)
| Feld | Typ | Beschreibung |
|---|---|---|
| slotObject | `SlotObjectData` | einzulösendes Item |

---

# S->C Packets (Server → Client)

| Opcode | Name | Beschreibung |
|---|---|---|
| 0 | FAILURE | Fehlermeldung / Verbindungsabbruch |
| 1 | SERVERPLAYERSHOOT | fremder Spieler schießt |
| 4 | QUESTOBJID | aktives Quest-Ziel |
| 7 | AOE | Flächenschaden |
| 8 | PING | Ping-Anfrage (→ PONG) |
| 12 | DEATH | Spieler ist gestorben |
| 13 | RESKIN_UNLOCK | neuer Skin freigeschaltet |
| 14 | INVITEDTOGUILD | Einladung in Gilde |
| 17 | PLAYSOUND | Sound abspielen |
| 18 | INVRESULT | Ergebnis einer Inventar-Aktion |
| 20 | NOTIFICATION | Popup-Nachricht über Spieler |
| 21 | PETYARDUPDATE | Pet-Yard-Update |
| 28 | MAPINFO | Map-/Spiel-Informationen |
| 30 | HATCH_PET | Pet ist geschlüpft |
| 31 | NEWTICK | Spiel-Tick mit Status-Updates |
| 33 | FILE | Datei vom Server |
| 34 | TEXT | Chat-Nachricht |
| 35 | TRADEDONE | Handel beendet |
| 38 | TRADECHANGED | Partner hat Angebot geändert |
| 39 | ACTIVEPETUPDATE | aktives Pet geändert |
| 40 | GLOBAL_NOTIFICATION | globale Nachricht |
| 44 | UPDATE | neue Objekte/Kacheln |
| 49 | ALLYSHOOT | verbündeter Spieler schießt |
| 50 | DELETE_PET | Pet gelöscht |
| 51 | TRADEREQUESTED | Handelsanfrage empfangen |
| 52 | DAMAGE | Schaden an Spieler |
| 53 | ACCOUNTLIST | Ignore-/Freundesliste |
| 55 | ARENA_DEATH | Tod in der Arena |
| 56 | BUYRESULT | Ergebnis des Kaufs |
| 57 | CLIENTSTAT | Server schickt Client-Statistik |
| 58 | CREATE_SUCCESS | Charakter erfolgreich erstellt |
| 60 | QUEST_FETCH_RESPONSE | Quest-Daten |
| 61 | PASSWORD_PROMPT | Passwort-Eingabe nötig |
| 62 | NAMERESULT | Ergebnis der Namenswahl |
| 65 | IMMINENT_ARENA_WAVE | nächste Arena-Welle |
| 68 | RECONNECT | zu anderem Server verbinden |
| 69 | EVOLVE_PET | Pet hat sich entwickelt |
| 74 | TRADESTART | Handel beginnt |
| 76 | NEW_ABILITY | neue Fähigkeit |
| 78 | SHOWEFFECT | visueller Effekt |
| 80 | VERIFY_EMAIL | E-Mail-Verifikation nötig |
| 90 | ENEMYSHOOT | Gegner schießt |
| 92 | GOTO | Objekt wurde teleportiert |
| 93 | QUEST_REDEEM_RESPONSE | Quest-Einlösung beantwortet |
| 95 | GUILDRESULT | Ergebnis der Gilden-Aktion |
| 100 | TRADEACCEPTED | Handel wurde akzeptiert |

## Detaillierte S->C Packets

### FAILURE (0)
| Feld | Typ | Beschreibung |
|---|---|---|
| errorId | `int` | Fehlercode (siehe unten) |
| errorDescription | `string` | Fehlertext |

Fehlercodes: `0`? (nicht benannt), `4` = INCORRECT_VERSION, `5` = BAD_KEY, `6` = INVALID_TELEPORT_TARGET, `7` = EMAIL_VERIFICATION_NEEDED.

### SERVERPLAYERSHOOT (1)
| Feld | Typ | Beschreibung |
|---|---|---|
| bulletId | `ubyte` | Bullet-ID |
| ownerId | `int` | Schütze |
| containerType | `int` | Waffen-Typ |
| startingPos | `WorldPosData` | Startposition |
| angle | `float` | Winkel |
| damage | `short` | Schaden |

### QUESTOBJID (4)
| Feld | Typ | Beschreibung |
|---|---|---|
| objectId | `int` | Quest-Ziel-Objekt |

### AOE (7)
| Feld | Typ | Beschreibung |
|---|---|---|
| pos | `WorldPosData` | Zentrum |
| radius | `float` | Radius |
| damage | `ushort` | Schaden |
| effect | `ubyte` | ConditionEffect |
| duration | `float` | Effekt-Dauer |
| origType | `ushort` | verursachender Projektiltyp |

### PING (8)
| Feld | Typ | Beschreibung |
|---|---|---|
| serial | `int` | Seriennummer (wird im PONG zurückgegeben) |

### DEATH (12)
| Feld | Typ | Beschreibung |
|---|---|---|
| accountId | `string` | Account-Name |
| charId | `int` | Charakter-ID |
| killedBy | `string` | Name des Mörders |
| zombieType | `int` | Zombie-Typ (falls vorhanden) |
| zombieId | `int` | Zombie-Objekt-ID (−1 = kein Zombie) |

### RESKIN_UNLOCK (13)
| Feld | Typ | Beschreibung |
|---|---|---|
| skinID | `int` | freigeschalteter Skin |

### INVITEDTOGUILD (14)
| Feld | Typ | Beschreibung |
|---|---|---|
| name | `string` | Einladender |
| guildName | `string` | Gildenname |

### PLAYSOUND (17)
| Feld | Typ | Beschreibung |
|---|---|---|
| ownerId | `int` | Objekt-Id des Ton-Auslösers |
| soundId | `ubyte` | Sound-ID |

### INVRESULT (18)
| Feld | Typ | Beschreibung |
|---|---|---|
| result | `int` | 0 = Erfolg, sonst Fehler |

### NOTIFICATION (20)
| Feld | Typ | Beschreibung |
|---|---|---|
| objectId | `int` | betroffenes Objekt |
| message | `string` | anzuzeigender Text |
| color | `int` | Textfarbe (ARGB) |

### PETYARDUPDATE (21)
| Feld | Typ | Beschreibung |
|---|---|---|
| type | `int` | Pet-Yard-Typ |

### MAPINFO (28)
| Feld | Typ | Beschreibung |
|---|---|---|
| width | `int` | Kartenbreite (Tiles) |
| height | `int` | Kartenhöhe (Tiles) |
| name | `string` | Map-Name (z. B. `"Nexus"`) |
| displayName | `string` | Anzeigename |
| fp | `uint` | Fingerprint (Map-Hash) |
| background | `int` | Hintergrund-Typ |
| difficulty | `int` | Schwierigkeit |
| allowPlayerTeleport | `bool` | Teleport erlaubt |
| showDisplays | `bool` | Displays anzeigen |
| clientXmlCount | `short` | Anzahl Client-XML-Blöcke |
| clientXml | `string[clientXmlCount]` | XML (Items, Enemies, …) |
| extraXmlCount | `short` | Anzahl Extra-XML-Blöcke |
| extraXml | `string[extraXmlCount]` | zusätzliches XML |

### HATCH_PET (30)
| Feld | Typ | Beschreibung |
|---|---|---|
| petName | `string` | Name des Pets |
| petSkin | `int` | Skin des Pets |

### NEWTICK (31)
| Feld | Typ | Beschreibung |
|---|---|---|
| tickId | `int` | Tick-Nummer |
| tickTime | `int` | Zeit des Ticks |
| statusesCount | `short` | Anzahl Status-Updates |
| statuses | `ObjectStatusData[statusesCount]` | Positionen + Stats aller relevanten Objekte |

### FILE (33)
| Feld | Typ | Beschreibung |
|---|---|---|
| filename | `string` | Dateiname |
| fileLength | `int` | Länge der Datei |
| file | `bytes` | Dateiinhalt |

### TEXT (34)
| Feld | Typ | Beschreibung |
|---|---|---|
| name | `string` | Absender |
| objectId | `int` | Absender-Objekt |
| numStars | `int` | Star-Rang des Absenders |
| bubbleTime | `ubyte` | Dauer der Chat-Blase |
| recipient | `string` | Empfänger (leer = global) |
| text | `string` | Roh-Text |
| cleanText | `string` | gefilterter Text |

### TRADEDONE (35)
| Feld | Typ | Beschreibung |
|---|---|---|
| code | `int` | 0 = erfolgreich, 1 = Spieler abgebrochen |
| description | `string` | Beschreibung |

### TRADECHANGED (38)
| Feld | Typ | Beschreibung |
|---|---|---|
| offerCount | `short` | Anzahl Slots |
| offer | `bool[offerCount]` | neues Angebot des Partners |

### ACTIVEPETUPDATE (39)
| Feld | Typ | Beschreibung |
|---|---|---|
| instanceID | `int` | Instanz-ID des aktiven Pets |

### GLOBAL_NOTIFICATION (40)
| Feld | Typ | Beschreibung |
|---|---|---|
| type | `int` | Nachrichten-Typ |
| text | `string` | Nachrichtentext |

### UPDATE (44)
| Feld | Typ | Beschreibung |
|---|---|---|
| tilesCount | `short` | Anzahl Kachel-Updates |
| tiles | `GroundTileData[tilesCount]` | geänderte Tiles |
| newObjsCount | `short` | Anzahl neuer Objekte |
| newObjs | `ObjectData[newObjsCount]` | neue Objekte/Entities |
| dropsCount | `short` | Anzahl gelöschter Objekte |
| drops | `int[dropsCount]` | Objekt-IDs der entfernten Objekte |

### ALLYSHOOT (49)
| Feld | Typ | Beschreibung |
|---|---|---|
| bulletId | `ubyte` | Bullet-ID |
| ownerId | `int` | Verbündeter |
| containerType | `short` | Waffen-Typ |
| angle | `float` | Winkel |

### DELETE_PET (50)
| Feld | Typ | Beschreibung |
|---|---|---|
| petID | `int` | gelöschtes Pet |

### TRADEREQUESTED (51)
| Feld | Typ | Beschreibung |
|---|---|---|
| name | `string` | Anfragender |

### DAMAGE (52)
| Feld | Typ | Beschreibung |
|---|---|---|
| targetId | `int` | getroffener Spieler |
| effectsCount | `ubyte` | Anzahl Effekte |
| effects | `ubyte[effectsCount]` | ConditionEffects |
| damageAmount | `ushort` | Schaden |
| kill | `bool` | tödlich |
| bulletId | `ubyte` | Bullet-ID |
| objectId | `int` | Schütze |

### ACCOUNTLIST (53)
| Feld | Typ | Beschreibung |
|---|---|---|
| accountListId | `int` | 0 = Ignore, 1 = Friends |
| accountIdsCount | `short` | Anzahl Einträge |
| accountIds | `string[accountIdsCount]` | Account-Namen |
| lockAction | `int` | Aktion (Lock/Unlock) |

### ARENA_DEATH (55)
| Feld | Typ | Beschreibung |
|---|---|---|
| cost | `int` | Kosten für Wiederbelebung |

### BUYRESULT (56)
| Feld | Typ | Beschreibung |
|---|---|---|
| result | `int` | Code (siehe unten) |
| resultString | `string` | Text |

Codes: `-1` = UNKNOWN_ERROR, `0` = SUCCESS, `1` = INVALID_CHARACTER, `2` = ITEM_NOT_FOUND, `3` = NOT_ENOUGH_GOLD, `4` = INVENTORY_FULL, `5` = TOO_LOW_RANK, `6` = NOT_ENOUGH_FAME, `7` = PET_FEED_SUCCESS.

### CLIENTSTAT (57)
| Feld | Typ | Beschreibung |
|---|---|---|
| name | `string` | Statistik-Name |
| value | `int` | Wert |

### CREATE_SUCCESS (58)
| Feld | Typ | Beschreibung |
|---|---|---|
| objectId | `int` | Spieler-Objekt-ID |
| charId | `int` | Charakter-ID |

### QUEST_FETCH_RESPONSE (60)
| Feld | Typ | Beschreibung |
|---|---|---|
| tier | `int` | Quest-Tier |
| goal | `string` | Quest-Ziel (Text) |
| description | `string` | Beschreibung |
| image | `string` | Bild-URL |

### PASSWORD_PROMPT (61)
| Feld | Typ | Beschreibung |
|---|---|---|
| cleanPasswordStatus | `int` | Status (Passwort ist schwach etc.) |

### NAMERESULT (62)
| Feld | Typ | Beschreibung |
|---|---|---|
| success | `bool` | Name angenommen |
| errorText | `string` | Fehlertext |

### IMMINENT_ARENA_WAVE (65)
| Feld | Typ | Beschreibung |
|---|---|---|
| currentRuntime | `int` | aktuelle Laufzeit (Sekunden) |

### RECONNECT (68)
| Feld | Typ | Beschreibung |
|---|---|---|
| name | `string` | Map-Name |
| host | `string` | Hostname des Zielservers |
| port | `int` | Port |
| gameId | `int` | Spiel-Modus |
| keyTime | `int` | Key-Zeitstempel |
| isFromArena | `bool` | von der Arena |
| keyLength | `short` | Key-Länge |
| key | `bytes` | Map-Key |

### EVOLVE_PET (69)
| Feld | Typ | Beschreibung |
|---|---|---|
| petID | `int` | Pet-ID |
| initialSkin | `int` | alter Skin |
| finalSkin | `int` | neuer Skin |

### TRADESTART (74)
| Feld | Typ | Beschreibung |
|---|---|---|
| myItemsCount | `short` | Anzahl eigener Items |
| myItems | `TradeItem[myItemsCount]` | eigene Items |
| yourName | `string` | Handelspartner |
| yourItemsCount | `short` | Anzahl dessen Items |
| yourItems | `TradeItem[yourItemsCount]` | dessen Items |

### NEW_ABILITY (76)
| Feld | Typ | Beschreibung |
|---|---|---|
| type | `int` | Fähigkeits-/Klassen-Typ |

### SHOWEFFECT (78)
| Feld | Typ | Beschreibung |
|---|---|---|
| effectType | `ubyte` | Effekt-Typ (siehe unten) |
| targetObjectId | `int` | Zielobjekt |
| pos1 | `WorldPosData` | Position 1 |
| pos2 | `WorldPosData` | Position 2 |
| color | `int` | Effektfarbe |

Effekt-Typen: `0` = UNKNOWN, `1` = HEAL, `2` = TELEPORT, `3` = STREAM, `4` = THROW, `5` = NOVA, `6` = POISON, `7` = LINE, `8` = BURST, `9` = FLOW, `10` = RING, `11` = LIGHTNING, `12` = COLLAPSE, `13` = CONEBLAST, `14` = JITTER, `15` = FLASH, `16` = THROW_PROJECTILE, `17` = SHOCKER, `18` = SHOCKEE, `19` = RISING_FURY.

### VERIFY_EMAIL (80)
Keine Felder. Signalisiert, dass die E-Mail verifiziert werden muss.

### ENEMYSHOOT (90)
| Feld | Typ | Beschreibung |
|---|---|---|
| bulletId | `ubyte` | Bullet-ID |
| ownerId | `int` | Gegner |
| bulletType | `ubyte` | Bullet-Typ |
| startingPos | `WorldPosData` | Startposition |
| angle | `float` | Winkel |
| damage | `short` | Schaden |
| numShots | `ubyte` | Anzahl Schüsse (optional, 1 wenn fehlt) |
| angleInc | `float` | Winkel-Offset je Schuss |

### GOTO (92)
| Feld | Typ | Beschreibung |
|---|---|---|
| objectId | `int` | Objekt |
| pos | `WorldPosData` | neue Position (Teleport) |

### QUEST_REDEEM_RESPONSE (93)
| Feld | Typ | Beschreibung |
|---|---|---|
| ok | `bool` | erfolgreich |
| message | `string` | Nachricht |

### GUILDRESULT (95)
| Feld | Typ | Beschreibung |
|---|---|---|
| success | `bool` | erfolgreich |
| lineBuilderJSON | `string` | Ergebnis-Text (JSON) |

### TRADEACCEPTED (100)
| Feld | Typ | Beschreibung |
|---|---|---|
| myOfferCount | `short` | Anzahl eigener Slots |
| myOffer | `bool[myOfferCount]` | bestätigtes eigenes Angebot |
| yourOfferCount | `short` | Anzahl fremder Slots |
| yourOffer | `bool[yourOfferCount]` | bestätigtes Gegenangebot |

---

# Stat-IDs (StatData.statType)

| ID | Name | Typ | Bedeutung |
|---|---|---|---|
| 0 | MAX_HP_STAT | int | max. HP |
| 1 | HP_STAT | int | aktuelle HP |
| 2 | SIZE_STAT | int | Größe |
| 3 | MAX_MP_STAT | int | max. MP |
| 4 | MP_STAT | int | aktuelle MP |
| 5 | NEXT_LEVEL_EXP_STAT | int | nötige XP für nächstes Level |
| 6 | EXP_STAT | int | XP |
| 7 | LEVEL_STAT | int | Level |
| 8–19 | INVENTORY_0..11_STAT | int | Inventar-Slots 0–11 |
| 20 | ATTACK_STAT | int | Angriff |
| 21 | DEFENSE_STAT | int | Verteidigung |
| 22 | SPEED_STAT | int | Geschwindigkeit |
| 26 | VITALITY_STAT | int | Vitalität |
| 27 | WISDOM_STAT | int | Weisheit |
| 28 | DEXTERITY_STAT | int | Geschicklichkeit |
| 29 | CONDITION_STAT | int | ConditionEffect-Bits |
| 30 | NUM_STARS_STAT | int | Star-Rang |
| 31 | NAME_STAT | string | Name |
| 32 | TEX1_STAT | int | Textur 1 |
| 33 | TEX2_STAT | int | Textur 2 |
| 34 | MERCHANDISE_TYPE_STAT | int | Item-Typ im Shop |
| 35 | CREDITS_STAT | int | Credits |
| 36 | MERCHANDISE_PRICE_STAT | int | Shop-Preis |
| 37 | ACTIVE_STAT | int | aktiv (Pet) |
| 38 | ACCOUNT_ID_STAT | string | Account-Name |
| 39 | FAME_STAT | int | Fame |
| 40 | MERCHANDISE_CURRENCY_STAT | int | Shop-Währung |
| 41 | CONNECT_STAT | int | Verbindungs-Status |
| 42 | MERCHANDISE_COUNT_STAT | int | Shop-Anzahl |
| 43 | MERCHANDISE_MINS_LEFT_STAT | int | Shop-Restzeit |
| 44 | MERCHANDISE_DISCOUNT_STAT | int | Shop-Rabatt |
| 45 | MERCHANDISE_RANK_REQ_STAT | int | Shop-Rang-Anforderung |
| 46 | MAX_HP_BOOST_STAT | int | HP-Boost |
| 47 | MAX_MP_BOOST_STAT | int | MP-Boost |
| 48 | ATTACK_BOOST_STAT | int | ATK-Boost |
| 49 | DEFENSE_BOOST_STAT | int | DEF-Boost |
| 50 | SPEED_BOOST_STAT | int | SPD-Boost |
| 51 | VITALITY_BOOST_STAT | int | VIT-Boost |
| 52 | WISDOM_BOOST_STAT | int | WIS-Boost |
| 53 | DEXTERITY_BOOST_STAT | int | DEX-Boost |
| 54 | OWNER_ACCOUNT_ID_STAT | string | Besitzer-Account |
| 55 | RANK_REQUIRED_STAT | int | nötiger Rang |
| 56 | NAME_CHOSEN_STAT | int | Name gewählt |
| 57 | CURR_FAME_STAT | int | aktuelles Fame |
| 58 | NEXT_CLASS_QUEST_FAME_STAT | int | Quest-Fame-Ziel |
| 59 | LEGENDARY_RANK_STAT | int | Legenden-Rang |
| 60 | SINK_LEVEL_STAT | int | Sink-Level |
| 61 | ALT_TEXTURE_STAT | int | alternative Textur |
| 62 | GUILD_NAME_STAT | string | Gildenname |
| 63 | GUILD_RANK_STAT | int | Gilden-Rang |
| 64 | BREATH_STAT | int | Atem (Roboter) |
| 65 | XP_BOOSTED_STAT | int | XP-Boost aktiv |
| 66 | XP_TIMER_STAT | int | XP-Boost-Timer |
| 67 | LD_TIMER_STAT | int | Lucky-Day-Timer |
| 68 | LT_TIMER_STAT | int | Lucky-Time-Timer |
| 69 | HEALTH_POTION_STACK_STAT | int | HP-Potion-Stack |
| 70 | MAGIC_POTION_STACK_STAT | int | MP-Potion-Stack |
| 71–78 | BACKPACK_0..7_STAT | int | Rucksack-Slots 0–7 |
| 79 | HASBACKPACK_STAT | int | hat Rucksack |
| 80 | TEXTURE_STAT | int | Textur |
| 81 | PET_INSTANCEID_STAT | int | Pet-Instanz-ID |
| 82 | PET_NAME_STAT | string | Pet-Name |
| 83 | PET_TYPE_STAT | int | Pet-Typ |
| 84 | PET_RARITY_STAT | int | Pet-Seltenheit |
| 85 | PET_MAXABILITYPOWER_STAT | int | max. Ability-Power |
| 86 | PET_FAMILY_STAT | int | Pet-Familie |
| 87–89 | PET_FIRST/SECOND/THIRDABILITY_POINT_STAT | int | Ability-Punkte |
| 90–92 | PET_FIRST/SECOND/THIRDABILITY_POWER_STAT | int | Ability-Power |
| 93–95 | PET_FIRST/SECOND/THIRDABILITY_TYPE_STAT | int | Ability-Typ |
| 96 | NEW_CON_STAT | int | neuer Connection-Status |
| 97 | FORTUNE_TOKEN_STAT | int | Fortune-Token |

---

# Referenz: Quellcode

Die Opcodes stehen in `src/kabam/rotmg/messaging/impl/GameServerConnection.as`.
Die Registrierung (welcher Opcode → welche Klasse) in `GameServerConnectionConcrete.as` (`mapMessages`).
Die Feld-Definitionen in den Klassen unter:
- `src/kabam/rotmg/messaging/impl/outgoing/` (C->S)
- `src/kabam/rotmg/messaging/impl/incoming/` (S->C)
- `src/kabam/rotmg/messaging/impl/data/` (Hilfs-Strukturen)