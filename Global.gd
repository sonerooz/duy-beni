extends Node

# =====================================================================
#  DUY BENİ - Global (autoload)
#  Dil/paket seçimi, zorluk listeleri, tekrarsız kelime destesi,
#  skorlar, ayar kaydı, ses/titreşim ve Android geri tuşu burada.
# =====================================================================

# --- 1. SKORLAR ---
var son_dogru : int = 0
var son_pas : int = 0

# --- 2. YERELLEŞTİRME ---
var yerellestirme = {
	"TR": { "BASLA": "OYUNA BAŞLA", "AYARLAR": "AYARLAR", "SOZLUK": "SÖZLÜK", "DIL": "DİL", "SN": "sn.", "GECMIS": "OYUN GEÇMİŞİ", "GERI": "X", "KOLAY": "KOLAY", "ORTA": "ORTA", "ZOR": "ZOR", "ANLAMI": "ANLAMI", "PAS": "PAS", "DOGRU": "DOĞRU", "TAKIM": "TAKIM", "TUR SONUCU": "TUR SONUCU", "DEVAM ET": "DEVAM ET", "NASIL OYNANIR": "NASIL OYNANIR", "SONUCLAR": "SONUÇLAR",
		"HAZIR": "HAZIR MISINIZ?", "TUR_BASLA": "BAŞLA", "SIRADAKI": "SIRADAKİ TAKIM", "YENI OYUN": "YENİ OYUN", "ANA MENU": "ANA MENÜ", "KAZANAN": "KAZANAN", "BERABERE": "BERABERE", "SKOR": "SKOR", "ANLATACAK": "Anlatıcı telefonu alsın", "ANLAM YOK": "Bu kelimenin sözlükte anlamı bulunmuyor." },
	"EN": { "BASLA": "NEW GAME", "AYARLAR": "SETTINGS", "SOZLUK": "DICTIONARY", "DIL": "LANGUAGE", "SN": "sec.", "GECMIS": "GAME HISTORY", "GERI": "X", "KOLAY": "EASY", "ORTA": "NORMAL", "ZOR": "HARD", "ANLAMI": "SEARCH", "PAS": "PASS", "DOGRU": "TRUE", "TAKIM": "TEAM", "TUR SONUCU": "ROUND RESULT", "DEVAM ET": "CONTINUE", "NASIL OYNANIR": "HOW TO PLAY", "SONUCLAR": "RESULTS",
		"HAZIR": "ARE YOU READY?", "TUR_BASLA": "START", "SIRADAKI": "NEXT TEAM", "YENI OYUN": "NEW GAME", "ANA MENU": "MAIN MENU", "KAZANAN": "WINNER", "BERABERE": "DRAW", "SKOR": "SCORE", "ANLATACAK": "Explainer, take the phone", "ANLAM YOK": "No definition found for this word." },
	"FR": { "BASLA": "COMMENCER", "AYARLAR": "PARAMÈTRES", "SOZLUK": "DICTIONNAIRE", "DIL": "LANGUE", "SN": "sec.", "GECMIS": "HISTORIQUE DU JEU", "GERI": "X", "KOLAY": "FACILE", "ORTA": "MOYEN", "ZOR": "DIFFICILE", "ANLAMI": "DÉFINITION", "PAS": "PASSER", "DOGRU": "VRAI", "TAKIM": "ÉQUIPE", "TUR SONUCU": "RÉSULTAT DU TOUR", "DEVAM ET": "CONTINUER", "NASIL OYNANIR": "COMMENT JOUER", "SONUCLAR": "RÉSULTATS",
		"HAZIR": "ÊTES-VOUS PRÊTS ?", "TUR_BASLA": "COMMENCER", "SIRADAKI": "ÉQUIPE SUIVANTE", "YENI OYUN": "NOUVELLE PARTIE", "ANA MENU": "MENU PRINCIPAL", "KAZANAN": "GAGNANT", "BERABERE": "ÉGALITÉ", "SKOR": "SCORE", "ANLATACAK": "Le narrateur prend le téléphone", "ANLAM YOK": "Aucune définition trouvée." }
}

func soz() -> Dictionary:
	return yerellestirme.get(secili_dil, yerellestirme["TR"])

