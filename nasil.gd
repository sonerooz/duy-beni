extends Control

# --- DÜĞÜM YOLLARI ---
@onready var geri_butonu = $"texturerect/<-"
@onready var sol_yazi = $"texturerect/SOL YAZI" # Yeni eklediğin başlık etiketi
@onready var rıch_label = $RichTextLabel

func _ready() -> void:
	# 1. Başlığı ve metni dile göre güncelle
	arayuz_metinlerini_guncelle()
	
	# 2. Buton sinyal bağlantısı
	if geri_butonu:
		if not geri_butonu.pressed.is_connected(_on_geri_pressed):
			geri_butonu.pressed.connect(_on_geri_pressed)

func arayuz_metinlerini_guncelle():
	var dil = Global.secili_dil
	var sozluk = Global.yerellestirme[dil]
	
	# --- SOL YAZI (BAŞLIK) GÜNCELLEME ---
	# Ayarlar ekranındaki mantığın aynısı: Global'den "NASIL" veya manuel karşılığını çekiyoruz
	if sol_yazi:
		if dil == "TR":
			sol_yazi.text = "NASIL OYNANIR"
		elif dil == "EN":
			sol_yazi.text = "HOW TO PLAY"
		elif dil == "FR":
			sol_yazi.text = "COMMENT JOUER"

	# --- RICH TEXT (İÇERİK) GÜNCELLEME ---
	# Not: Renk ve Font ayarlarını Denetleyici'den (Inspector) yapabilmen için 
	# kodla renk ataması yapmıyoruz. Sadece metni değiştiriyoruz.
	if rıch_label:
		var icerik = ""
		match dil:
			"TR":
				icerik = "[center]Ekrandaki kelimeyi, kelimenin kendisini söylemeden takım arkadaşına anlat. Bilirse DOĞRU'ya, bilemezse PAS'a bas. Süre bitmeden en çok puanı topla![/center]"
			"EN":
				icerik = "[center]Describe the word on the screen to your teammate without saying the word itself. Tap CORRECT when they guess it, PASS to skip. Score as many points as you can before time runs out![/center]"
			"FR":
				icerik = "[center]Faites deviner le mot affiché à votre coéquipier sans prononcer le mot lui-même. Appuyez sur JUSTE quand il trouve, sur PASSER pour passer. Marquez un maximum de points avant la fin du temps ![/center]"
		
		rıch_label.bbcode_enabled = true
		rıch_label.text = icerik

# Sahne geçiş fonksiyonları
func _on_geri_pressed() -> void:
	if get_tree():
		get_tree().call_deferred("change_scene_to_file", "res://ayarlar.tscn")

func _on__pressed() -> void:
	_on_geri_pressed()
