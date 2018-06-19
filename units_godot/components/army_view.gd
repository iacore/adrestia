tool
extends Control

var Colour = preload('res://lib/colour.gd')

var data = [] setget set_data
var max_tile_size = 50
var OutlinedPolygon2D = preload("outlined_polygon2d.gd")
onready var scale_container = $ScaleContainer
onready var offset_container = $ScaleContainer/OffsetContainer

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

static func unit_fits(occupied, blocks, x, y):
  for xy in blocks:
    if occupied.has([xy[0]+x, xy[1]+y]):
      return false
  return true

class SortUnitsByWidth:
  static func sort(a, b):
    return (a.kind.width > b.kind.width)

# Given a list of units, returns a list of [unit, x, y].
static func position_units(orig_units):
  var occupied = {}
  var units_and_positions = []
  var goal_aspect = 2.0 # Goal aspect ratio. >1 is wider.
  var units = [] + orig_units
  units.sort_custom(SortUnitsByWidth, "sort")

  for unit in units:
    var flat_blocks = unit.kind.tiles
    var blocks = []
    for i in range(flat_blocks.size() / 2):
      blocks.append([flat_blocks[2 * i], flat_blocks[2 * i + 1]])

    # Find a place to put this unit.
    var result_x; var result_y
    var x = 0
    var y = 0
    var done = false
    while not done:
      if x == 0 or x <= y * goal_aspect:
        # Add a column
        for i in range(0, y):
          if unit_fits(occupied, blocks, x, i):
            done = true
            result_x = x
            result_y = i
            break
        if not done:
          x += 1
      else:
        # Add a row
        for i in range(0, x):
          if unit_fits(occupied, blocks, i, y):
            done = true
            result_x = i
            result_y = y
            break
        if not done:
          y += 1

    for xy in blocks:
      occupied[[xy[0] + result_x, xy[1] + result_y]] = true

    units_and_positions.append([unit, result_x, result_y])
    x += 1
  return units_and_positions

func _ready():
  connect("resized", self, "redraw")
  redraw()
  
func set_data(new_data):
  data = new_data
  redraw()

func redraw():
  # This should hopefully be called not-so-often
  var max_x = 0; var max_y = 0;
  for child in offset_container.get_children():
    child.queue_free()

  var units_and_positions = position_units(data)
  if not units_and_positions:
    return

  for record in units_and_positions:
    var unit = record[0]
    var unit_x = record[1]
    var unit_y = record[2]

    var polygon = OutlinedPolygon2D.new()
    var vertices = PoolVector2Array()

    var poly_coords = squares_to_polygon(unit.kind.tiles)

    var x_ofs = unit_x * 50
    var y_ofs = unit_y * 50
    for xy in poly_coords:
      var x = xy[0] * 50; var y = xy[1] * 50;
      max_x = max(max_x, x + x_ofs)
      max_y = max(max_y, y + y_ofs)
      vertices.append(Vector2(x, y))

    polygon.color = Colour.to_color(unit.kind.colour)
    polygon.position = Vector2(x_ofs, y_ofs)
    polygon.polygon = vertices

    var label = Label.new()
    label.text = "%s (%d)" % [unit.kind.label, unit.health]
    polygon.add_child(label)

    offset_container.add_child(polygon)
  offset_container.position = Vector2(-max_x / 2, -max_y / 2)

  scale_container.position = Vector2(rect_size.x / 2, rect_size.y / 2)
  var scale = 1.0
  scale = min(scale, rect_size.x / max_x)
  scale = min(scale, rect_size.y / max_y)
  scale_container.scale = Vector2(scale, scale)
