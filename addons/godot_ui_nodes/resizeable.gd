extends Control
class_name Resizeable

@export var activation_event : String = 'ui_select'
@export var grab_area_size : float = 48

@export_group('Grabbers','grabber')
@export var grabber_size : float = 12
@export var grabber_color : Color = Color.WHITE
@export var grabber_outline_color : Color = Color.BLACK
@export var grabber_outline_width : float = 4

@export_group('Debug')
@export var show_grab_area : bool = false
@export var show_gizmo : bool = false

var active_handle : Control
var parent_pos : Vector2
var parent_size : Vector2
var flipped_v : bool = false
var flipped_h : bool = false
var top_handles : Array
var left_handles : Array
var right_handles : Array
var bottom_handles : Array
var transforming : bool = false

@onready var handles_container: Control
@onready var area_outline: ReferenceRect
@onready var gizmo: Line2D
@onready var parent : Control = get_parent()

func _init() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE

func _ready() -> void:
	if parent is TextureRect:
		parent.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	
	if gizmo == null:
		_create_gizmo()
	if area_outline == null:
		_create_area_outline()
	if handles_container == null:
		_create_handles_container()
	area_outline.border_color = grabber_outline_color
	area_outline.border_width = grabber_outline_width
	gizmo.visible = show_gizmo
	_generate_handles()

func _create_gizmo():
	gizmo = Line2D.new()
	gizmo.add_point(Vector2.ZERO)
	gizmo.add_point(Vector2.ZERO)
	add_child(gizmo)

func _create_handles_container():
	handles_container = Control.new()
	handles_container.set_anchors_preset(PRESET_FULL_RECT)
	add_child(handles_container)

func _create_area_outline():
	area_outline = ReferenceRect.new()
	area_outline.set_anchors_preset(PRESET_FULL_RECT)
	area_outline.editor_only = false
	#var new_material := ShaderMaterial.new()
	#new_material.shader = load("res://addons/godot_ui_nodes/transforming.gdshader")
	#area_outline.material = new_material
	add_child(area_outline)

func _process(delta: float) -> void:
	if transforming:
		_resize()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(activation_event) and active_handle:
		transforming = true
		_init_gizmo()
	if event.is_action_released(activation_event):
		transforming = false

func set_font_size(font_size : int):
	if parent is Label:
		var ratio : float = parent_size.y/font_size
		parent.set('theme_override_font_sizes/font_size', font_size)
		parent.size.x = parent_size.x*ratio

func _resize() -> void:
	gizmo.points[1] = get_global_mouse_position()
	var delta = gizmo.points[1]-gizmo.points[0]
	
	var temp_size : float
	
	var right = right_handles
	var left = left_handles 
	var top = top_handles 
	var bottom = bottom_handles
	
	if parent is TextureRect:
		right = right_handles if !parent.flip_h else left_handles
		left = left_handles if !parent.flip_h else right_handles
		top = top_handles if !parent.flip_v else bottom_handles
		bottom = bottom_handles if !parent.flip_v else top_handles
	
	if active_handle in top:
		temp_size = parent_size.y - delta.y
		if temp_size < 0:
			_init_gizmo()
			if parent is TextureRect:
				parent.flip_v = !parent.flip_v
				flipped_v = !flipped_v
			return
		parent.position.y = parent_pos.y + delta.y 
		parent.size.y = temp_size
		set_font_size(temp_size)

	if active_handle in left:
		temp_size = parent_size.x - delta.x
		if temp_size < 0:
			_init_gizmo()
			if parent is TextureRect:
				parent.flip_h = !parent.flip_h
				flipped_h = !flipped_h
			return
		parent.position.x = parent_pos.x + delta.x
		parent.size.x = temp_size
		#set_font_size(temp_size)

	if active_handle in bottom:
		temp_size = parent_size.y + delta.y
		if temp_size < 0:
			_init_gizmo()
			if parent is TextureRect:
				parent.flip_v = !parent.flip_v
				flipped_v = !flipped_v
			return
		parent.size.y = temp_size
		set_font_size(temp_size)

	if active_handle in right:
		temp_size = parent_size.x + delta.x
		if temp_size < 0:
			_init_gizmo()
			if parent is TextureRect:
				parent.flip_h = !parent.flip_h
				flipped_h = !flipped_h
			return
		parent.size.x = temp_size
		#set_font_size(temp_size)


func _init_gizmo() -> void:
	gizmo.points[0] = get_global_mouse_position()
	parent_size = parent.size
	if parent is Label:
		parent_size = Vector2(parent.size.x,parent.get('theme_override_font_sizes/font_size'))
	parent_pos = parent.global_position
	flipped_v = false
	flipped_h = false

func _create_handle(anchor_preset : LayoutPreset) -> Control:
	var new_handle = ColorRect.new()
	new_handle.color = Color.TRANSPARENT
	new_handle.custom_minimum_size = Vector2(grabber_size,grabber_size)
	new_handle.set_anchors_preset(anchor_preset)
	return new_handle

