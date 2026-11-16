extends Control

# --- 1. DEĞİŞKENLER VE REFERANSLAR ---
@onready var kelime_etiketi = $ANAKELIME
@onready var sure_etiketi = $"HBoxContainer/Sayacetiketi"
@onready var oyun_timer = $Timer

@onready var sozluk_popup = $SozlukPopup
@onready var sozluk_kelime_etiketi = $SozlukPopup/AnlamEtiketi
@onready var kapat_butonu = $SozlukPopup/KapatButonu

@onready var buton_dogru = $AksiyonButonlari/DOGRU
@onready var buton_pas = $AksiyonButonlari/PAS
@onready var kelime_anla_butonu = $HBoxContainer/kelime_anlami

const UYARI_SANIYESI = 10      # son kaç saniyede tik sesi + kırmızı sayaç
const TITRESIM_SANIYESI = 5    # son kaç saniyede titreşim
var kalan_sure = 0
var su_anki_kelime = ""
var sure_normal_renk : Color

# --- 2. BAŞLATMA ---
func _ready():
	_kurulum_yap()
	_efektleri_bagla()
	_oyunu_baslat()

func _kurulum_yap():
	Global.son_dogru = 0
	Global.son_pas = 0
	kalan_sure = Global.tur_suresi
	if sozluk_popup:
		sozluk_popup.visible = false
	dili_uygula()
	if sure_etiketi:
		sure_etiketi.custom_minimum_size = Vector2(400, 0)
		sure_etiketi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sure_etiketi.text = str(kalan_sure)
		sure_normal_renk = sure_etiketi.get_theme_color("font_color")

func _efektleri_bagla():
	var butonlar = [buton_dogru, buton_pas, kelime_anla_butonu]
	await get_tree().process_frame
	for btn in butonlar:
		if btn:
			btn.pivot_offset = btn.size / 2
			if not btn.mouse_entered.is_connected(_on_button_hover):
				btn.mouse_entered.connect(_on_button_hover.bind(btn))
			if not btn.mouse_exited.is_connected(_on_button_normal):
				btn.mouse_exited.connect(_on_button_normal.bind(btn))
			_yazi_rengini_degistir(btn, Color.BLACK)
	if kapat_butonu and not kapat_butonu.pressed.is_connected(_on_kapat_buton_pressed):
		kapat_butonu.pressed.connect(_on_kapat_buton_pressed)

func _oyunu_baslat():
	if oyun_timer:
		oyun_timer.wait_time = 1.0
		oyun_timer.start()
	yeni_kelime_getir()

# --- 3. KELİME MANTIĞI ---
func yeni_kelime_getir():
	var secilen = Global.rastgele_kelime_getir()
	su_anki_kelime = secilen
	if secilen == "":
		if kelime_etiketi: kelime_etiketi.text = "?"
		return
	_etiket_gorunumunu_ayarla(secilen)

func _etiket_gorunumunu_ayarla(kelime: String):
	var punto = 160
	var metin = kelime.strip_edges()
	if metin.contains(" "):
		metin = metin.replace(" ", "\n")
	else:
		if metin.length() > 13: punto = 100
		elif metin.length() > 11: punto = 120
		elif metin.length() > 8: punto = 140
	if kelime_etiketi:
		kelime_etiketi.add_theme_font_size_override("font_size", punto)
		kelime_etiketi.text = metin

# --- 4. YARDIMCI FONKSİYONLAR ---
func dili_uygula():
	var s = Global.soz()
	if buton_dogru: _buton_metni_set(buton_dogru, s["DOGRU"])
	if buton_pas: _buton_metni_set(buton_pas, s["PAS"])
	# "Anlamı" butonu sözlük ikonlu; üzerine yazı yazmıyoruz (ikon görünsün)
	if kelime_anla_butonu: kelime_anla_butonu.text = ""
	if kapat_butonu: kapat_butonu.text = s["GERI"]

func _buton_metni_set(btn: Button, metin: String):
	if btn == null: return
	var bulundu = false
	for child in btn.get_children():
		if child is Label:
			child.text = metin
			bulundu = true
	if not bulundu:
		btn.text = metin

func _yazi_rengini_degistir(btn: Button, renk: Color):
	if btn == null: return
	for child in btn.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", renk)

# --- 5. SÜRE, SES VE TİTREŞİM ---
func _on_timer_timeout():
	if kalan_sure > 0:
		kalan_sure -= 1
		if sure_etiketi: sure_etiketi.text = str(kalan_sure)
		_son_saniye_uyarisi()
	if kalan_sure <= 0:
		if oyun_timer: oyun_timer.stop()
		Global.ses_cal("bitti")
		Global.titret(600)
		set_process_input(false)
		await get_tree().create_timer(0.8).timeout
		get_tree().change_scene_to_file("res://tur_sonucu.tscn")

func _son_saniye_uyarisi():
	if kalan_sure <= 0 or kalan_sure > UYARI_SANIYESI: return
	if sure_etiketi:
		sure_etiketi.add_theme_color_override("font_color", Color(0.85, 0.05, 0.05))
		sure_etiketi.pivot_offset = sure_etiketi.size / 2
		sure_etiketi.scale = Vector2(1.25, 1.25)
		create_tween().tween_property(sure_etiketi, "scale", Vector2.ONE, 0.3)
	Global.ses_cal("son" if kalan_sure <= 3 else "tik")
	if kalan_sure <= TITRESIM_SANIYESI:
		Global.titret(80)

# --- 6. SİNYALLER ---
func _on_dogru_pressed():
	if kalan_sure <= 0: return
	Global.son_dogru += 1
	yeni_kelime_getir()

func _on_pas_pressed():
	if kalan_sure <= 0: return
	Global.son_pas += 1
	yeni_kelime_getir()

func _on_kelime_anlami_pressed():
	if su_anki_kelime == "": return
	var anlam = ""
	if Global.kelime_havuzu.has(su_anki_kelime):
		anlam = str(Global.kelime_havuzu[su_anki_kelime]).strip_edges()
	if anlam == "":
		anlam = Global.tum_sozluklerde_ara(su_anki_kelime)
	if anlam == "":
		anlam = Global.soz()["ANLAM YOK"]
	sozluk_kelime_etiketi.text = su_anki_kelime.strip_edges() + ":\n\n" + anlam.replace(" / ", "\n").replace("/", "\n")
	sozluk_popup.visible = true
	if oyun_timer: oyun_timer.stop()

func _on_kapat_buton_pressed():
	if sozluk_popup: sozluk_popup.visible = false
	if oyun_timer and kalan_sure > 0:
		oyun_timer.start()

# Android geri tuşu: sözlük penceresi açıksa önce onu kapat, değilse "<" gibi davran
func geri_tusu():
	if sozluk_popup and sozluk_popup.visible:
		_on_kapat_buton_pressed()
	else:
		_on_geri_pressed()

func _on_geri_pressed():
	Global.mac_devam_ediyor = false
	get_tree().change_scene_to_file("res://ana_menu.tscn")

# --- 7. ANİMASYONLAR ---
func _on_button_hover(btn: Button):
	if btn:
		create_tween().tween_property(btn, "scale", Vector2(1.05, 1.05), 0.1)
		_yazi_rengini_degistir(btn, Color.WHITE)

func _on_button_normal(btn: Button):
	if btn:
		create_tween().tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
		_yazi_rengini_degistir(btn, Color.BLACK)