# --- 3. PAKETLER (dil + konu) ---
# dosya: kelime -> anlam sözlüğü | zorluk: { "KOLAY": [...], "ORTA": [...], "ZOR": [...] }
const PAKETLER = [
	{"ad": "Türkçe",   "dosya": "res://sozluk.json",  "zorluk": "res://kelimeler.json",       "dil": "TR"},
	{"ad": "English",  "dosya": "res://EN.json",      "zorluk": "res://zorluk/EN.json",      "dil": "EN"},
	{"ad": "Français", "dosya": "res://FR.json",      "zorluk": "res://zorluk/FR.json",      "dil": "FR"},
	{"ad": "Z Kuşağı", "dosya": "res://zkusagi.json", "zorluk": "res://zorluk/zkusagi.json", "dil": "TR"},
	{"ad": "Gamer",    "dosya": "res://gamer.json",   "zorluk": "res://zorluk/gamer.json",   "dil": "TR"},
	{"ad": "Finans",   "dosya": "res://kripto.json",  "zorluk": "res://zorluk/kripto.json",  "dil": "TR"},
	{"ad": "EskiTR",   "dosya": "res://eskiTR.json",  "zorluk": "res://zorluk/eskiTR.json",  "dil": "TR"},
	{"ad": "Plaza",    "dosya": "res://plaza.json",   "zorluk": "res://zorluk/plaza.json",   "dil": "TR"},
	{"ad": "GYM",      "dosya": "res://gym.json",     "zorluk": "res://zorluk/gym.json",     "dil": "TR"},
	{"ad": "Hukuk",    "dosya": "res://hukuk.json",   "zorluk": "res://zorluk/hukuk.json",   "dil": "TR"},
	{"ad": "Sağlık",   "dosya": "res://dr.json",      "zorluk": "res://zorluk/dr.json",      "dil": "TR"},
	{"ad": "Develop",  "dosya": "res://dev.json",     "zorluk": "res://zorluk/dev.json",     "dil": "TR"},
]
const SEVIYELER = ["KOLAY", "ORTA", "ZOR"]

# --- 4. AYARLAR (diske kaydedilir) ---
var secili_paket : int = 0
var secili_dil : String = "TR"
var secili_dil_adi : String = "Türkçe"
var tur_suresi : int = 60
var secili_zorluk : String = "ORTA"
var toplam_takim_sayisi : int = 2
var su_anki_takim_sirasi : int = 1

const AYAR_YOLU = "user://ayarlar.cfg"
const SAVE_PATH = "user://oyun_gecmisi.save"

# --- 5. VERİ ---
var kelime_havuzu = {}       # aktif paketin kelime -> anlam sözlüğü
var zorluk_listesi = {}      # aktif paketin zorluk listeleri
var tur_sonuclari = {}       # { takım_no (int): {"dogru": x, "pas": y} }
var mac_devam_ediyor := false
var yuklu_jsonlar = {}       # dosya önbelleği
var _arama_indeksi = {}      # dosya -> { küçük harfli kelime: asıl kelime }

func _ready():
	ayarlari_yukle()
	veriyi_yukle()
	_paketi_yukle()

# =====================================================================
#  DOSYA / PAKET YÖNETİMİ
# =====================================================================
func _dosya_getir(yol: String):
	if yuklu_jsonlar.has(yol):
		return yuklu_jsonlar[yol]
	if FileAccess.file_exists(yol):
		var icerik = JSON.parse_string(FileAccess.get_file_as_string(yol))
		if icerik is Dictionary:
			yuklu_jsonlar[yol] = icerik
			return icerik
	return null

func aktif_paket() -> Dictionary:
	return PAKETLER[clampi(secili_paket, 0, PAKETLER.size() - 1)]

func _paketi_yukle():
	var p = aktif_paket()
	secili_dil = p["dil"]
	secili_dil_adi = p["ad"]
	var veri = _dosya_getir(p["dosya"])
	kelime_havuzu = veri if veri != null else {}
	var z = _dosya_getir(p["zorluk"])
	zorluk_listesi = z if z != null else {}

func paket_sec(index: int):
	secili_paket = clampi(index, 0, PAKETLER.size() - 1)
	_paketi_yukle()
	ayarlari_kaydet()

# Eski kodlarla uyumluluk
func havuz_guncelle(_ozel_dosya_yolu: String = ""):
	_paketi_yukle()

