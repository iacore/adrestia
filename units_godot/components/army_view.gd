tool
extends Control

# Really bad format for things to draw
# [colour, [x, y], [x1, y1, x2, y2, ...]]
# TODO: charles: change to a better format after we figure out how to represent
# result of box packing algorithm; probably, UnitKind will specify the colour
# and arrangement of tiles, and Unit will have a position
var data = [
    [Color(0, 0, 1), [0, 0], [1, 0, 0, 1, 1, 1, 2, 1, 0, 2, 1, 2, 2, 2]],
    [Color(0.5, 0.5, 0.5), [2, 0], [0, 0]],
    [Color(1, 0, 0), [3, 0], [0, 0]],
    [Color(1, 0, 0), [4, 0], [0, 0]],
    [Color(0, 1, 0), [3, 1], [0, 0, 1, 0]],
    [Color(0, 1, 0), [3, 2], [0, 0, 1, 0]]
  ]
var line_color = Color(0.2, 0.2, 0.2)
var max_tile_size = 50
var OutlinedPolygon2D = preload("outlined_polygon2d.gd")
onready var parent = $Container

static func squares_to_polygon(coords):
  # Converts a bunch of squares into a list of vertices.
  # The polygon must not have interior holes.
  # The key insight here is that we are always travelling ccw around the
  # polygon. That means the 2x2 neighborhood around our current vertex is
  # always enough information to determine which way to head.
  var square_occupied = {}
  var top_left = [coords[0], coords[1]]
  for i in range(coords.size() / 2):
    var x = coords[2 * i]
    var y = coords[2 * i + 1]
    square_occupied[[x,y]] = true
    if y < top_left[1] or (y == top_left[1] and x < top_left[0]):
      top_left = [x,y]

  var poly_coords = []
  poly_coords.append(top_left)
  var x = top_left[0]
  var y = top_left[1] + 1
  while [x, y] != top_left:
    var nw = square_occupied.has([x-1, y-1])
    var ne = square_occupied.has([x  , y-1])
    var sw = square_occupied.has([x-1, y  ])
    var se = square_occupied.has([x  , y  ])
    var window = [nw, ne, sw, se]
    if window.count(true) % 2 == 1:
      poly_coords.append([x, y])
    match [nw, ne, sw, se]:
      # Corners
      [false, false, false, true ]: y += 1 # [ .]
      [false, false, true , false]: x -= 1 # [. ]
      [false, true , false, false]: x += 1 # [ ']
      [true , false, false, false]: y -= 1 # [' ]
      [true , true , true , false]: x += 1 # [:']
      [true , true , false, true ]: y += 1 # [':]
      [true , false, true , true ]: y -= 1 # [:.]
      [false, true , true , true ]: x -= 1 # [.:]
      # Flat walls
      [true , false, true , false]: y -= 1 # [: ]
      [false, true , false, true ]: y += 1 # [ :]
      [true , true , false, false]: x += 1 # ['']
      [false, false, true , true ]: x -= 1 # [..]
      _:
        print("Bad squares")
        return poly_coords
  return poly_coords

func _ready():
  connect("resized", self, "_on_resized")
  _on_resized()

func _on_resized():
  # This should hopefully be called like, once max per game
  print("army_view resized! this may be expensive")
  var max_x = 0; var max_y = 0;
  for child in parent.get_children():
    child.queue_free()
  for unit in data:
    var polygon = OutlinedPolygon2D.new()
    polygon.color = unit[0]
    var vertices = PoolVector2Array()
    var poly_coords = squares_to_polygon(unit[2])
    var x_ofs = unit[1][0] * 50
    var y_ofs = unit[1][1] * 50
    for xy in poly_coords:
      var x = xy[0] * 50; var y = xy[1] * 50;
      max_x = max(max_x, x + x_ofs)
      max_y = max(max_y, y + y_ofs)
      vertices.append(Vector2(x, y))
    polygon.position = Vector2(x_ofs, y_ofs)
    polygon.polygon = vertices
    parent.add_child(polygon)
  parent.position = Vector2((rect_size.x - max_x) / 2, (rect_size.y - max_y) / 2)