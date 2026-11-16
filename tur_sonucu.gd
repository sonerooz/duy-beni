extends Control

# Sahne hiyerarşisindeki isimlere göre (SONUC ve ADET)
@onready var dogru_label = $VBoxContainer/SONUC
@onready var pas_label = $VBoxContainer/ADET

func _ready():
	# 1. Tabelaya o anki performansı yazdır
	if dogru_label:
		dogru_label.text = str(Global.son_dogru)
	if pas_label:
		pas_label.text = str(Global.son_pas)
	
	# 2. Skoru mevcut takıma (Global.su_anki_takim_sirasi) kaydet
	var t_adi = "Takım " + str(Global.su_anki_takim_sirasi)
	Global.tur_sonuclari[t_adi] = "Doğru: " + str(Global.son_dogru) + " | Pas: " + str(Global.son_pas)
	
	# 3. Veriyi hem belleğe hem diske kaydet
	Global.puanlari_kaydet()

func _on_devam_et_pressed():
	# Her zaman önce Toplam Sonuç ekranına gider, sıra orada kontrol edilir
	get_tree().change_scene_to_file("res://toplam_sonuc.tscn")
