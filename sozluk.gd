extends Control

@onready var arama_kutusu : LineEdit = $LineEdit
@onready var aciklama_label : RichTextLabel = $ACIKLAMA
@onready var anlami_btn = get_node_or_null("ANLAMI")
@onready var geri_btn = get_node_or_null("<-")
@onready var baslik_label = get_node_or_null("BASLIK")

func _ready():
	arama_kutusu.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	aciklama_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	aciklama_label.scroll_active = true
	if not arama_kutusu.text_changed.is_connected(_on_line_edit_text_changed):
		arama_kutusu.text_changed.connect(_on_line_edit_text_changed)
	dili_uygula()

func dili_uygula():
	var s = Global.soz()
	var dil = Global.secili_dil
	if baslik_label: baslik_label.text = s["SOZLUK"]
	if anlami_btn: _yazi_ayarla(anlami_btn, s["ANLAMI"])
	var ipucu = "Kelime yaz..."
	if dil == "EN": ipucu = "Write a word..."
	elif dil == "FR": ipucu = "Écris un mot..."
	arama_kutusu.placeholder_text = ipucu
	aciklama_label.text = ""

func _yazi_ayarla(btn: Button, metin: String):
	for child in btn.get_children():
		if child is Label:
			child.text = metin
			return
	btn.text = metin

func _mesaj(tr: String, en: String, fr: String) -> String:
	match Global.secili_dil:
		"EN": return en
		"FR": return fr
	return tr

# Yazarken (tam_sonuc=false) anlam anında görünür; butona/enter'a basınca
# bulunamazsa uyarı verilir. Büyük/küçük harf ve Türkçe i/ı fark etmez.
func _ara(tam_sonuc: bool):
	var kelime = arama_kutusu.text.strip_edges()
	if kelime == "":
		aciklama_label.text = _mesaj("Lütfen bir kelime yazın.", "Please type a word.", "Veuillez écrire un mot.") if tam_sonuc else ""
		return
	var sonuc = Global.anlam_ara(kelime)
	var scroll_bar = aciklama_label.get_v_scroll_bar()
	if scroll_bar: scroll_bar.value = 0
	if sonuc[0] != "":
		aciklama_label.text = sonuc[1].replace(" / ", "\n\n").replace("/", "\n\n")
	elif tam_sonuc:
		aciklama_label.text = _mesaj("Kelime hiçbir sözlükte bulunamadı.", "Word not found in any dictionary.", "Mot introuvable.")
	else:
		aciklama_label.text = ""

func _on_line_edit_text_changed(_yeni):
	_ara(false)

func _on_anlami_pressed():
	_ara(true)

func _on_line_edit_text_submitted(_new_text):
	_ara(true)

func _on_geri_pressed():
	get_tree().change_scene_to_file("res://ana_menu.tscn")
