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
    RED  : return Color(1.0, 0.0, 0.0)
    GREEN: return Color(0.0, 1.0, 0.0)
    BLUE : return Color(0.0, 0.0, 1.0)
    WHITE: return Color(0.9, 0.9, 0.9)
  return Color(0.0, 0.0, 0.0)
