extends Node

# --- YEREKLEŞTİRME (DİL) AYARLARI ---
var yerellestirme = {
	"TR": {
		"BASLA": "OYUNA BAŞLA",
		"AYARLAR": "AYARLAR",
		"SÖZLÜK": "SÖZLÜK",
		"SN": "sn.",
		"GECMIS": "OYUN GEÇMİŞİ",
		"GERI": "GERİ",
		"KOLAY": "KOLAY",
		"ORTA": "ORTA",
		"ZOR": "ZOR"
	}
}

# --- OYUN AYARLARI (Ayarlar ekranının aradığı değişkenler) ---
var secili_dil = "TR"
var tur_suresi = 60
var secili_zorluk = "ORTA" # Hata veren eksik değişken buydu
var toplam_takim_sayisi = 4 
var su_anki_takim_sirasi = 1

# --- PUANLAMA VE VERİ VERİLERİ ---
var tur_sonuclari = {} 
var son_dogru = 0
var son_pas = 0
var sozluk_verisi = {}

const SAVE_PATH = "user://oyun_gecmisi.save"

# --- ANDROID GERİ TUŞU ---
# project.godot'ta quit_on_go_back=false olduğu için geri tuşu uygulamayı
# kapatmaz; bunun yerine açık ekranın "<" butonuyla aynı işi yapar.
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		geri_tusuna_basildi()

func geri_tusuna_basildi():
	var sahne = get_tree().current_scene
	if sahne == null: return
	if sahne.has_method("geri_tusu"):
		sahne.geri_tusu()               # ekranın kendi özel davranışı
	elif sahne.has_method("_on_geri_pressed"):
		sahne._on_geri_pressed()        # "<" butonu ile aynı iş

func _ready():
	sozluk_yukle()
	kelime_listelerini_yukle()
	veriyi_yukle()

# Puanları diske kaydeder
func puanlari_kaydet():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(tur_sonuclari)
		file.close()

# Diskteki en son sonucu yükler
func veriyi_yukle():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var yuklenen_veri = file.get_var()
			if yuklenen_veri is Dictionary:
				tur_sonuclari = yuklenen_veri
			file.close()

# --- Global.gd içindeki ilgili kısım ---

# Yeni bir maç serisi başladığında (Ana Menü'den basıldığında) çağrılır
func yeni_mac_serisi_baslat():
	tur_sonuclari = {} # Listeyi tamamen boşaltır
	su_anki_takim_sirasi = 1 # İlk takıma döner
	puanlari_kaydet() # Boş halini diske yazar (Eski maçı siler)

# Sözlük yükleme (Hata almamak için gerekli)
func sozluk_yukle():
	var dosya_yolu = "res://sozluk.json"
	if FileAccess.file_exists(dosya_yolu):
		var dosya = FileAccess.open(dosya_yolu, FileAccess.READ)
		var json = JSON.new()
		if json.parse(dosya.get_as_text()) == OK:
			sozluk_verisi = json.data

# --- ZORLUĞA GÖRE KELİME LİSTELERİ ---
# kelimeler.json: { "KOLAY": [...], "ORTA": [...], "ZOR": [...] }
var kelime_listeleri = {}

func kelime_listelerini_yukle():
	var dosya_yolu = "res://kelimeler.json"
	if FileAccess.file_exists(dosya_yolu):
		var dosya = FileAccess.open(dosya_yolu, FileAccess.READ)
		var json = JSON.new()
		if json.parse(dosya.get_as_text()) == OK and json.data is Dictionary:
			kelime_listeleri = json.data

# --- TEKRARSIZ KELİME DESTESİ ---
# Her zorluk seviyesinin karıştırılmış bir destesi var. Uygulama açık kaldığı
# sürece çıkan her kelime "kullanilan" listesine girer ve bir daha gelmez;
# zorluk değişse veya yeni maça geçilse bile. Seçili seviyenin kelimeleri
# biterse komşu seviyeden kelime verilir. Ancak bütün kelimeler tükenirse
# liste sıfırlanır (bu, yüzlerce kelimeden sonra olur).
var desteler = {}
var kullanilan = {}
const SEVIYELER = ["KOLAY", "ORTA", "ZOR"]

func desteyi_karistir(seviye: String):
	var liste: Array = kelime_listeleri.get(seviye, [])
	if liste.is_empty() and kelime_listeleri.is_empty():
		# Hiç liste yoksa tüm sözlüğe geri dön
		liste = sozluk_verisi.keys()
	var deste = []
	for k in liste:
		if not kullanilan.has(k): deste.append(k)
	deste.shuffle()
	desteler[seviye] = deste

func _desteden_cek(seviye: String) -> String:
	if not desteler.has(seviye): desteyi_karistir(seviye)
	var deste: Array = desteler[seviye]
	while not deste.is_empty():
		var k = deste.pop_back()
		if not kullanilan.has(k):
			return k
	return ""

func rastgele_kelime_getir() -> String:
	if kelime_listeleri.is_empty() and sozluk_verisi.is_empty(): return "Yüklenemedi"
	var seviye = secili_zorluk
	# Önce seçili seviye, sonra yakın seviyeler
	var sira = [seviye]
	var idx = SEVIYELER.find(seviye)
	for fark in [1, -1, 2, -2]:
		var j = idx + fark
		if idx >= 0 and j >= 0 and j < SEVIYELER.size(): sira.append(SEVIYELER[j])
	for sev in sira:
		var k = _desteden_cek(sev)
		if k != "":
			kullanilan[k] = true
			return k
	# Bütün kelimeler kullanıldı: baştan başla
	kullanilan.clear()
	desteler.clear()
	var k2 = _desteden_cek(seviye)
	kullanilan[k2] = true
	return k2
