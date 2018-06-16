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

func _draw():
  # First determine bounds of tiles
  var min_x = null; var max_x; var min_y; var max_y
  for unit in data:
    for i in range(unit[2].size() / 2):
      if min_x == null:
        min_x = unit[1][0] + unit[2][2 * i]
        max_x = unit[1][0] + unit[2][2 * i]
        min_y = unit[1][1] + unit[2][2 * i + 1]
        max_y = unit[1][1] + unit[2][2 * i + 1]
      else:
        min_x = min(min_x, unit[1][0] + unit[2][2 * i])
        max_x = max(max_x, unit[1][0] + unit[2][2 * i])
        min_y = min(min_y, unit[1][1] + unit[2][2 * i + 1])
        max_y = max(max_y, unit[1][1] + unit[2][2 * i + 1])
  if min_x == null:
    return

  # Determine tile_size and offsets
  var width = max_x - min_x + 1
  var height = max_y - min_y + 1
  var tile_size = min(max_tile_size, min(rect_size.x / width, rect_size.y / height))
  var off_x = (rect_size.x - tile_size * width) / 2
  var off_y = (rect_size.y - tile_size * height) / 2

  var reverse_map = []
  for i in range(width * height):
    reverse_map.append(-1)

  var x; var y; var unit
  for j in range(data.size()):
    unit = data[j]
    for i in range(unit[2].size() / 2):
      x = unit[1][0] + unit[2][2 * i] - min_x
      y = unit[1][1] + unit[2][2 * i + 1] - min_y
      reverse_map[y * width + x] = j
      draw_rect(
          Rect2(x * tile_size + off_x, y * tile_size + off_y, tile_size, tile_size),
          unit[0],
          true
        )

  # Draw bars between different units
  for x in range(width):
    for y in range(height):
      var current = reverse_map[y * width + x]
      if (x == 0 && current != -1) || (x > 0 && current != reverse_map[y * width + x - 1]):
        draw_line(Vector2(off_x + x * tile_size, off_y + y * tile_size), Vector2(off_x + x * tile_size, off_y + (y + 1) * tile_size), line_color, 2)
      if (y == 0 && current != -1) || (y > 0 && current != reverse_map[(y - 1) * width + x]):
        draw_line(Vector2(off_x + x * tile_size, off_y + y * tile_size), Vector2(off_x + (x + 1) * tile_size, off_y + y * tile_size), line_color, 2)
      if x == width - 1 && current != -1:
        draw_line(Vector2(off_x + (x + 1) * tile_size, off_y + y * tile_size), Vector2(off_x + (x + 1) * tile_size, off_y + (y + 1) * tile_size), line_color, 2)
      if y == height - 1 && current != -1:
        draw_line(Vector2(off_x + x * tile_size, off_y + (y + 1) * tile_size), Vector2(off_x + (x + 1) * tile_size, off_y + (y + 1) * tile_size), line_color, 2)
