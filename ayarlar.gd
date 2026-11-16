extends Control

# Yazı referansları - Sahnendeki tam yollar
@onready var sure_yazisi = $"VBoxContainer/SURE/SAG YAZI"
@onready var zorluk_yazisi = $"VBoxContainer/ZORLUK/SAG YAZI"
@onready var takim_yazisi = $"VBoxContainer/TAKIM/SAG YAZI"
@onready var gecmis_yazisi = $"VBoxContainer/GECMIS/SOL YAZI" 

# Animasyon ve renk yönetimi yapılacak buton listesi
@onready var butonlar = [
	$"VBoxContainer/DIL",
	$"VBoxContainer/SURE",
	$"VBoxContainer/ZORLUK",
	$"VBoxContainer/TAKIM",
	$"VBoxContainer/GECMIS"
]

func _ready():
	guncelle_arayuz()
	
	# Butonların nihai boyutlarını alması için bir kare bekliyoruz
	await get_tree().process_frame
	
	for buton in butonlar:
		# Merkezden büyüme ayarı (Pivot Offset)
		buton.pivot_offset = buton.size / 2
		
		# Başlangıç hali: Yazılar siyah
		_yazi_rengini_degistir(buton, Color.BLACK)
		
		# Fare sinyallerini bağla (Hover efektleri için)
		if not buton.mouse_entered.is_connected(_on_button_hover):
			buton.mouse_entered.connect(_on_button_hover.bind(buton))
		if not buton.mouse_exited.is_connected(_on_button_normal):
			buton.mouse_exited.connect(_on_button_normal.bind(buton))

func guncelle_arayuz():
	var sozluk = Global.yerellestirme["TR"]
	
	sure_yazisi.text = str(Global.tur_suresi) + " " + sozluk["SN"]
	zorluk_yazisi.text = Global.secili_zorluk
	takim_yazisi.text = str(Global.toplam_takim_sayisi)
	
	# Tasarımındaki "OYUN GEÇMİŞİ" metnini Global sözlükten çeker
	gecmis_yazisi.text = sozluk["GECMIS"] 

# --- Görsel Efekt Fonksiyonları ---

func _on_button_hover(btn: Button):
	# 1.01 Scale - Çok hafif büyüme
	create_tween().tween_property(btn, "scale", Vector2(1.01, 1.01), 0.1).set_trans(Tween.TRANS_SINE)
	# Üzerine gelince yazı rengi beyaz
	_yazi_rengini_degistir(btn, Color.WHITE)

func _on_button_normal(btn: Button):
	# Orijinal boyuta dönüş
	create_tween().tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
	# Fare çekilince yazı rengi siyah
	_yazi_rengini_degistir(btn, Color.BLACK)

func _yazi_rengini_degistir(btn: Button, renk: Color):
	for child in btn.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", renk)

# --- Buton Mantık Fonksiyonları (Sinyaller) ---

func _on_sure_pressed():
	var sureler = [30, 60, 90, 120]
	var index = sureler.find(Global.tur_suresi)
	Global.tur_suresi = sureler[(index + 1) % sureler.size()]
	guncelle_arayuz()

func _on_zorluk_pressed():
	var soz = Global.yerellestirme["TR"]
	var zorluklar = [soz["KOLAY"], soz["ORTA"], soz["ZOR"]]
	var index = zorluklar.find(Global.secili_zorluk)
	Global.secili_zorluk = zorluklar[(index + 1) % zorluklar.size()]
	guncelle_arayuz()

func _on_takim_pressed():
	Global.toplam_takim_sayisi = (Global.toplam_takim_sayisi % 4) + 1
	guncelle_arayuz()
func _on_gecmis_pressed():
	# Hiçbir değişken kontrolü yapmadan direkt Toplam Sonuç ekranına git
	# Çünkü veriyi zaten Global.gd açılışta diskten (oyun_gecmisi.save) yüklüyor.
	get_tree().change_scene_to_file("res://toplam_sonuc.tscn")

func _on_geri_pressed():
	get_tree().change_scene_to_file("res://ana_menu.tscn")
