extends Control
class_name Draggable

@export var activation_event = "ui_select"
#@export var vertical_drag : bool = true
#@export var horizontal_drag : bool = true

var drag_offset : Vector2 = Vector2.ZERO
var drag_transition : Tween.TransitionType = Tween.TRANS_QUINT
var drag_ease : Tween.EaseType = Tween.EASE_OUT
var transforming : bool = false 
var mouse_on_parent : bool = false

@onready var parent : Control = get_parent()

func _init() -> void:
	#set_anchors_preset(PRESET_FULL_RECT)
	pass

func _ready():
	set_anchors_preset(PRESET_FULL_RECT)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _physics_process(delta):
	if transforming:
		var tween = get_tree().create_tween()
		tween.tween_property(parent,"global_position",get_global_mouse_position()+drag_offset,0.2).set_trans(drag_transition).set_ease(drag_ease)
		#position = get_global_mouse_position()+item_drag_offset

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(activation_event) and mouse_on_parent:
		transforming = true
		drag_offset = position - get_local_mouse_position()
		mouse_default_cursor_shape = CURSOR_DRAG
	if event.is_action_released(activation_event):
		transforming = false
		mouse_default_cursor_shape = CURSOR_ARROW

func _on_mouse_entered():
	mouse_on_parent = true

func _on_mouse_exited():
	mouse_on_parent = false
