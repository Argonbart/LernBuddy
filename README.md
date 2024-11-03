# LernBuddy

## Abgabe
- [x] [Readme](README.md)
- [x] [Build](Build)
- [x] [Quellcode](LifeBuilderPrototype)
- [x] [Video](LernBuddyVideo.mp4)
- [ ] [Assets]()

---
Beim Spielstart erscheint man im Dorf. Von dort kann man in die Taverne.  
In der Taverne kann man über Richard das **Karten-Reflektionsspiel** starten.  
Und ebenfalls aus der Taverne über Jana das **Hexagon-Orientierungsspiel** starten.  
Aus jeglichen Menüs kann man über einen Button wieder zurück in das Vorherige, bzw. bei der Taverne über den Ausgang.  

---
## Village
Dort kann man sich frei bewegen und mit manchen NPCs interagieren.  
Der Schmied und das Phantom sind dabei an eine Gemini API angebunden, sodass diese frei zu jeder Eingabe antworten können.  
Manche Rückmeldungen können dabei zum Absturz führen (z.B. bei blockierten Anfragen durch vulgäre oder unangebrachte Prompts).  
Der Bürgermeister startet einen kurzen Dialog mit vorgefertigten Spielerantwort-Möglichkeiten.  
Dies sind alles Relikte mit denen wir Interaktionen der frühen Entwicklungs- und Prototypen-Phase getestet haben.  
Man kann auch Häuser platzieren (Teil der frühen Entwicklung), welche den Spieler blockieren falls diese auf dem Spieler platziert werden.  
Über den Eintritt in die Taverne kommt man zu den anderen Teilen des Spiels.  

### Buttons:
- wasd = movement
- space = jump (gimmick)
- q = place house
- c = change camera
- mouse wheel = zoom in/out
- wasd in changed camera = camera movement

### Interactions:
- talk to smith
- talk to phantom
- talk to mayor
- enter tavern

---
## Tavern:
Hier kann man sich ebenfalls frei bewegen, mit NPCs interagieren und über manche damit die einzelnen Spiele starten.  
Richard → Karten-Reflektionsspiel  
Jana → Hexagon-Orientierungsspiel  
Regelbrett → Ort für Erklärung der Regeln. Noch unvollständig (Jana fehlt) und eher als Platzhalter.  
Ausführliche interaktive Tutorials wären bei dem richtigen Spiel natürlich mit dabei.  
Man kann zum Dorf zurückkehren.  

### Buttons:
- e interact with npcs
- y/n to confirm mini games

### Interactions:
- read instruction board for rules (+return to tavern from inside)
- play with richard
- play with jana
- talk to npcs
- return to village

---
## Richard Game:
Hier wird das Kartenreflektionsspiel gespielt.  
Hierbei sind alle Karten von Richard ebenfalls über Gemini befüllt.  
In diesen Teil ist der größte Teil des Implementierungsaufwands hineingeflossen.  
Man kann zur Taverne zurückkehren.  

### Buttons:
- ctrl + space = confirm text input/play

### Interactions:
- select hand cards
- fill cards
- select fields
- play cards
- play bonus cards
- hover over cards
- return to tavern

---
## Jana Game:
Hier wird das Hexagon-Orientierungsspiel gespielt.  
Man kann zur Taverne zurückkehren.  
Es könnten einzelne Bugs auftauchen bei denen Hexagons nicht mehr greifbar werden.  

### Buttons:
- tab = open menu
- enter = confirm naming
- e/q while holding hexagon = rotate it
- t = toggle visibility of lables/names

### Interactions:
- select hexagons from menu
- place hexagons
- rotate hexagons
- name hexagons
- delete hexagons
- swap tabs in menu
- return to tavern

---
