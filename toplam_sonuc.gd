extends Control

# Skor tablosu + kazanan ekranı.
#  - Maç sürüyorsa: ara skorlar ve "SIRADAKİ TAKIM" butonu
#  - Maç bittiyse (veya Ayarlar > Oyun Geçmişi'nden açıldıysa): kazanan ve "YENİ OYUN"

@onready var grid_listesi = $GridContainer
@onready var ana_baslik = get_node_or_null("Label")
@onready var yeni_oyun_btn = get_node_or_null("VBoxContainer/yeni_oyun")
@onready var ana_menu_btn = get_node_or_null("VBoxContainer/ana_menu")

const ALTIN = Color(0.55, 0.05, 0.05)   # kazanan satırı rengi (koyu kırmızı)
var kazanan_etiketi : Label

func _ready():
	grid_listesi.columns = 3
	grid_listesi.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grid_listesi.position.y -= 180
	grid_listesi.add_theme_constant_override("h_separation", 80)
	grid_listesi.add_theme_constant_override("v_separation", 20)
	arayuz_metinlerini_yerellestir()
	listeyi_guncelle()
	await get_tree().process_frame
	_kazanani_goster()

func _mac_suruyor() -> bool:
	return Global.siradaki_takim_var_mi()

func arayuz_metinlerini_yerellestir():
	var s = Global.soz()
	if ana_baslik:
		ana_baslik.text = s["SONUCLAR"]
	if yeni_oyun_btn:
		_yazi_ayarla(yeni_oyun_btn, s["SIRADAKI"] if _mac_suruyor() else s["YENI OYUN"])
	if ana_menu_btn:
		_yazi_ayarla(ana_menu_btn, s["ANA MENU"])

func _yazi_ayarla(dugum: Node, metin: String):
	if dugum is Button:
		dugum.text = metin
	for child in dugum.get_children():
		if child is Label:
			child.text = metin

func listeyi_guncelle():
	for n in grid_listesi.get_children():
		n.queue_free()
	var s = Global.soz()
	_hucre_olustur(s["TAKIM"], 80, Color.BLACK)
	_hucre_olustur(s["DOGRU"], 80, Color.BLACK)
	_hucre_olustur(s["PAS"], 80, Color.BLACK)
	for i in range(3):
		var orta = CenterContainer.new()
		orta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cizgi = ColorRect.new()
		cizgi.color = Color.BLACK
		cizgi.custom_minimum_size = Vector2(320, 10)
		orta.add_child(cizgi)
		grid_listesi.add_child(orta)

	var bitti = not _mac_suruyor()
	var kazananlar = Global.kazananlar() if bitti else []
	var takimlar = Global.tur_sonuclari.keys()
	takimlar.sort()
	for t in takimlar:
		var v = Global.tur_sonuclari[t]
		var renk = ALTIN if (t in kazananlar and Global.tur_sonuclari.size() > 1) else Color.BLACK
		var ad = s["TAKIM"] + " " + str(t)
		if renk == ALTIN: ad = "★ " + ad
		_hucre_olustur(ad, 90, renk)
		_hucre_olustur(str(v["dogru"]), 110, renk)
		_hucre_olustur(str(v["pas"]), 110, renk)

func _kazanani_goster():
	if _mac_suruyor() or Global.tur_sonuclari.is_empty(): return
	var s = Global.soz()
	var kazananlar = Global.kazananlar()
	var metin = ""
	if Global.tur_sonuclari.size() == 1:
		var t = Global.tur_sonuclari.keys()[0]
		metin = s["SKOR"] + ": " + str(Global.tur_sonuclari[t]["dogru"])
	elif kazananlar.size() == 1:
		metin = s["KAZANAN"] + "\n" + s["TAKIM"] + " " + str(kazananlar[0])
	else:
		var adlar = []
		for t in kazananlar: adlar.append(str(t))
		metin = s["BERABERE"] + "\n" + s["TAKIM"] + " " + " & ".join(adlar)
	kazanan_etiketi = Label.new()
	kazanan_etiketi.text = metin
	kazanan_etiketi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kazanan_etiketi.add_theme_font_size_override("font_size", 110)
	kazanan_etiketi.add_theme_color_override("font_color", ALTIN)
	add_child(kazanan_etiketi)
	kazanan_etiketi.position = Vector2(0, grid_listesi.position.y + grid_listesi.size.y + 60)
	kazanan_etiketi.size = Vector2(size.x, 300)
	kazanan_etiketi.pivot_offset = Vector2(size.x / 2, 150)
	kazanan_etiketi.scale = Vector2(0.6, 0.6)
	create_tween().tween_property(kazanan_etiketi, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Global.titret(200)
	Global.mac_devam_ediyor = false

func _hucre_olustur(metin: String, punto: int, renk: Color):
	var l = Label.new()
	l.text = metin
	l.add_theme_color_override("font_color", renk)
	l.add_theme_font_size_override("font_size", punto)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_listesi.add_child(l)

func _on_yeni_oyun_pressed():
	if _mac_suruyor():
		Global.su_anki_takim_sirasi += 1
	else:
		Global.yeni_mac_serisi_baslat()
	get_tree().change_scene_to_file("res://hazir.tscn")

func _on_ana_menu_pressed():
	Global.mac_devam_ediyor = false
	get_tree().change_scene_to_file("res://ana_menu.tscn")

# Android geri tuşu: "ANA MENÜ" butonuyla aynı
func geri_tusu():
	_on_ana_menu_pressed()
