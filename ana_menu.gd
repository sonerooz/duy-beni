extends Control

@onready var basla_btn = $"VBoxContainer/OYUNA BAŞLA"
@onready var ayarlar_btn = $VBoxContainer/AYARLAR
@onready var sozluk_btn = $"VBoxContainer/SÖZLÜK"

func _ready():
	dili_uygula()
	var butonlar = [basla_btn, ayarlar_btn, sozluk_btn]
	await get_tree().process_frame
	for buton in butonlar:
		if buton:
			buton.pivot_offset = buton.size / 2
			if not buton.mouse_entered.is_connected(_on_button_hover):
				buton.mouse_entered.connect(_on_button_hover.bind(buton))
			if not buton.mouse_exited.is_connected(_on_button_normal):
				buton.mouse_exited.connect(_on_button_normal.bind(buton))

func dili_uygula():
	var s = Global.soz()
	if basla_btn: basla_btn.text = s["BASLA"]
	if ayarlar_btn: ayarlar_btn.text = s["AYARLAR"]
	if sozluk_btn: sozluk_btn.text = s["SOZLUK"]

func _on_button_hover(btn: Button):
	create_tween().tween_property(btn, "scale", Vector2(1.02, 1.02), 0.1).set_trans(Tween.TRANS_SINE)

func _on_button_normal(btn: Button):
	create_tween().tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)

func _on_oyuna_basla_pressed():
	Global.yeni_mac_serisi_baslat()
	get_tree().change_scene_to_file("res://hazir.tscn")

func _on_ayarlar_pressed():
	get_tree().change_scene_to_file("res://ayarlar.tscn")

func _on_sozluk_pressed():
	get_tree().change_scene_to_file("res://sozluk.tscn")

# Android geri tuşu: ana menüde uygulamadan çıkar
func geri_tusu():
	get_tree().quit()
