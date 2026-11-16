extends Button

var target_scale = Vector2(1.0, 1.0)

func _ready():
	# Pivotu merkeze alıyoruz (Butonun 800x250 ise 400x125 olur)
	pivot_offset = size / 2

func _process(delta):
	# Yumuşak geçiş efektini sağlar
	scale = scale.lerp(target_scale, 0.2)

func _on_button_down():
	# BASINCA BÜYÜSÜN: %15 büyüme (1.15)
	target_scale = Vector2(1.15, 1.15)
	# O inatçı gri kutuyu engellemek için odaklanmayı bırakıyoruz
	release_focus()

func _on_button_up():
	# TIKLAMAYI BIRAKINCA: Eski boyuta dön
	target_scale = Vector2(1.0, 1.0)


func _on_pressed() -> void:
	pass # Replace with function body.
