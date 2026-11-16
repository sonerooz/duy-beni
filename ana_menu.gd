extends Control

@onready var basla_btn = $"VBoxContainer/OYUNA BAŞLA"
@onready var ayarlar_btn = $VBoxContainer/AYARLAR
@onready var sozluk_btn = $"VBoxContainer/SÖZLÜK"

func _ready():
	dili_uygula()
	
	# --- SCALE EFEKTİ AYARLARI ---
	var butonlar = [basla_btn, ayarlar_btn, sozluk_btn]
	
	# Butonların boyutlarının hesaplanması için bir kare bekliyoruz
	await get_tree().process_frame
	
	for buton in butonlar:
		if buton:
			# Büyümenin merkezden olması için pivot noktasını ayarlıyoruz
			buton.pivot_offset = buton.size / 2
			
			# Fare üzerine gelince çalışacak sinyal
			buton.mouse_entered.connect(_on_button_hover.bind(buton))
			# Fare üzerinden çekilince çalışacak sinyal
			buton.mouse_exited.connect(_on_button_normal.bind(buton))

func dili_uygula():
	var sozluk = Global.yerellestirme["TR"]
	if basla_btn: basla_btn.text = sozluk["BASLA"]
	if ayarlar_btn: ayarlar_btn.text = sozluk["AYARLAR"]
	if sozluk_btn: sozluk_btn.text = sozluk["SÖZLÜK"]

# --- ANİMASYON FONKSİYONLARI ---

func _on_button_hover(btn: Button):
	# 0.1 saniyede yumuşakça 1.02 boyutuna çıkar
	create_tween().tween_property(btn, "scale", Vector2(1.02, 1.02), 0.1).set_trans(Tween.TRANS_SINE)

func _on_button_normal(btn: Button):
	# 0.1 saniyede orijinal boyutuna (1.0) döner
	create_tween().tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)

# --- BUTON TIKLAMA FONKSİYONLARI ---
# --- ana_menu.gd içindeki başlatma fonksiyonu ---

func _on_oyuna_basla_pressed():
	# 1. Eski listeyi sil ve her şeyi sıfırla
	Global.yeni_mac_serisi_baslat()
	
	# 2. Oyuna gönder
	get_tree().change_scene_to_file("res://oyun_ekrani.tscn")
	
# Android geri tuşu: ana menüde uygulamadan çıkar
func geri_tusu():
	get_tree().quit()

func _on_ayarlar_pressed():
	get_tree().change_scene_to_file("res://ayarlar.tscn")

func _on_sozluk_pressed():
	get_tree().change_scene_to_file("res://sozluk.tscn")
