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

# --- 5. SÜRE, SES, TİTREŞİM VE SON SANİYE ANİMASYONLARI ---
var _flas : ColorRect          # tüm ekranı kaplayan kırmızı flaş katmanı
var _kelime_konum : Vector2
var _bitti := false

func _on_timer_timeout():
	if _bitti: return
	if kalan_sure > 0:
		kalan_sure -= 1
		if sure_etiketi: sure_etiketi.text = str(kalan_sure)
		_son_saniye_uyarisi()
	if kalan_sure <= 0:
		_sure_bitti()

func _son_saniye_uyarisi():
	if kalan_sure <= 0 or kalan_sure > UYARI_SANIYESI: return
	var son5 = kalan_sure <= TITRESIM_SANIYESI
	# Sayaç: kırmızı ve nabız (son 5 saniyede daha sert)
	if sure_etiketi:
		sure_etiketi.add_theme_color_override("font_color", Color(0.85, 0.05, 0.05))
		sure_etiketi.pivot_offset = sure_etiketi.size / 2
		sure_etiketi.scale = Vector2(1.6, 1.6) if son5 else Vector2(1.25, 1.25)
		create_tween().tween_property(sure_etiketi, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if not son5:
		Global.ses_cal("tik")
		return
	# --- SON 5 SANİYE ---
	Global.kalp_atisi_cal(kalan_sure)
	Global.titret(80)
	_kirmizi_flas(0.18 + (5 - kalan_sure) * 0.05)
	_kelimeyi_salla(6.0 + (5 - kalan_sure) * 3.0)

func _flas_katmani() -> ColorRect:
	if _flas == null:
		_flas = ColorRect.new()
		_flas.color = Color(0.9, 0.0, 0.0, 0.0)
		_flas.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_flas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(_flas)
	return _flas

func _kirmizi_flas(guc: float):
	var f = _flas_katmani()
	f.color = Color(0.9, 0.0, 0.0, guc)
	create_tween().tween_property(f, "color:a", 0.0, 0.6).set_ease(Tween.EASE_OUT)

func _kelimeyi_salla(siddet: float):
	if kelime_etiketi == null: return
	if _kelime_konum == Vector2.ZERO: _kelime_konum = kelime_etiketi.position
	kelime_etiketi.pivot_offset = kelime_etiketi.size / 2
	var t = create_tween()
	for i in range(6):
		var yon = Vector2(randf_range(-1, 1), randf_range(-0.5, 0.5)) * siddet
		t.tween_property(kelime_etiketi, "position", _kelime_konum + yon, 0.035)
	t.tween_property(kelime_etiketi, "position", _kelime_konum, 0.05)
	kelime_etiketi.scale = Vector2(1.08, 1.08)
	create_tween().tween_property(kelime_etiketi, "scale", Vector2.ONE, 0.3)

func _sure_bitti():
	if _bitti: return
	_bitti = true
	if oyun_timer: oyun_timer.stop()
	Global.ses_cal("bitti")
	Global.titret(600)
	# Beyaz parlama -> kırmızıya dönüş
	var f = _flas_katmani()
	f.color = Color(1, 1, 1, 0.75)
	var t = create_tween()
	t.tween_property(f, "color", Color(0.85, 0.0, 0.0, 0.45), 0.25)
	t.tween_property(f, "color:a", 0.25, 0.6)
	# "SÜRE BİTTİ!" yazısı zıplayarak gelir
	var yazi = Label.new()
	yazi.text = Global.soz()["SURE BITTI"]
	yazi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	yazi.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	yazi.add_theme_font_size_override("font_size", 170)
	yazi.add_theme_color_override("font_color", Color.WHITE)
	yazi.add_theme_color_override("font_outline_color", Color(0.5, 0, 0))
	yazi.add_theme_constant_override("outline_size", 30)
	yazi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	yazi.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(yazi)
	yazi.pivot_offset = size / 2
	yazi.scale = Vector2(0.2, 0.2)
	create_tween().tween_property(yazi, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if kelime_etiketi: create_tween().tween_property(kelime_etiketi, "modulate:a", 0.15, 0.3)
	await get_tree().create_timer(1.6).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file("res://tur_sonucu.tscn")

# --- 6. SİNYALLER ---
func _on_dogru_pressed():
	if kalan_sure <= 0 or _bitti: return
	Global.son_dogru += 1
	yeni_kelime_getir()

func _on_pas_pressed():
	if kalan_sure <= 0 or _bitti: return
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