# =====================================================================
#  ANLAM ARAMA (büyük/küçük harf ve Türkçe i/ı duyarsız)
# =====================================================================
func kucuk_harf(metin: String) -> String:
	return metin.strip_edges().replace("I", "ı").replace("İ", "i").to_lower()

func _indeks(yol: String) -> Dictionary:
	if _arama_indeksi.has(yol):
		return _arama_indeksi[yol]
	var d = _dosya_getir(yol)
	var ind = {}
	if d != null:
		for k in d.keys():
			ind[kucuk_harf(k)] = k
	_arama_indeksi[yol] = ind
	return ind

# Önce aktif pakette, sonra aynı dildeki diğer paketlerde arar.
# Dönüş: [bulunan_kelime, anlam]  (bulunamazsa ["", ""])
func anlam_ara(kelime: String) -> Array:
	var anahtar = kucuk_harf(kelime)
	if anahtar == "": return ["", ""]
	var yollar = [aktif_paket()["dosya"]]
	for p in PAKETLER:
		if p["dil"] == secili_dil and not (p["dosya"] in yollar):
			yollar.append(p["dosya"])
	for yol in yollar:
		var ind = _indeks(yol)
		if ind.has(anahtar):
			var asil = ind[anahtar]
			var sozluk: Dictionary = _dosya_getir(yol)
			return [asil, str(sozluk[asil]).strip_edges()]
	return ["", ""]

func tum_sozluklerde_ara(kelime: String) -> String:
	return anlam_ara(kelime)[1]

# =====================================================================
#  TEKRARSIZ KELİME DESTESİ
#  Uygulama açık kaldığı sürece çıkan kelime bir daha gelmez (zorluk veya
#  paket değişse de). Seçili seviye biterse yakın seviyeden verilir;
#  paketteki tüm kelimeler biterse o paket için baştan başlanır.
# =====================================================================
var desteler = {}
var kullanilan = {}

func _seviye_listesi(seviye: String) -> Array:
	var liste = zorluk_listesi.get(seviye, [])
	if liste is Array and not liste.is_empty():
		return liste
	if zorluk_listesi.is_empty():
		return kelime_havuzu.keys()   # zorluk dosyası yoksa tüm paket
	return []

func _deste_anahtari(seviye: String) -> String:
	return str(secili_paket) + ":" + seviye

func _desteden_cek(seviye: String) -> String:
	var anahtar = _deste_anahtari(seviye)
	if not desteler.has(anahtar):
		var deste = []
		for k in _seviye_listesi(seviye):
			if not kullanilan.has(k): deste.append(k)
		deste.shuffle()
		desteler[anahtar] = deste
	var d: Array = desteler[anahtar]
	while not d.is_empty():
		var k = d.pop_back()
		if not kullanilan.has(k):
			return k
	return ""

func rastgele_kelime_getir() -> String:
	if kelime_havuzu.is_empty() and zorluk_listesi.is_empty(): return ""
	var sira = [secili_zorluk]
	var idx = SEVIYELER.find(secili_zorluk)
	for fark in [1, -1, 2, -2]:
		var j = idx + fark
		if idx >= 0 and j >= 0 and j < SEVIYELER.size(): sira.append(SEVIYELER[j])
	for sev in sira:
		var k = _desteden_cek(sev)
		if k != "":
			kullanilan[k] = true
			return k
	# Bu paketin bütün kelimeleri kullanıldı: bu paket için baştan başla
	for sev in SEVIYELER:
		for k in _seviye_listesi(sev): kullanilan.erase(k)
		desteler.erase(_deste_anahtari(sev))
	var k2 = _desteden_cek(secili_zorluk)
	if k2 != "": kullanilan[k2] = true
	return k2

# =====================================================================
#  SKORLAR VE MAÇ
# =====================================================================
func turu_kaydet():
	tur_sonuclari[su_anki_takim_sirasi] = {"dogru": son_dogru, "pas": son_pas}
	puanlari_kaydet()

func siradaki_takim_var_mi() -> bool:
	return mac_devam_ediyor and su_anki_takim_sirasi < toplam_takim_sayisi

func mac_bitti_mi() -> bool:
	return tur_sonuclari.size() >= toplam_takim_sayisi or not mac_devam_ediyor

