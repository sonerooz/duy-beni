extends Control

@onready var kelime_etiketi = $ANAKELIME
@onready var sure_etiketi = $"HBoxContainer/Sayacetiketi"
@onready var oyun_timer = $Timer
@onready var sozluk_popup = $SozlukPopup
@onready var sozluk_kelime_etiketi = $SozlukPopup/AnlamEtiketi
@onready var kapat_butonu = $SozlukPopup/KapatButonu

# --- BUTON REFERANSLARI ---
@onready var buton_dogru = $AksiyonButonlari/DOGRU
@onready var buton_pas = $AksiyonButonlari/PAS
@onready var kelime_anla_butonu = $HBoxContainer/kelime_anlami

var kalan_sure = 0
var su_anki_kelime = ""

func _ready():
	Global.son_dogru = 0
	Global.son_pas = 0
	kalan_sure = Global.tur_suresi
	sozluk_popup.visible = false
	
	# --- BUTONLARA SCALE MÜDAHALESİ ---
	var efekt_butonlari = [buton_dogru, buton_pas, kelime_anla_butonu]
	await get_tree().process_frame 
	
	for btn in efekt_butonlari:
		if btn:
			btn.pivot_offset = btn.size / 2 
			if not btn.mouse_entered.is_connected(_on_button_hover):
				btn.mouse_entered.connect(_on_button_hover.bind(btn))
			if not btn.mouse_exited.is_connected(_on_button_normal):
				btn.mouse_exited.connect(_on_button_normal.bind(btn))
			_yazi_rengini_degistir(btn, Color.BLACK)
	
	if sure_etiketi:
		sure_etiketi.custom_minimum_size = Vector2(400, 0) 
		sure_etiketi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sure_etiketi.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		sure_etiketi.text = str(kalan_sure)
	
	if not kapat_butonu.pressed.is_connected(_on_kapat_buton_pressed):
		kapat_butonu.pressed.connect(_on_kapat_buton_pressed)
	
	oyun_timer.start()
	yeni_kelime_getir()

# --- EFEKT FONKSİYONLARI ---
func _on_button_hover(btn: Button):
	create_tween().tween_property(btn, "scale", Vector2(1.02, 1.02), 0.1).set_trans(Tween.TRANS_SINE)
	_yazi_rengini_degistir(btn, Color.WHITE)

func _on_button_normal(btn: Button):
	create_tween().tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
	_yazi_rengini_degistir(btn, Color.BLACK)

func _yazi_rengini_degistir(btn: Button, renk: Color):
	for child in btn.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", renk)

# --- GÜNCEL KELİME VE PUNTO MANTIĞI ---
func yeni_kelime_getir():
	su_anki_kelime = Global.rastgele_kelime_getir()
	if su_anki_kelime != "":
		
		var kelime_listesi = su_anki_kelime.split(" ")
		var gosterilecek_metin = su_anki_kelime
		var yeni_punto = 160 # Varsayılan punto
		
		# EĞER KELİME 2 VEYA DAHA FAZLAYSA (Örn: "Dondurma Kabı")
		if kelime_listesi.size() >= 2:
			gosterilecek_metin = su_anki_kelime.replace(" ", "\n")
			yeni_punto = 160 # İki satıra çıktığı için puntoyu büyük bırakıyoruz
			
		# EĞER TEK KELİMEYSE VE ÇOK UZUNSA (Örn: "Muvaffakiyetsizleş")
		else:
			var kelime_uzunlugu = su_anki_kelime.length()
			if kelime_uzunlugu > 13:
				yeni_punto = 110 # Sadece tek satıra sığmayanları küçültüyoruz
			elif kelime_uzunlugu > 11:
				yeni_punto = 130
		
		# Ayarları uygula
		kelime_etiketi.add_theme_font_size_override("font_size", yeni_punto)
		kelime_etiketi.text = gosterilecek_metin

func _on_timer_timeout():
	if kalan_sure > 0:
		kalan_sure -= 1
		if sure_etiketi: sure_etiketi.text = str(kalan_sure)
	else:
		oyun_timer.stop()
		get_tree().change_scene_to_file("res://tur_sonucu.tscn")

func _on_kelime_anlami_pressed():
	if su_anki_kelime == "": return
	var anlam = "Bu kelimenin sözlükte anlamı bulunmuyor."
	if Global.sozluk_verisi.has(su_anki_kelime):
		anlam = str(Global.sozluk_verisi[su_anki_kelime]).strip_edges().replace("/", "\n")
	sozluk_kelime_etiketi.text = su_anki_kelime + ":\n\n" + anlam
	sozluk_popup.visible = true
	oyun_timer.stop()

func _on_dogru_pressed():
	Global.son_dogru += 1
	yeni_kelime_getir()

func _on_pas_pressed():
	Global.son_pas += 1
	yeni_kelime_getir()

func _on_geri_pressed():
	get_tree().change_scene_to_file("res://ana_menu.tscn")

func _on_kapat_buton_pressed():
	sozluk_popup.visible = false
	oyun_timer.start()
