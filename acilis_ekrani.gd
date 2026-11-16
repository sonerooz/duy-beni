extends Control

func _ready():
	# 1. Animasyon düğümü bozulduğu için kod ile basit bir geçiş yapalım
	# Logoyu (TextureRect) 2 saniyede görünür hale getiriyoruz
	var tween = create_tween()
	$TextureRect.modulate.a = 0 # Önce gizle
	tween.tween_property($TextureRect, "modulate:a", 1.0, 2.0) 
	
	# 2. Bekleme süresi ve Geçiş
	# 3 saniye sonra ana menüye otomatik geçer
	await get_tree().create_timer(3.0).timeout
	
	# Dosya ismini 'u' olarak düzelttiğimiz için bu yol artık çalışacaktır
	get_tree().change_scene_to_file("res://ana_menu.tscn")
