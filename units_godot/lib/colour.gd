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

static func to_color(colour):
  match colour:
    BLACK: return Color(0.5, 0.5, 0.5)
    RED  : return Color(0.8, 0.25, 0.25)
    GREEN: return Color(0.2, 0.66, 0.35)
    BLUE : return Color(0.2, 0.6, 0.85)
    WHITE: return Color(0.9, 0.9, 0.9)
  return Color(0.0, 0.0, 0.0)