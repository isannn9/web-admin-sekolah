import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:intl/intl.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAmAtZPBbnqOxECg-ZHZEvaG-mIjxmRcpY",
      authDomain: "pengduanapp.firebaseapp.com",
      projectId: "pengduanapp",
      storageBucket: "pengduanapp.firebasestorage.app",
      messagingSenderId: "326496900877",
      appId: "1:326496900877:web:553f4c755a7790405b0244",
      measurementId: "G-TXB47FDPZB",
    ),
  );
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel Admin - Pengaduan Siswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFF1F5F9),
              body: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
            );
          }
          if (snapshot.hasData) {
            return const AdminDashboard();
          }
          return const AdminLoginPage();
        },
      ),
    );
  }
}

// =========================================================================
// HALAMAN LOGIN ADMIN
// =========================================================================
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _loginAsliFirebase() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        String pesanError = 'Terjadi kesalahan sistem.';
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          pesanError = 'Email atau Password salah!';
        } else if (e.code == 'invalid-email') {
          pesanError = 'Format email tidak valid!';
        } else {
          pesanError = 'Error: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(pesanError), backgroundColor: Colors.redAccent),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
              ),
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded,
                          color: Color(0xFF2563EB), size: 44),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ADMIN PENGADUAN',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Silakan masuk menggunakan akun administrator',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Administrator',
                        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF2563EB), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: (value) => value!.isEmpty ? 'Email wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2563EB), size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF94A3B8),
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: (value) => value!.isEmpty ? 'Password wajib diisi' : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginAsliFirebase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'MASUK DASHBOARD',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// HALAMAN DASHBOARD UTAMA
// =========================================================================
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _selectedFilter = 'Semua';
  String _selectedReportFilter = 'Semua';

  void _updateStatus(String docId, String statusBaru, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('pengaduan').doc(docId).update({'status': statusBaru});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diubah ke: $statusBaru'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _kirimFeedbackDialog(String docId, String feedbackLama, String feedbackFotoLama, BuildContext context) {
    final TextEditingController feedbackController = TextEditingController(text: feedbackLama);
    String currentFeedbackFoto = feedbackFotoLama;
    bool isProcessingPhoto = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.rate_review_rounded, color: Color(0xFF2563EB), size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Tanggapan & Foto Admin',
                    style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Catatan / Solusi untuk Siswa:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: feedbackController,
                        maxLines: 4,
                        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Tuliskan tanggapan atau solusi penyelesaian...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF2563EB)),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Lampiran Foto Bukti Balasan (Opsional):', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: isProcessingPhoto
                            ? null
                            : () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 800,
                                  maxHeight: 800,
                                  imageQuality: 80,
                                );
                                if (image != null) {
                                  setStateDialog(() => isProcessingPhoto = true);
                                  try {
                                    Uint8List bytes = await image.readAsBytes();
                                    String base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                                    setStateDialog(() {
                                      currentFeedbackFoto = base64String;
                                      isProcessingPhoto = false;
                                    });
                                  } catch (e) {
                                    setStateDialog(() => isProcessingPhoto = false);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Gagal memproses foto: $e'), backgroundColor: Colors.redAccent),
                                    );
                                  }
                                }
                              },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              isProcessingPhoto
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 2))
                                  : const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF2563EB), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isProcessingPhoto
                                      ? 'Memproses gambar...'
                                      : currentFeedbackFoto.isEmpty
                                          ? 'Pilih Foto dari Galeri'
                                          : 'Foto Berhasil Dipilih (Ketuk untuk ganti)',
                                  style: TextStyle(
                                    color: currentFeedbackFoto.isEmpty ? const Color(0xFF64748B) : Colors.green[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: isProcessingPhoto
                      ? null
                      : () async {
                          try {
                            await FirebaseFirestore.instance.collection('pengaduan').doc(docId).update({
                              'feedback': feedbackController.text.trim(),
                              'feedback_foto': currentFeedbackFoto,
                            });
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tanggapan berhasil disimpan!'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.redAccent),
                            );
                          }
                        },
                  child: const Text('Kirim Tanggapan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String rawData, String title) {
    final bool isHttpUrl = rawData.startsWith('http://') || rawData.startsWith('https://');
    final bool isBase64 = rawData.length > 100 && !isHttpUrl;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 15)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 10),
              if (isHttpUrl)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    rawData,
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))),
                    errorBuilder: (context, error, stack) => const SizedBox(
                      height: 150,
                      child: Center(child: Text('Gagal memuat gambar dari URL.', style: TextStyle(color: Colors.redAccent))),
                    ),
                  ),
                )
              else if (isBase64)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Builder(
                    builder: (context) {
                      try {
                        String clean = rawData.contains(',') ? rawData.split(',').last : rawData;
                        Uint8List bytes = base64Decode(clean);
                        return Image.memory(bytes, height: 350, width: double.infinity, fit: BoxFit.cover);
                      } catch (e) {
                        return const SizedBox(
                          height: 150,
                          child: Center(child: Text('Format gambar Base64 tidak valid.', style: TextStyle(color: Colors.redAccent))),
                        );
                      }
                    },
                  ),
                )
              else
                const SizedBox(
                  height: 150,
                  child: Center(child: Text('Gambar tidak tersedia.', style: TextStyle(color: Colors.grey))),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return 'Baru saja';
    if (timestamp is Timestamp) {
      DateTime dt = timestamp.toDate().toLocal();
      return "${dt.day} ${DateFormat('MMMM yyyy').format(dt)} | ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }
    return 'Baru saja';
  }

  void _cetakLaporan(List<QueryDocumentSnapshot> listDocs, String judulLaporan) {
    if (listDocs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk dicetak!'), backgroundColor: Colors.orange),
      );
      return;
    }

    String htmlContent = '''
      <html>
        <head>
          <title>Cetak Laporan Pengaduan - $judulLaporan</title>
          <style>
            body { font-family: Arial, sans-serif; color: #1e293b; padding: 20px; }
            h2 { text-align: center; margin-bottom: 5px; color: #0f172a; }
            p.subtitle { text-align: center; color: #64748B; margin-top: 0; margin-bottom: 25px; font-size: 14px; }
            table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 12px; }
            th, td { border: 1px solid #cbd5e1; padding: 10px; text-align: left; vertical-align: top; }
            th { background-color: #2563eb; color: white; }
            tr:nth-child(even) { background-color: #f8fafc; }
            .badge { padding: 3px 8px; border-radius: 4px; font-weight: bold; font-size: 10px; }
            .selesai { background: #d1fae5; color: #065f46; }
            .diproses { background: #fef3c7; color: #92400e; }
            .terkirim { background: #ffedd5; color: #9a3412; }
          </style>
        </head>
        <body>
          <h2>LAPORAN PENGADUAN & ASPIRASI SISWA</h2>
          <p class="subtitle">Kategori / Filter: <b>$judulLaporan</b> | Dicetak pada: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}</p>
          <table>
            <thead>
              <tr>
                <th style="width: 5%;">No</th>
                <th style="width: 15%;">Tanggal</th>
                <th style="width: 18%;">Pelapor (Siswa)</th>
                <th style="width: 12%;">Kategori</th>
                <th style="width: 25%;">Judul & Isi Pengaduan</th>
                <th style="width: 15%;">Tanggapan Admin</th>
                <th style="width: 10%;">Status</th>
              </tr>
            </thead>
            <tbody>
    ''';

    for (int i = 0; i < listDocs.length; i++) {
      final d = listDocs[i].data() as Map<String, dynamic>;
      String tgl = 'Baru saja';
      if (d['timestamp'] is Timestamp) {
        DateTime dt = (d['timestamp'] as Timestamp).toDate().toLocal();
        tgl = DateFormat('dd/MM/yyyy HH:mm').format(dt);
      }
      String nama = d['nama'] ?? 'Siswa';
      String nis = d['nis'] ?? '-';
      String kat = d['kategori'] ?? 'Pengaduan';
      String judul = d['judul'] ?? '-';
      String isi = d['isi'] ?? '-';
      String status = d['status'] ?? 'Terkirim';
      String feedback = d['feedback'] ?? '-';

      String statusClass = status == 'Selesai' ? 'selesai' : (status == 'Diproses' ? 'diproses' : 'terkirim');

      htmlContent += '''
        <tr>
          <td>${i + 1}</td>
          <td>$tgl</td>
          <td><b>$nama</b><br><span style="color:#64748b; font-size:11px;">NIS: $nis</span></td>
          <td>$kat</td>
          <td><b>$judul</b><br><span style="color:#475569;">$isi</span></td>
          <td>$feedback</td>
          <td><span class="badge $statusClass">$status</span></td>
        </tr>
      ''';
    }

    htmlContent += '''
            </tbody>
          </table>
          <script>
            window.onload = function() { window.print(); }
          </script>
        </body>
      </html>
    ''';

    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.dashboard_rounded, color: Color(0xFF2563EB), size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'ADMIN PANEL - PENGADUAN SISWA',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[700],
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: () async => await FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pengaduan')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 3));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error memuat data: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)),
            );
          }

          final allDocs = snapshot.hasData ? snapshot.data!.docs : [];

          int totalLaporan = allDocs.length;
          int totalTerkirim = allDocs.where((d) => (d.data() as Map)['status'] == 'Terkirim' || (d.data() as Map)['status'] == null).length;
          int totalDiproses = allDocs.where((d) => (d.data() as Map)['status'] == 'Diproses').length;
          int totalSelesai = allDocs.where((d) => (d.data() as Map)['status'] == 'Selesai').length;

          DateTime now = DateTime.now();
          List<QueryDocumentSnapshot> reportFilteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['timestamp'] == null) return false;
            DateTime? dt = (data['timestamp'] as Timestamp?)?.toDate();
            if (dt == null) return false;

            if (_selectedReportFilter == 'Minggu Ini') {
              DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
              DateTime startOfWeekClean = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
              return dt.isAfter(startOfWeekClean.subtract(const Duration(seconds: 1)));
            } else if (_selectedReportFilter == 'Bulan Ini') {
              return dt.year == now.year && dt.month == now.month;
            }
            return true;
          }).toList();

          final List<QueryDocumentSnapshot> docs = reportFilteredDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            String status = data['status'] ?? 'Terkirim';
            if (_selectedFilter == 'Semua') return true;
            return status.toLowerCase() == _selectedFilter.toLowerCase();
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.blue.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan & Pengelolaan Laporan Pengaduan',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pantau aspirasi siswa secara real-time, lakukan tanggapan, ubah status pengerjaan, dan cetak laporan berkala.',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFE2E8F0), height: 1),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.date_range_rounded, color: Color(0xFF2563EB), size: 18),
                              const SizedBox(width: 8),
                              const Text('Periode Laporan:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 13)),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedReportFilter,
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 13),
                                    items: ['Semua', 'Minggu Ini', 'Bulan Ini']
                                        .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedReportFilter = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              elevation: 1,
                            ),
                            onPressed: () => _cetakLaporan(reportFilteredDocs, _selectedReportFilter),
                            icon: const Icon(Icons.print_rounded, size: 18),
                            label: Text('Cetak Laporan ($_selectedReportFilter)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxis = constraints.maxWidth > 800 ? 4 : 2;
                    return GridView.count(
                      crossAxisCount: crossAxis,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.3,
                      children: [
                        _buildMetricCard('Total Laporan', '$totalLaporan', Icons.folder_shared_rounded, Colors.blue, 'Semua'),
                        _buildMetricCard('Terkirim', '$totalTerkirim', Icons.hourglass_top_rounded, Colors.orange, 'Terkirim'),
                        _buildMetricCard('Diproses', '$totalDiproses', Icons.sync_rounded, Colors.amber[800]!, 'Diproses'),
                        _buildMetricCard('Selesai', '$totalSelesai', Icons.check_circle_rounded, Colors.teal, 'Selesai'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text('Status Filter:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 13)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Semua', Icons.dashboard_outlined),
                            const SizedBox(width: 8),
                            _buildFilterChip('Terkirim', Icons.send_rounded),
                            const SizedBox(width: 8),
                            _buildFilterChip('Diproses', Icons.autorenew_rounded),
                            const SizedBox(width: 8),
                            _buildFilterChip('Selesai', Icons.verified_rounded),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                docs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Column(
                            children: [
                              const Icon(Icons.inbox_rounded, size: 64, color: Color(0xFF94A3B8)),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada data pengaduan untuk filter status "$_selectedFilter" ($_selectedReportFilter).',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: docs.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final docId = docs[index].id;
                          final data = docs[index].data() as Map<String, dynamic>;
                          final dateStr = _formatDateTime(data['timestamp']);
                          String status = data['status'] ?? 'Terkirim';
                          String feedback = data['feedback'] ?? '';
                          String feedbackFoto = data['feedback_foto'] ?? '';

                          String fotoSiswa = data['image_url'] ??
                              data['foto_url'] ??
                              data['imageUrl'] ??
                              data['foto'] ??
                              '';
                          String kategori = data['kategori'] ?? 'Pengaduan';

                          Color statusColor = status == 'Selesai'
                              ? Colors.teal
                              : status == 'Diproses'
                                  ? Colors.amber[800]!
                                  : Colors.orange;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                              ],
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: kategori == 'Saran'
                                              ? Colors.blue.withValues(alpha: 0.1)
                                              : Colors.deepOrange.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          kategori.toUpperCase(),
                                          style: TextStyle(
                                            color: kategori == 'Saran' ? Colors.blue[700] : Colors.deepOrange[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Pelapor: ${data['nama'] ?? 'Siswa'} (NIS: ${data['nis'] ?? '-'})',
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Divider(color: Color(0xFFF1F5F9), height: 1),
                                  ),
                                  Text(
                                    data['judul'] ?? 'Tanpa Judul',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    data['isi'] ?? '',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                                  ),
                                  if (fotoSiswa.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    InkWell(
                                      onTap: () => _showImageDialog(context, fotoSiswa, 'Lampiran Foto Siswa'),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.image_rounded, color: Color(0xFF2563EB), size: 20),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text('Siswa melampirkan foto bukti. Ketuk untuk memperbesar.',
                                                  style: TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.w500)),
                                            ),
                                            Icon(Icons.open_in_new_rounded, color: Color(0xFF94A3B8), size: 16),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                  ),
                                  if (feedback.isNotEmpty || feedbackFoto.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Tanggapan / Solusi Admin:',
                                            style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                          if (feedback.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(feedback, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 12, height: 1.3)),
                                          ],
                                          if (feedbackFoto.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            InkWell(
                                              onTap: () => _showImageDialog(context, feedbackFoto, 'Foto Balasan Admin'),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.photo_camera_back_rounded, color: Colors.teal, size: 16),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    'Lihat Lampiran Foto Balasan Admin',
                                                    style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Divider(color: Color(0xFFF1F5F9), height: 1),
                                  ),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => _kirimFeedbackDialog(docId, feedback, feedbackFoto, context),
                                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                                        label: Text(
                                          (feedback.isEmpty && feedbackFoto.isEmpty) ? 'Beri Tanggapan & Foto' : 'Edit Tanggapan / Foto',
                                          style: const TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFF2563EB)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Ubah Status:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                          const SizedBox(width: 8),
                                          _buildStatusActionButton(docId, 'Terkirim', status == 'Terkirim', Colors.orange, context),
                                          const SizedBox(width: 4),
                                          _buildStatusActionButton(docId, 'Diproses', status == 'Diproses', Colors.amber[800]!, context),
                                          const SizedBox(width: 4),
                                          _buildStatusActionButton(docId, 'Selesai', status == 'Selesai', Colors.teal, context),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusActionButton(String docId, String targetStatus, bool isActive, Color color, BuildContext context) {
    return InkWell(
      onTap: isActive ? null : () => _updateStatus(docId, targetStatus, context),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? color : const Color(0xFFCBD5E1)),
        ),
        child: Text(
          targetStatus,
          style: TextStyle(
            color: isActive ? color : const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String count, IconData icon, Color color, String targetFilter) {
    bool isSelected = _selectedFilter == targetFilter;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = targetFilter),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? color : const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    bool isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : const Color(0xFF64748B)),
      selected: isSelected,
      selectedColor: const Color(0xFF2563EB),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF475569),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
        ),
      ),
      onSelected: (selected) => setState(() => _selectedFilter = label),
      visualDensity: VisualDensity.standard,
    );
  }
}
