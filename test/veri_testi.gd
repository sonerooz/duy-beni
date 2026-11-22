extends SceneTree

# Veri ve mantık testi (oyun açılmadan çalışır):
#   Godot_v4.6.3-stable_win64_console.exe --headless --path E:/duy-beni -s res://test/veri_testi.gd
# Hata varsa çıkış kodu 1 olur.

var hatalar := 0
var g

func _initialize():
	g = load("res://Global.gd").new()
	_paket_verisi_testi()
	_dil_testi()
	_mantik_testi()
	_kelime_destesi_testi()
	g.free()
	print("TEST: ", ("BAŞARISIZ (%d hata)" % hatalar) if hatalar > 0 else "GEÇTİ")
	quit(1 if hatalar > 0 else 0)

func _kontrol(kosul: bool, mesaj: String):
	if not kosul:
		hatalar += 1
		printerr("HATA: ", mesaj)

func _json(yol: String):
	var d = JSON.parse_string(FileAccess.get_file_as_string(yol))
	_kontrol(d is Dictionary, yol + " okunamadı")
	return d if d is Dictionary else {}

# Her paket: zorluk listelerindeki her kelimenin sözlükte dolu bir anlamı olmalı, tekrar olmamalı.
func _paket_verisi_testi():
	for p in g.PAKETLER:
		var sozluk = _json(p["dosya"])
		var zorluk = _json(p["zorluk"])
		var hepsi = []
		for sev in g.SEVIYELER:
			var liste = zorluk.get(sev, [])
			_kontrol(liste is Array and not liste.is_empty(), "%s: '%s' listesi boş" % [p["ad"], sev])
			for k in liste:
				hepsi.append(k)
				_kontrol(sozluk.has(k), "%s: '%s' sözlükte yok" % [p["ad"], k])
				if sozluk.has(k):
					_kontrol(str(sozluk[k]).strip_edges() != "", "%s: '%s' anlamı boş" % [p["ad"], k])
		var tekil = {}
		for k in hepsi: tekil[k] = true
		_kontrol(tekil.size() == hepsi.size(), "%s: zorluk listelerinde tekrar eden kelime var" % p["ad"])

# TR, EN, FR metin anahtarları aynı olmalı ve boş değer olmamalı.
func _dil_testi():
	var tr_anahtarlar = g.yerellestirme["TR"].keys()
	for dil in ["EN", "FR"]:
		var d = g.yerellestirme[dil]
		for k in tr_anahtarlar:
			_kontrol(d.has(k), "%s dilinde '%s' eksik" % [dil, k])
		for k in d.keys():
			_kontrol(g.yerellestirme["TR"].has(k), "%s dilinde fazladan '%s'" % [dil, k])
			_kontrol(str(d[k]).strip_edges() != "", "%s dilinde '%s' boş" % [dil, k])
	# Çeviri düzeltmeleri bozulmasın.
	_kontrol(g.yerellestirme["EN"]["DOGRU"] == "CORRECT", "EN DOGRU 'CORRECT' olmalı")
	_kontrol(g.yerellestirme["FR"]["DOGRU"] == "JUSTE", "FR DOGRU 'JUSTE' olmalı")

func _mantik_testi():
	# Kazanan: en çok doğru; eşitlikte az pas; tam eşitlikte berabere.
	g.tur_sonuclari = {1: {"dogru": 5, "pas": 2}, 2: {"dogru": 7, "pas": 9}}
	_kontrol(g.kazananlar() == [2], "en çok doğru kazanmalı")
	g.tur_sonuclari = {1: {"dogru": 5, "pas": 2}, 2: {"dogru": 5, "pas": 1}}
	_kontrol(g.kazananlar() == [2], "eşitlikte az pas kazanmalı")
	g.tur_sonuclari = {1: {"dogru": 5, "pas": 2}, 2: {"dogru": 5, "pas": 2}}
	_kontrol(g.kazananlar().size() == 2, "tam eşitlik berabere olmalı")
	# Türkçe büyük/küçük harf: İ/I
	_kontrol(g.kucuk_harf("ISIRGAN") == "ısırgan", "I → ı")
	_kontrol(g.kucuk_harf("İZMİR") == "izmir", "İ → i")

# Aynı oturumda kelime tekrar etmemeli.
func _kelime_destesi_testi():
	g.secili_paket = 1  # English
	g._paketi_yukle()
	g.secili_zorluk = "ORTA"
	var gorulen = {}
	for i in range(300):
		var k = g.rastgele_kelime_getir()
		_kontrol(k != "", "kelime çıkmadı (%d. çekiliş)" % i)
		_kontrol(not gorulen.has(k), "'%s' tekrar etti" % k)
		gorulen[k] = true
	# Eksik paket verisi: boş havuzda boş döner, çökmez.
	g.kelime_havuzu = {}
	g.zorluk_listesi = {}
	_kontrol(g.rastgele_kelime_getir() == "", "boş havuz boş dönmeli")
