extends Control

@onready var arama_kutusu = $LineEdit
@onready var aciklama_label = $ACIKLAMA

func _ready():
	arama_kutusu.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	# Yazarken anlam anında görünsün
	if not arama_kutusu.text_changed.is_connected(_on_line_edit_text_changed):
		arama_kutusu.text_changed.connect(_on_line_edit_text_changed)
	# Sözlük açılışta Global'de bir kez yüklendi; burada tekrar yüklemiyoruz
	if Global.sozluk_verisi.is_empty():
		aciklama_label.text = "Hata: sözlük yüklenemedi!"
	else:
		aciklama_label.text = "Aramak istediğiniz kelimeyi yazın."

# Türkçe büyük harf: i -> İ, ı -> I
func tr_buyuk(metin: String) -> String:
	return metin.replace("i", "İ").replace("ı", "I").to_upper()

func anlam_metni(kelime: String) -> String:
	return str(Global.sozluk_verisi[kelime]).strip_edges().replace(" / ", "\n\n").replace("/", "\n\n")

func _ara(tam_sonuc: bool):
	var kelime = tr_buyuk(arama_kutusu.text).strip_edges()
	if kelime == "":
		aciklama_label.text = "Lütfen kelime yazın."
		return
	if Global.sozluk_verisi.has(kelime):
		aciklama_label.text = anlam_metni(kelime)
	elif tam_sonuc:
		aciklama_label.text = "Kelime bulunamadı."
	else:
		aciklama_label.text = ""

func _on_line_edit_text_changed(_yeni_metin):
	_ara(false)

func _on_anlami_pressed():
	_ara(true)

func _on_line_edit_text_submitted(_new_text):
	_ara(true)

# Geri butonu fonksiyonu - Türkçe karakterler temizlendi
func _on_geri_pressed():
	get_tree().change_scene_to_file("res://ana_menu.tscn")
