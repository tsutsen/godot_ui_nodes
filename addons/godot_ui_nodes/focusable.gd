extends Control
class_name Focusable

@export var tween_on_hover : Dictionary # property_string_name : [value_in, duration_in, value_out, duration_out]

var active : bool = false :
	set(new_status):
		active = new_status
		if active:
			var tween : Tween = create_tween()
			for property in tween_on_hover.keys():
				tween.parallel().tween_property(parent,property,tween_on_hover[property][0],tween_on_hover[property][1])
		else:
			var tween : Tween = create_tween()
			for property in tween_on_hover.keys():
				tween.parallel().tween_property(parent,property,tween_on_hover[property][2],tween_on_hover[property][3])


@onready var parent : Control = get_parent()

func _ready() -> void:
	for property in tween_on_hover.keys():
		parent.set(property,tween_on_hover[property][2])
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_PASS
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _on_focus_entered() -> void:
	active = true

func _on_focus_exited() -> void:
	active = false
