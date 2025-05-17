extends Control

signal spell_press(spell)
signal book_opened(i, book)

@onready var spell_button_scene = preload('res://components/spell_button.tscn')

@onready var g = get_node('/root/global')

var tech_levels = null: set = set_tech_levels
var books = null: set = set_books
var spell_buttons = []
var enabled_filter = null
var unlocked_filter = null
var unlockable_filter = null
var current_book = null

@onready var book_buttons_vbox = $book_buttons
@onready var spell_panel = $spell_panel
@onready var spell_panel_close_button = $spell_panel/ninepatch/close_button
@onready var spell_grid = $spell_panel/ninepatch/hbox
@onready var template_book_button = $templates/book_button
@onready var animation_player = $animation_player

func _ready():
	spell_panel_close_button.connect('pressed', Callable(self, 'on_close_book'))
	$templates.visible = false
	redraw()

func _unhandled_input(event):
	if g.event_is_pressed(event):
		on_close_book()

func redraw_tech_levels():
	if tech_levels == null: return
	var book_buttons = book_buttons_vbox.get_children()
	for index in range(len(book_buttons)):
		var book_button = book_buttons[index]
		g.child(book_button, 'level').text = str(tech_levels[index])

func redraw_tech_upgrades(upgraded_book):
	for i in range(len(books)):
		var btn = book_buttons_vbox.get_child(i)
		var btn_upgrade = g.child(btn, 'upgrade_arrow')
		btn_upgrade.visible = false #(upgraded_book == null)

func redraw():
	spell_panel.visible = false
	g.clear_children(book_buttons_vbox)

	if books == null: return
	if book_buttons_vbox == null: return

	# Prevent the book buttons from getting confused by the old book buttons??
	await get_tree().idle_frame

	print('Regenerating books')
	for index in range(len(books)):
		var book = books[index]
		var btn = template_book_button.duplicate()
		book_buttons_vbox.add_child(btn)
		var btn_book = g.child(btn, 'book')
		var btn_upgrade = g.child(btn, 'upgrade_arrow')
		btn_upgrade.visible = false
		btn_book.texture_normal = g.get_book_texture(book.get_id())
		btn_book.connect('pressed', Callable(self, 'on_open_book').bind(index, book))
		btn_upgrade.connect('pressed', Callable(self, 'on_book_upgrade').bind(index, book))

	redraw_tech_levels()

func on_close_book():
	if current_book == null: return
	current_book = null
	animation_player.play_backwards('spell_panel_enter')

func redraw_spells():
	if current_book == null:
		return
	var spells = g.filter(current_book.get_spells(), funcref(g, 'is_not_tech_spell'))
	g.clear_children(spell_grid)
	spell_buttons = g.make_spell_buttons(spells, true, false, enabled_filter, unlocked_filter, unlockable_filter)
	for i in range(len(spell_buttons)):
		var spell_button = spell_buttons[i]
		var spell = spell_button.spell
		spell_button.connect('pressed', Callable(self, 'on_spell_pressed').bind(i, spell))
		spell_grid.add_child(spell_button)

func on_open_book(index, book):
	if current_book == book: return
	var old_book = current_book
	current_book = book
	redraw_spells()
	spell_panel.visible = true
	if old_book == null:
		animation_player.play('spell_panel_enter')
	emit_signal('book_opened', index, book)

func set_tech_levels(tech_levels_):
	tech_levels = tech_levels_
	redraw_tech_levels()

func set_books(books_):
	books = books_
	redraw()

func on_spell_pressed(index, spell):
	emit_signal('spell_press', spell)

func on_book_upgrade(index, book):
	for spell_id in book.get_spells():
		print('considering ' + spell_id)
		var spell = g.get_rules().get_spell(spell_id)
		if spell.is_tech_spell():
			print('casting ' + spell_id)
			emit_signal('spell_press', spell)
			return
