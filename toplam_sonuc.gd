extends Control

@onready var grid_listesi = $GridContainer

func _ready():
	# Konumlandırma: Listeyi yukarı çekiyoruz
	grid_listesi.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grid_listesi.position.y -= 180
	
	# MESAFE AYARLARI:
	grid_listesi.add_theme_constant_override("h_separation", 80) 
	grid_listesi.add_theme_constant_override("v_separation", 20) 
	
	listeyi_guncelle()

func listeyi_guncelle():
	# 1. Temizlik
	for n in grid_listesi.get_children():
		n.queue_free()
	
	# 2. Sütun Başlıkları (80 Punto)
	_baslik_olustur("TAKIM")
	_baslik_olustur("DOĞRU")
	_baslik_olustur("PAS")
	
	# 3. Tam Ortalanmış Başlık Altı Çizgileri
	for i in range(3):
		# CenterContainer çizgiyi hücre içinde tam ortalar
		var orta_nokta = CenterContainer.new()
		orta_nokta.custom_minimum_size = Vector2(0, 2) # Başlık ile mesafe
		orta_nokta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var cizgi = ColorRect.new()
		cizgi.color = Color.BLACK
		cizgi.custom_minimum_size = Vector2(320, 10) # Çizgi genişliği ve kalınlığı
		
		orta_nokta.add_child(cizgi)
		grid_listesi.add_child(orta_nokta)
	
	# 4. Verileri Yerleştir
	for takim_anahtar in Global.tur_sonuclari.keys():
		var veri_metni = Global.tur_sonuclari[takim_anahtar]
		var parcalar = veri_metni.split("|")
		var dogru_sayisi = parcalar[0].split(":")[1].strip_edges()
		var pas_sayisi = parcalar[1].split(":")[1].strip_edges()
		
		# Takım (90 Punto)
		_hucre_olustur(takim_anahtar.to_upper(), 90)
		# Doğru (110 Punto)
		_hucre_olustur(dogru_sayisi, 110)
		# Pas (110 Punto)
		_hucre_olustur(pas_sayisi, 110)

func _baslik_olustur(metin: String):
	var l = Label.new()
	l.text = metin
	l.add_theme_color_override("font_color", Color.BLACK)
	l.add_theme_font_size_override("font_size", 80)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_listesi.add_child(l)

func _hucre_olustur(metin: String, punto: int):
	var l = Label.new()
	l.text = metin
	l.add_theme_color_override("font_color", Color.BLACK)
	l.add_theme_font_size_override("font_size", punto)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_listesi.add_child(l)

func _on_yeni_oyun_pressed():
	if Global.su_anki_takim_sirasi < Global.toplam_takim_sayisi:
		Global.su_anki_takim_sirasi += 1
		get_tree().change_scene_to_file("res://oyun_ekrani.tscn")
	else:
		get_tree().change_scene_to_file("res://ana_menu.tscn")

# Android geri tuşu: "ANA MENÜ" butonuyla aynı
func geri_tusu():
	_on_ana_menu_pressed()

func _on_ana_menu_pressed():
	get_tree().change_scene_to_file("res://ana_menu.tscn")
