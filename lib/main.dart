import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';      
import 'package:path_provider/path_provider.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 
import 'package:path/path.dart' as path; 


void main() {
  runApp(const SeyahatHaritasiApp());
}

class SeyahatHaritasiApp extends StatelessWidget {
  const SeyahatHaritasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seyahat Haritası Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.indigo, 
      ),
      home: const HaritaAnaSayfasi(),
    );
  }
}

// *******************************************************************
// HARİTA EKRANI KODLARI (Marker Sistemi)
// *******************************************************************

// Ülke Veri Modeli
class Ulke {
  final String adi;
  final LatLng koordinat;
  Ulke({required this.adi, required this.koordinat}); 
}

// Tıklanabilir işaretçiler (Marker) listesi - Sizin sisteminizde çalışan yapı kullanıldı.
// Bu liste, haritada tıklanabilir olan tüm noktaları temsil eder.
final List<Ulke> ulkeler = [ 
  // Sizin sisteminizde uyumlu çalışan yapı kullanıldı (Listenin kendisi const)
  Ulke(adi: 'Türkiye', koordinat: const LatLng(39.9334, 32.8597)),
  Ulke(adi: 'Almanya', koordinat: const LatLng(52.5200, 13.4050)),
  Ulke(adi: 'Japonya', koordinat: const LatLng(35.6895, 139.6917)),
  Ulke(adi: 'Brezilya', koordinat: const LatLng(-15.7797, -47.9297)),
  Ulke(adi: 'ABD', koordinat: LatLng(38.9072, -77.0369)),
  
  // GENİŞLETİLMİŞ VE ÇALIŞAN NOKTALAR
  Ulke(adi: 'Fransa', koordinat: const LatLng(48.8566, 2.3522)),
  Ulke(adi: 'İtalya', koordinat: const LatLng(41.9028, 12.4964)),
  Ulke(adi: 'Mısır', koordinat: const LatLng(30.0333, 31.2333)),
  Ulke(adi: 'Nijerya', koordinat: const LatLng(9.0765, 7.3983)),
  Ulke(adi: 'Hindistan', koordinat: const LatLng(28.6139, 77.2090)),
  Ulke(adi: 'Çin', koordinat: const LatLng(39.9042, 116.4074)),
  Ulke(adi: 'Rusya', koordinat: const LatLng(55.7558, 37.6173)),
  Ulke(adi: 'Avustralya', koordinat: const LatLng(-35.2809, 149.1300)),
  Ulke(adi: 'Arjantin', koordinat: const LatLng(-34.6037, -58.3816)),
  Ulke(adi: 'Kanada', koordinat: const LatLng(45.4215, -75.6972)),
];

class HaritaAnaSayfasi extends StatelessWidget {
  const HaritaAnaSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 Dünya Seyahat Haritası'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white), 
            tooltip: 'Uygulamadan Çıkış Yap',
            onPressed: () => exit(0), 
          ),
        ],
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: const LatLng(20.0, 0.0), // Başlangıç merkezi
          initialZoom: 2.0,                      // Başlangıç zoom seviyesi
          interactionOptions: InteractionOptions(flags: InteractiveFlag.all), 
        ),
        children: [
          // Harita Görseli (Dil sorunu çözülmüş ArcGIS sunucusu)
          TileLayer(
            urlTemplate: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}",
            userAgentPackageName: 'com.example.seyahat_haritasi_app_v2', 
          ),
          
          // Tıklanabilir Marker Katmanı
          MarkerLayer(
            markers: ulkeler.map((ulke) {
              return Marker(
                point: ulke.koordinat,
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    // Tıklanan ülkeyle ilgili seçenekleri göster
                    _markerDialogGoster(context, ulke.adi);
                  },
                  // İŞARETÇİ GÖRSELİ: Sadece küçük kırmızı bir nokta
                  child: const Icon(
                    Icons.circle, 
                    color: Colors.red, 
                    size: 8, // Haritayı boğmayacak şekilde küçültülmüş nokta
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Marker'a tıklandığında açılan Pop-up (Dialog) fonksiyonu
  void _markerDialogGoster(BuildContext context, String ulkeAdi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$ulkeAdi Seçenekleri'),
          content: const Text('Bu ülkenin anı galerisine gitmek ister misiniz?'),
          actions: <Widget>[
            TextButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Anı Galerisine Git'),
              onPressed: () {
                Navigator.pop(context); 
                _ulkeGalerisiniAc(context, ulkeAdi); 
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.cancel),
              label: const Text('Kapat'),
              onPressed: () {
                Navigator.pop(context); 
              },
            ),
          ],
        );
      },
    );
  }

  // Tıklanan ülkeye ait galeri ekranını açan fonksiyon
  void _ulkeGalerisiniAc(BuildContext context, String ulkeAdi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UlkeGaleriSayfasi(ulkeAdi: ulkeAdi),
      ),
    );
  }
}

