extends Object

enum Colour {
  BLACK,
  RED,
  GREEN,
  BLUE,
  WHITE,
}

# Creates a value suitable for serialization with JSON.print.
static func jsonify(colour):
  match colour:
    BLACK: return "BLACK"
    RED: return "RED"
    GREEN: return "GREEN"
    BLUE: return "BLUE"
    WHITE: return "WHITE"
  return "BLACK"

# Creates value from JSON parse result
static func of_json(json):
  match json:
    "BLACK": return BLACK
    "RED": return RED
    "GREEN": return GREEN
    "BLUE": return BLUE
    "WHITE": return WHITE
  return BLACK