# Kazananlar: en çok doğru; eşitlikte daha az pas yapan önde.
# Dönüş: kazanan takım numaraları (birden fazlaysa berabere)
func kazananlar() -> Array:
	var en_iyi = []
	var en_iyi_d = -1
	var en_iyi_p = 0
	for t in tur_sonuclari.keys():
		var d = int(tur_sonuclari[t]["dogru"])
		var p = int(tur_sonuclari[t]["pas"])
		if d > en_iyi_d or (d == en_iyi_d and p < en_iyi_p):
			en_iyi = [t]; en_iyi_d = d; en_iyi_p = p
		elif d == en_iyi_d and p == en_iyi_p:
			en_iyi.append(t)
	return en_iyi

func puanlari_kaydet():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var({"surum": 2, "sonuclar": tur_sonuclari, "takim_sayisi": toplam_takim_sayisi})
		file.close()

func veriyi_yukle():
	if not FileAccess.file_exists(SAVE_PATH): return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null: return
	var v = file.get_var()
	file.close()
	# Eski sürümün metin biçimli kayıtlarını yok sayıyoruz
	if v is Dictionary and v.get("surum", 0) == 2 and v.get("sonuclar") is Dictionary:
		tur_sonuclari = v["sonuclar"]

func yeni_mac_serisi_baslat():
	tur_sonuclari = {}
	su_anki_takim_sirasi = 1
	son_dogru = 0
	son_pas = 0
	mac_devam_ediyor = true
	puanlari_kaydet()

# =====================================================================
#  AYAR KAYDI
# =====================================================================
func ayarlari_kaydet():
	var c = ConfigFile.new()
	c.set_value("oyun", "paket", secili_paket)
	c.set_value("oyun", "sure", tur_suresi)
	c.set_value("oyun", "zorluk", secili_zorluk)
	c.set_value("oyun", "takim", toplam_takim_sayisi)
	c.save(AYAR_YOLU)

func ayarlari_yukle():
	var c = ConfigFile.new()
	if c.load(AYAR_YOLU) != OK: return
	secili_paket = clampi(int(c.get_value("oyun", "paket", secili_paket)), 0, PAKETLER.size() - 1)
	var s = int(c.get_value("oyun", "sure", tur_suresi))
	if s in [30, 60, 90, 120]: tur_suresi = s
	var z = str(c.get_value("oyun", "zorluk", secili_zorluk))
	if z in SEVIYELER: secili_zorluk = z
	toplam_takim_sayisi = clampi(int(c.get_value("oyun", "takim", toplam_takim_sayisi)), 1, 4)

# =====================================================================
#  SES VE TİTREŞİM (ses dosyası gerekmez, kodla üretilir)
# =====================================================================
var _ses_oynatici : AudioStreamPlayer
var _sesler = {}

func _ses_uret(frekans: float, sure: float, ses_seviyesi: float = 0.6) -> AudioStreamWAV:
	var oran = 22050
	var n = int(oran * sure)
	var veri = PackedByteArray()
	veri.resize(n * 2)
	for i in range(n):
		var t = float(i) / oran
		var zarf = min(1.0, (n - i) / (oran * 0.02)) * min(1.0, i / (oran * 0.005))
		var ornek = sin(TAU * frekans * t) * ses_seviyesi * zarf
		veri.encode_s16(i * 2, int(clamp(ornek, -1.0, 1.0) * 32767))
	var w = AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = oran
	w.stereo = false
	w.data = veri
	return w

func ses_cal(ad: String):
	if _ses_oynatici == null:
		_ses_oynatici = AudioStreamPlayer.new()
		add_child(_ses_oynatici)
		_sesler["tik"] = _ses_uret(880.0, 0.08)
		_sesler["son"] = _ses_uret(1320.0, 0.12)
		_sesler["bitti"] = _ses_uret(440.0, 0.7, 0.8)
	if _sesler.has(ad):
		_ses_oynatici.stream = _sesler[ad]
		_ses_oynatici.play()

func titret(ms: int):
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(ms)

# =====================================================================
#  ANDROID GERİ TUŞU
#  project.godot'ta quit_on_go_back=false: geri tuşu uygulamayı kapatmaz,
#  açık ekranın "<" butonuyla aynı işi yapar.
# =====================================================================
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		geri_tusuna_basildi()

func geri_tusuna_basildi():
	var sahne = get_tree().current_scene
	if sahne == null: return
	if sahne.has_method("geri_tusu"):
		sahne.geri_tusu()
	elif sahne.has_method("_on_geri_pressed"):
		sahne._on_geri_pressed()