// *******************************************************************
// RESİM GALERİ SAYFASI KODLARI (TAM EKRAN BÜYÜTME DAHİL)
// *******************************************************************
class UlkeGaleriSayfasi extends StatefulWidget {
  final String ulkeAdi;
  const UlkeGaleriSayfasi({super.key, required this.ulkeAdi});

  @override
  State<UlkeGaleriSayfasi> createState() => _UlkeGaleriSayfasiState();
}

class _UlkeGaleriSayfasiState extends State<UlkeGaleriSayfasi> {
  List<File> resimler = []; 
  final picker = ImagePicker(); 

  @override
  void initState() {
    super.initState();
    _resimleriYukle(); 
  }

  // Ülkeye özel klasör yolunu oluşturan fonksiyon
  Future<String> _klasorYolunuBul() async {
    final appDir = await getApplicationDocumentsDirectory(); 
    // Ülke adını temizleme 
    final temizUlkeAdi = widget.ulkeAdi.toLowerCase().replaceAll(' ', '_').replaceAll('ğ', 'g').replaceAll('ı', 'i').replaceAll('ş', 's').replaceAll('ü', 'u').replaceAll('ö', 'o').replaceAll('ç', 'c');
    
    final ulkeKlasorYolu = path.join(appDir.path, 'seyahat_resimleri', temizUlkeAdi);
    final Directory ulkeKlasoru = Directory(ulkeKlasorYolu);

    if (!await ulkeKlasoru.exists()) {
      await ulkeKlasoru.create(recursive: true);
      print('Klasör oluşturuldu: $ulkeKlasorYolu');
    }
    return ulkeKlasorYolu;
  }

  // Klasördeki tüm resimleri listeleyen fonksiyon
  Future<void> _resimleriYukle() async {
    final klasorYolu = await _klasorYolunuBul();
    final Directory ulkeKlasoru = Directory(klasorYolu);
    
    List<File> yuklenenResimler = [];
    final dosyalar = ulkeKlasoru.listSync(); 
    
    for (var dosya in dosyalar) {
      if (dosya is File && (dosya.path.endsWith('.jpg') || dosya.path.endsWith('.png') || dosya.path.endsWith('.jpeg'))) {
        yuklenenResimler.add(dosya);
      }
    }

    setState(() {
      resimler = yuklenenResimler.reversed.toList(); 
    });
  }

  // Galeriden resim seçip klasöre kaydeden fonksiyon
  Future<void> _resimEkle() async {
    final secilenResim = await picker.pickImage(source: ImageSource.gallery);

    if (secilenResim != null) {
      final klasorYolu = await _klasorYolunuBul();
      final File kaynakDosya = File(secilenResim.path);
      
      final yeniDosyaAdi = '${DateTime.now().millisecondsSinceEpoch}${path.extension(kaynakDosya.path)}';
      final hedefYol = path.join(klasorYolu, yeniDosyaAdi);
      
      await kaynakDosya.copy(hedefYol);
      _resimleriYukle(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.ulkeAdi} Anıları'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: _resimEkle, 
            tooltip: 'Galeriden Resim Ekle',
          ),
        ],
      ),
      body: resimler.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library, size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    'Henüz ${widget.ulkeAdi} için bir anınız yok.',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _resimEkle,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('İlk Anıyı Ekle'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: resimler.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TamEkranResimSayfasi(
                          resimDosyasi: resimler[index],
                          heroTag: resimler[index].path,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: resimler[index].path,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: FileImage(resimler[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// *******************************************************************
// TAM EKRAN RESİM GÖRÜNTÜLEYİCİ
// *******************************************************************
class TamEkranResimSayfasi extends StatelessWidget {
  final File resimDosyasi;
  final String heroTag;

  const TamEkranResimSayfasi({
    super.key,
    required this.resimDosyasi,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        backgroundColor: Colors.black, 
        iconTheme: const IconThemeData(color: Colors.white), 
        title: const Text('Resim Önizleme', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: Image.file(
            resimDosyasi,
            fit: BoxFit.contain, 
          ),
        ),
      ),
    );
  }
}