extends Control

@onready var ana_baslik = $VBoxContainer/TUR_SONUCU
@onready var dogru_metni = $VBoxContainer/DOGRU
@onready var dogru_skor = $VBoxContainer/SONUC
@onready var pas_metni = $VBoxContainer/PAS
@onready var pas_skor = $VBoxContainer/ADET
@onready var devam_et_btn = get_node_or_null("devam_et")

func _ready():
	_arayuzu_hazirla()
	Global.turu_kaydet()

func _arayuzu_hazirla():
	var s = Global.soz()
	if ana_baslik:
		ana_baslik.text = s["TAKIM"] + " " + str(Global.su_anki_takim_sirasi)
	if devam_et_btn:
		_buton_metni_ayarla(devam_et_btn, s["DEVAM ET"])
	if dogru_metni: dogru_metni.text = s["DOGRU"]
	if pas_metni: pas_metni.text = s["PAS"]
	if dogru_skor: dogru_skor.text = str(Global.son_dogru)
	if pas_skor: pas_skor.text = str(Global.son_pas)

func _buton_metni_ayarla(btn: Node, metin: String):
	if btn is Button:
		btn.text = metin
	for child in btn.get_children():
		if child is Label:
			child.text = metin

func _on_devam_et_pressed():
	get_tree().change_scene_to_file("res://toplam_sonuc.tscn")

func _on_devam_et_button_down():
	_on_devam_et_pressed()

# Android geri tuşu: "DEVAM ET" ile aynı (skor zaten kaydedildi)
func geri_tusu():
	_on_devam_et_pressed()
