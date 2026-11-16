extends Control

# Takımlar arası "Hazır mısınız?" ekranı.
# BAŞLA'ya basınca 3-2-1 geri sayım yapılır, ardından tur başlar.

@onready var takim_etiketi = $VBoxContainer/TAKIM
@onready var hazir_etiketi = $VBoxContainer/HAZIR
@onready var sayac_etiketi = $VBoxContainer/SAYAC
@onready var bilgi_etiketi = $VBoxContainer/BILGI
@onready var ipucu_etiketi = $VBoxContainer/IPUCU
@onready var basla_btn = $basla

var geri_sayim_basladi := false

func _ready():
	var s = Global.soz()
	takim_etiketi.text = s["TAKIM"] + " " + str(Global.su_anki_takim_sirasi)
	if Global.toplam_takim_sayisi > 1:
		takim_etiketi.text += "  (" + str(Global.su_anki_takim_sirasi) + "/" + str(Global.toplam_takim_sayisi) + ")"
	hazir_etiketi.text = s["HAZIR"]
	bilgi_etiketi.text = Global.aktif_paket()["ad"] + "  ·  " + s[Global.secili_zorluk] + "  ·  " + str(Global.tur_suresi) + " " + s["SN"]
	bilgi_etiketi.add_theme_font_size_override("font_size", 80)
	ipucu_etiketi.text = s["ANLATACAK"]
	ipucu_etiketi.add_theme_font_size_override("font_size", 70)
	sayac_etiketi.text = ""
	basla_btn.text = s["TUR_BASLA"]
	await get_tree().process_frame
	basla_btn.pivot_offset = basla_btn.size / 2

func _on_basla_pressed():
	if geri_sayim_basladi: return
	geri_sayim_basladi = true
	basla_btn.disabled = true
	basla_btn.visible = false
	for n in [3, 2, 1]:
		sayac_etiketi.text = str(n)
		sayac_etiketi.pivot_offset = sayac_etiketi.size / 2
		sayac_etiketi.scale = Vector2(1.6, 1.6)
		create_tween().tween_property(sayac_etiketi, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK)
		Global.ses_cal("tik")
		Global.titret(40)
		await get_tree().create_timer(1.0).timeout
		if not is_inside_tree(): return
	Global.ses_cal("son")
	get_tree().change_scene_to_file("res://oyun_ekrani.tscn")

func _on_geri_pressed():
	Global.mac_devam_ediyor = false
	get_tree().change_scene_to_file("res://ana_menu.tscn")

# Android geri tuşu: ana menüye dön
func geri_tusu():
	_on_geri_pressed()