func _create_grab_area(anchor_preset : LayoutPreset) -> Control:
	var grab_area = ReferenceRect.new()
	grab_area.border_color = Color.BLUE
	grab_area.border_width = 4
	grab_area.editor_only = !show_grab_area
	grab_area.custom_minimum_size = Vector2(grabber_size+grab_area_size,grabber_size+grab_area_size)
	if anchor_preset in [PRESET_BOTTOM_WIDE,PRESET_BOTTOM_RIGHT,PRESET_BOTTOM_LEFT]:
		grab_area.position.y -= grabber_size
	if anchor_preset in [PRESET_RIGHT_WIDE,PRESET_BOTTOM_RIGHT,PRESET_TOP_RIGHT]:
		grab_area.position.x -= grabber_size
	grab_area.position -= Vector2((grab_area_size+grabber_size)/2,(grab_area_size+grabber_size)/2)
	grab_area.set_anchors_preset(anchor_preset)
	grab_area.connect("mouse_entered",_on_grab_area_entered.bind(grab_area))
	grab_area.connect("mouse_exited",_on_grab_area_exited)
	grab_area.name = 'grab_area'
	grab_area.mouse_filter = Control.MOUSE_FILTER_STOP
	_set_cursor_shape(grab_area,anchor_preset)
	return grab_area

func _create_grabber(anchor_preset : LayoutPreset) -> Control:
	var grabber = ColorRect.new()
	grabber.color = grabber_color
	grabber.custom_minimum_size = Vector2(grabber_size,grabber_size)
	grabber.set_anchors_preset(PRESET_CENTER)
	grabber.position -= Vector2(grabber_size,grabber_size)
	if anchor_preset in [PRESET_TOP_WIDE,PRESET_BOTTOM_WIDE]:
		grabber.position.x += grabber_size/2
	if anchor_preset in [PRESET_LEFT_WIDE,PRESET_RIGHT_WIDE]:
		grabber.position.y += grabber_size/2
	grabber.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grabber.name = 'grabber'
	return grabber

func _create_grabber_outline() -> Control:
	var grabber_outline = ReferenceRect.new()
	grabber_outline.border_color = grabber_outline_color
	grabber_outline.border_width = grabber_outline_width
	grabber_outline.editor_only = false
	grabber_outline.set_anchors_preset(PRESET_FULL_RECT)
	grabber_outline.name = 'grabber_outline'
	return grabber_outline

func _generate_handles() -> void:
	var handle_anchors : Array[LayoutPreset] = [
		PRESET_BOTTOM_WIDE,PRESET_TOP_WIDE,PRESET_LEFT_WIDE,PRESET_RIGHT_WIDE,
		PRESET_BOTTOM_LEFT,PRESET_BOTTOM_RIGHT,PRESET_TOP_LEFT,PRESET_TOP_RIGHT]
	
	for anchor_preset in handle_anchors:
		var new_handle = _create_handle(anchor_preset)
		var grab_area = _create_grab_area(anchor_preset)
		var grabber = _create_grabber(anchor_preset)
		var grabber_outline = _create_grabber_outline()
		
		handles_container.add_child(new_handle)
		new_handle.add_child(grab_area)	
		new_handle.add_child(grabber)
		grabber.add_child(grabber_outline)
		
		assign_handle_category(grab_area,anchor_preset)


func assign_handle_category(grab_area : Control, anchor_preset : LayoutPreset) -> void:
	if anchor_preset in [PRESET_TOP_WIDE, PRESET_TOP_LEFT, PRESET_TOP_RIGHT]:
		top_handles.append(grab_area)
	if anchor_preset in [PRESET_BOTTOM_WIDE, PRESET_BOTTOM_LEFT, PRESET_BOTTOM_RIGHT]:
		bottom_handles.append(grab_area)
	if anchor_preset in [PRESET_LEFT_WIDE, PRESET_BOTTOM_LEFT, PRESET_TOP_LEFT]:
		left_handles.append(grab_area)
	if anchor_preset in [PRESET_RIGHT_WIDE, PRESET_BOTTOM_RIGHT, PRESET_TOP_RIGHT]:
		right_handles.append(grab_area)

func _set_cursor_shape(grab_area:Control,anchor_preset:LayoutPreset) -> void:
	if anchor_preset in [PRESET_LEFT_WIDE, PRESET_RIGHT_WIDE]:
		grab_area.mouse_default_cursor_shape = CURSOR_HSIZE
	if anchor_preset in [PRESET_TOP_WIDE, PRESET_BOTTOM_WIDE]:
		grab_area.mouse_default_cursor_shape = CURSOR_VSIZE
	if anchor_preset in [PRESET_BOTTOM_LEFT, PRESET_TOP_RIGHT]:
		grab_area.mouse_default_cursor_shape = CURSOR_BDIAGSIZE
	if anchor_preset in [PRESET_TOP_LEFT, PRESET_BOTTOM_RIGHT]:
		grab_area.mouse_default_cursor_shape = CURSOR_FDIAGSIZE


func _on_grab_area_entered(grab_area : Control) -> void:
	if not active_handle:
		active_handle = grab_area


func _on_grab_area_exited() -> void:
	if not transforming:
		active_handle = null
