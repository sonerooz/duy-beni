extends Control

# --- GÖRSEL AYARLAR (dil listesi açılır menüsü) ---
var DIL_KUTUSU_RENK = Color("faedb400")
var DIL_KUTUSU_SEFFAFLIK = 1
var LISTE_ARKA_PLAN_RENGI = Color("f9c322ef")
var LISTE_SECIM_RENGI = Color("e3ac46dc")
var LISTE_YAZI_HIZALAMA = 1
var LISTE_GENISLIK = 500
var LISTE_YUKSEKLIK = 600
var LISTE_YAZI_BOYUTU = 80
var LISTE_YAZI_RENGI = Color.BLACK
var LISTE_HOVER_RENGI = Color.WHITE

@onready var sure_yazisi = $"VBoxContainer/SURE/SAG YAZI"
@onready var zorluk_yazisi = $"VBoxContainer/ZORLUK/SAG YAZI"
@onready var takim_yazisi = $"VBoxContainer/TAKIM/SAG YAZI"
@onready var gecmis_yazisi = $"VBoxContainer/GECMIS/SOL YAZI"
@onready var dil_sag_yazi = $"VBoxContainer/DIL/SAG YAZI"
@onready var dil_secici : OptionButton = get_node_or_null("VBoxContainer/DIL/dilsecici")

@onready var dil_etiket = $"VBoxContainer/DIL/SOL YAZI"
@onready var sure_etiket = $"VBoxContainer/SURE/SOL YAZI"
@onready var zorluk_etiket = $"VBoxContainer/ZORLUK/SOL YAZI"
@onready var takim_etiket = $"VBoxContainer/TAKIM/SOL YAZI"
@onready var nasil_etiket = get_node_or_null("VBoxContainer/NASIL/SOL YAZI")

@onready var butonlar = [
	$"VBoxContainer/DIL",
	$"VBoxContainer/SURE",
	$"VBoxContainer/ZORLUK",
	$"VBoxContainer/TAKIM",
	$"VBoxContainer/GECMIS",
	$"VBoxContainer/NASIL"
]

func _ready():
	_dil_menusunu_hazirla()
	guncelle_arayuz()
	await get_tree().process_frame
	for buton in butonlar:
		if buton:
			buton.pivot_offset = buton.size / 2
			_yazi_rengini_degistir(buton, Color.BLACK)
			if not buton.mouse_entered.is_connected(_on_button_hover):
				buton.mouse_entered.connect(_on_button_hover.bind(buton))
			if not buton.mouse_exited.is_connected(_on_button_normal):
				buton.mouse_exited.connect(_on_button_normal.bind(buton))

# --- DİL / PAKET MENÜSÜ ---
func _dil_menusunu_hazirla():
	if not dil_secici: return
	dil_secici.clear()
	dil_secici.flat = true
	for renk_adi in ["font_color", "font_focus_color", "font_hover_color", "font_pressed_color"]:
		dil_secici.add_theme_color_override(renk_adi, Color(0, 0, 0, 0))
	dil_secici.modulate = DIL_KUTUSU_RENK
	dil_secici.modulate.a = DIL_KUTUSU_SEFFAFLIK
	for p in Global.PAKETLER:
		dil_secici.add_item(p["ad"])
	dil_secici.select(Global.secili_paket)

	var popup = dil_secici.get_popup()
	popup.add_theme_font_size_override("font_size", LISTE_YAZI_BOYUTU)
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = LISTE_ARKA_PLAN_RENGI
	style_box.set_corner_radius_all(10)
	if LISTE_YAZI_HIZALAMA == 1: style_box.content_margin_left = 60
	elif LISTE_YAZI_HIZALAMA == 2: style_box.content_margin_left = 180
	else: style_box.content_margin_left = 20
	popup.add_theme_stylebox_override("panel", style_box)
	var hover_box = StyleBoxFlat.new()
	hover_box.bg_color = LISTE_SECIM_RENGI
	hover_box.set_corner_radius_all(5)
	hover_box.content_margin_left = style_box.content_margin_left
	popup.add_theme_stylebox_override("hover", hover_box)
	popup.add_theme_color_override("font_color", LISTE_YAZI_RENGI)
	popup.add_theme_color_override("font_hover_color", LISTE_HOVER_RENGI)
	popup.add_theme_icon_override("checked", ImageTexture.new())
	popup.add_theme_icon_override("unchecked", ImageTexture.new())
	popup.min_size.x = LISTE_GENISLIK
	popup.max_size.y = LISTE_YUKSEKLIK
	if not dil_secici.item_selected.is_connected(_on_dil_secildi):
		dil_secici.item_selected.connect(_on_dil_secildi)

func _on_dil_secildi(index: int):
	Global.paket_sec(index)   # dili de günceller ve kaydeder
	guncelle_arayuz()

# Satırın tamamına basılınca da liste açılsın
func _on_dil_pressed():
	if dil_secici: dil_secici.show_popup()

func _on_dilsecici_pressed():
	pass

func guncelle_arayuz():
	var s = Global.soz()
	var dil = Global.secili_dil
	if dil_etiket: dil_etiket.text = s["DIL"]
	if sure_etiket: sure_etiket.text = "DURATION" if dil == "EN" else ("DURÉE" if dil == "FR" else "SÜRE")
	if zorluk_etiket: zorluk_etiket.text = "DIFFICULTY" if dil == "EN" else ("DIFFICULTÉ" if dil == "FR" else "ZORLUK")
	if takim_etiket: takim_etiket.text = s["TAKIM"]
	if sure_yazisi: sure_yazisi.text = str(Global.tur_suresi) + " " + s["SN"]
	if zorluk_yazisi: zorluk_yazisi.text = s[Global.secili_zorluk]
	if takim_yazisi: takim_yazisi.text = str(Global.toplam_takim_sayisi)
	if gecmis_yazisi: gecmis_yazisi.text = s["GECMIS"]
	if dil_sag_yazi: dil_sag_yazi.text = Global.secili_dil_adi
	if nasil_etiket: nasil_etiket.text = s["NASIL OYNANIR"]

# --- AKSİYONLAR (her değişiklik diske kaydedilir) ---
func _on_nasil_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_nasil_pressed()

func _on_nasil_pressed():
	get_tree().change_scene_to_file("res://nasil.tscn")

func _on_gecmis_pressed():
	Global.mac_devam_ediyor = false
	get_tree().change_scene_to_file("res://toplam_sonuc.tscn")

func _on_sure_pressed():
	var sureler = [30, 60, 90, 120]
	Global.tur_suresi = sureler[(sureler.find(Global.tur_suresi) + 1) % sureler.size()]
	Global.ayarlari_kaydet()
	guncelle_arayuz()

func _on_zorluk_pressed():
	var zorluklar = Global.SEVIYELER
	Global.secili_zorluk = zorluklar[(zorluklar.find(Global.secili_zorluk) + 1) % zorluklar.size()]
	Global.ayarlari_kaydet()
	guncelle_arayuz()

func _on_takim_pressed():
	Global.toplam_takim_sayisi = (Global.toplam_takim_sayisi % 4) + 1
	Global.ayarlari_kaydet()
	guncelle_arayuz()

func _on_geri_pressed():
	get_tree().change_scene_to_file("res://ana_menu.tscn")

# --- ANİMASYONLAR ---
func _on_button_hover(btn: Control):
	create_tween().tween_property(btn, "scale", Vector2(1.02, 1.02), 0.1)
	_yazi_rengini_degistir(btn, Color.WHITE)

func _on_button_normal(btn: Control):
	create_tween().tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
	_yazi_rengini_degistir(btn, Color.BLACK)

func _yazi_rengini_degistir(btn: Control, renk: Color):
	for child in btn.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", renk)
