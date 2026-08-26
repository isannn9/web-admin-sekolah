import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

const FirebaseOptions _firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyAmAtZPBbnqOxECg-ZHZEvaG-mIjxmRcpY",
  authDomain: "pengduanapp.firebaseapp.com",
  projectId: "pengduanapp",
  storageBucket: "pengduanapp.firebasestorage.app",
  messagingSenderId: "326496900877",
  appId: "1:326496900877:web:553f4c755a7790405b0244",
  measurementId: "G-TXB47FDPZB",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: _firebaseOptions);
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel Admin - Pengaduan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF0F172A),
          surface: Colors.white,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF0F172A),
              body: Center(child: CircularProgressIndicator(color: Colors.white)),
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
        if (e.code == 'user-not-found') {
          pesanError = 'Email admin tidak terdaftar!';
        } else if (e.code == 'wrong-password') {
          pesanError = 'Password salah!';
        } else if (e.code == 'invalid-email') {
          pesanError = 'Format email tidak valid!';
        } else if (e.code == 'invalid-credential') {
          pesanError = 'Email atau Password salah.';
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
      backgroundColor: const Color(0xFF0B0F19),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded, color: Color(0xFF38BDF8), size: 36),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ADMIN PORTAL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Silakan masuk untuk melanjutkan',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Administrator',
                        labelStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF38BDF8), size: 20),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      validator: (value) => value!.isEmpty ? 'Email wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF38BDF8), size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      validator: (value) => value!.isEmpty ? 'Password wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginAsliFirebase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Color(0xFF0F172A), strokeWidth: 2),
                              )
                            : const Text(
                                'MASUK',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
// HALAMAN KELOLA PETUGAS
// =========================================================================
class AdminPetugasPage extends StatefulWidget {
  const AdminPetugasPage({super.key});

  @override
  State<AdminPetugasPage> createState() => _AdminPetugasPageState();
}

class _AdminPetugasPageState extends State<AdminPetugasPage> {
  bool _isLoading = false;

  CollectionReference<Map<String, dynamic>> get _petugasCollection =>
      FirebaseFirestore.instance.collection('petugas');

  String _emailAuthFromUsername(String username) =>
      '${username.trim().toLowerCase()}@petugas.pengaduanapp.com';

  Future<FirebaseAuth> _getSecondaryAuth() async {
    const appName = 'petugasCreator';
    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app(appName);
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: appName,
        options: _firebaseOptions,
      );
    }
    return FirebaseAuth.instanceFor(app: secondaryApp);
  }

  Future<void> _tambahPetugas() async {
    final formKey = GlobalKey<FormState>();
    final idController = TextEditingController();
    final namaController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final tugasController = TextEditingController();
    bool obscure = true;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF38BDF8)),
                  SizedBox(width: 8),
                  Text('Tambah Petugas', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        _petugasField(idController, 'ID Petugas', Icons.badge_outlined),
                        const SizedBox(height: 10),
                        _petugasField(namaController, 'Nama Petugas', Icons.person_outline),
                        const SizedBox(height: 10),
                        _petugasField(
                          usernameController,
                          'Username',
                          Icons.account_circle_outlined,
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Username wajib diisi';
                            if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(value)) {
                              return 'Gunakan huruf, angka, titik, _ atau -';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscure,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _petugasDecoration('Password', Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscure ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => setDialogState(() => obscure = !obscure),
                            ),
                          ),
                          validator: (v) {
                            if ((v ?? '').length < 6) return 'Password minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        _petugasField(tugasController, 'Tugas', Icons.assignment_outlined, maxLines: 2),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => _isLoading = true);
                          try {
                            final id = idController.text.trim();
                            final username = usernameController.text.trim().toLowerCase();
                            final existing = await _petugasCollection.doc(id).get();
                            if (existing.exists) {
                              throw Exception('ID Petugas sudah digunakan.');
                            }

                            final usernameQuery = await _petugasCollection
                                .where('username', isEqualTo: username)
                                .limit(1)
                                .get();
                            if (usernameQuery.docs.isNotEmpty) {
                              throw Exception('Username sudah digunakan.');
                            }

                            final secondaryAuth = await _getSecondaryAuth();
                            final credential = await secondaryAuth.createUserWithEmailAndPassword(
                              email: _emailAuthFromUsername(username),
                              password: passwordController.text,
                            );

                            await _petugasCollection.doc(id).set({
                              'idPetugas': id,
                              'nama': namaController.text.trim(),
                              'username': username,
                              'tugas': tugasController.text.trim(),
                              'emailAuth': _emailAuthFromUsername(username),
                              'uid': credential.user?.uid,
                              'role': 'petugas',
                              'createdAt': FieldValue.serverTimestamp(),
                              'updatedAt': FieldValue.serverTimestamp(),
                            });

                            await secondaryAuth.signOut();
                            if (dialogContext.mounted) Navigator.pop(dialogContext);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Petugas berhasil ditambahkan.'),
                                  backgroundColor: Colors.teal,
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal membuat akun: ${e.message ?? e.code}'), backgroundColor: Colors.redAccent),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.redAccent),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    idController.dispose();
    namaController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    tugasController.dispose();
  }

  Future<void> _editPetugas(String docId, Map<String, dynamic> data) async {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: data['nama'] ?? '');
    final usernameController = TextEditingController(text: data['username'] ?? '');
    final tugasController = TextEditingController(text: data['tugas'] ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Petugas', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _petugasField(TextEditingController(text: data['idPetugas'] ?? docId), 'ID Petugas', Icons.badge_outlined, enabled: false),
                const SizedBox(height: 10),
                _petugasField(namaController, 'Nama Petugas', Icons.person_outline),
                const SizedBox(height: 10),
                _petugasField(
                  usernameController,
                  'Username',
                  Icons.account_circle_outlined,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Username wajib diisi';
                    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(value)) return 'Format username tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _petugasField(tugasController, 'Tugas', Icons.assignment_outlined, maxLines: 2),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                final username = usernameController.text.trim().toLowerCase();
                final oldUsername = (data['username'] ?? '').toString().toLowerCase();
                if (username != oldUsername) {
                  final q = await _petugasCollection.where('username', isEqualTo: username).limit(1).get();
                  if (q.docs.isNotEmpty && q.docs.first.id != docId) throw Exception('Username sudah digunakan.');
                }
                await _petugasCollection.doc(docId).update({
                  'nama': namaController.text.trim(),
                  'username': username,
                  'tugas': tugasController.text.trim(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data petugas berhasil diperbarui.'), backgroundColor: Colors.teal),
                  );
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.redAccent));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    namaController.dispose();
    usernameController.dispose();
    tugasController.dispose();
  }

  Future<void> _hapusPetugas(String docId, Map<String, dynamic> data) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Hapus Petugas?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Data ${data['nama'] ?? 'petugas'} akan dihapus dari daftar petugas. Akun Firebase Authentication tidak ikut dihapus dari aplikasi client.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;

    try {
      await _petugasCollection.doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data petugas berhasil dihapus dari Firestore.'), backgroundColor: Colors.teal),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.redAccent));
    }
  }

  InputDecoration _petugasDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFF38BDF8), size: 19),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
    );
  }

  Widget _petugasField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? Function(String?)? validator,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: _petugasDecoration(label, icon),
      validator: validator ?? (v) => (v?.trim().isEmpty ?? true) ? '$label wajib diisi' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.people_alt_rounded, color: Color(0xFF38BDF8), size: 20),
            SizedBox(width: 8),
            Text('KELOLA PETUGAS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _tambahPetugas,
              icon: const Icon(Icons.add, size: 17),
              label: const Text('Tambah Petugas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _petugasCollection.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 58, color: Colors.grey[700]),
                  const SizedBox(height: 10),
                  Text('Belum ada petugas.', style: TextStyle(color: Colors.grey[400])),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(onPressed: _tambahPetugas, icon: const Icon(Icons.add), label: const Text('Tambah Petugas')),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 900;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: ListView.separated(
                    padding: EdgeInsets.all(desktop ? 24 : 14),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 18,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: desktop ? 100 : 80,
                              child: _petugasInfo('ID', data['idPetugas'] ?? doc.id),
                            ),
                            SizedBox(
                              width: desktop ? 180 : 150,
                              child: _petugasInfo('Nama', data['nama'] ?? '-'),
                            ),
                            SizedBox(
                              width: desktop ? 150 : 130,
                              child: _petugasInfo('Username', data['username'] ?? '-'),
                            ),
                            SizedBox(
                              width: desktop ? 140 : 120,
                              child: _petugasInfo('Password', '••••••••'),
                            ),
                            SizedBox(
                              width: desktop ? 240 : 180,
                              child: _petugasInfo('Tugas', data['tugas'] ?? '-'),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Edit',
                                  onPressed: () => _editPetugas(doc.id, data),
                                  icon: const Icon(Icons.edit_rounded, color: Color(0xFF38BDF8), size: 19),
                                ),
                                IconButton(
                                  tooltip: 'Hapus',
                                  onPressed: () => _hapusPetugas(doc.id, data),
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 19),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _petugasInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 9)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
      ],
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
  String _selectedTimeFilter = 'Semua Waktu';
  String _searchQuery = '';
  
  // Variabel penanda untuk fitur notifikasi pengaduan baru
  int? _previousTotalCount;

  @override
  void initState() {
    super.initState();
    _requestBrowserNotificationPermission();
  }

  // Meminta izin browser untuk menampilkan Push Notification
  void _requestBrowserNotificationPermission() async {
    if (html.Notification.supported) {
      if (html.Notification.permission != 'granted') {
        await html.Notification.requestPermission();
      }
    }
  }

  // Fungsi penampil Notifikasi (SnackBar & Browser Notification)
  void _triggerNewComplaintNotification(String namaSiswa, String judulPengaduan) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📢 Pengaduan Baru dari $namaSiswa: "$judulPengaduan"'),
          backgroundColor: Colors.blue[800],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }

    if (html.Notification.supported && html.Notification.permission == 'granted') {
      html.Notification(
        'Pengaduan Sekolah Baru!',
        body: 'Dari: $namaSiswa\nIsi: $judulPengaduan',
      );
    }
  }

  void _updateStatus(String docId, String statusBaru, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('pengaduan')
          .doc(docId)
          .update({'status': statusBaru});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status diubah ke: $statusBaru'),
          backgroundColor: Colors.teal[700],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.redAccent),
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
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.rate_review_rounded, color: Color(0xFF38BDF8), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tanggapan & Foto Admin',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Catatan / Tanggapan Teks:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: feedbackController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Tuliskan tanggapan atau solusi...',
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Lampiran Foto Balasan Admin:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 4),
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
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              isProcessingPhoto
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 2),
                                    )
                                  : const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF38BDF8), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isProcessingPhoto
                                      ? 'Memproses gambar...'
                                      : currentFeedbackFoto.isEmpty
                                          ? 'Pilih Foto dari Galeri'
                                          : 'Foto Berhasil Dipilih (Ketuk ganti)',
                                  style: TextStyle(
                                    color: currentFeedbackFoto.isEmpty ? Colors.grey[400] : Colors.tealAccent,
                                    fontSize: 11,
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
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: isProcessingPhoto
                      ? null
                      : () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('pengaduan')
                                .doc(docId)
                                .update({
                              'feedback': feedbackController.text.trim(),
                              'feedback_foto': currentFeedbackFoto,
                            });

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tanggapan & foto berhasil dikirim!'),
                                backgroundColor: Colors.teal,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.redAccent),
                            );
                          }
                        },
                  child: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
        backgroundColor: const Color(0xFF1E293B),
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
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
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const SizedBox(
                      height: 150,
                      child: Center(
                        child: Text('Gagal memuat gambar dari URL.', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ),
                    ),
                  ),
                )
              else if (isBase64)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Builder(
                    builder: (context) {
                      try {
                        String cleanBase64 = rawData.contains(',') ? rawData.split(',').last : rawData;
                        Uint8List imageBytes = base64Decode(cleanBase64);
                        return Image.memory(
                          imageBytes,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(
                            height: 150,
                            child: Center(
                              child: Text('Format Base64 gambar tidak valid.', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                            ),
                          ),
                        );
                      } catch (e) {
                        return const SizedBox(
                          height: 150,
                          child: Center(
                            child: Text('Gagal mendecode data Base64 gambar.', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                          ),
                        );
                      }
                    },
                  ),
                )
              else
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Gambar tidak valid atau kosong.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                      ),
                    ),
                  ),
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
      return "${dt.day}-${dt.month}-${dt.year} | ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }
    return 'Baru saja';
  }

  void _showCetakDialog(List<QueryDocumentSnapshot> allDocs) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.print_rounded, color: Color(0xFF38BDF8), size: 20),
              SizedBox(width: 8),
              Text(
                'Cetak Rekap Laporan',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Pilih jenis periode laporan yang ingin dicetak:',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF0F172A),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _printHtmlReport('Semua Laporan Pengaduan Sekolah', allDocs);
                  },
                  icon: const Icon(Icons.all_inclusive, size: 16),
                  label: const Text('Cetak Semua Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    final filtered = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final ts = data['timestamp'];
                      if (ts is Timestamp) {
                        final dt = ts.toDate();
                        final now = DateTime.now();
                        return dt.year == now.year && dt.month == now.month && dt.day == now.day;
                      }
                      return false;
                    }).toList();
                    _printHtmlReport('Laporan Hari Ini', filtered);
                  },
                  icon: const Icon(Icons.today, size: 16),
                  label: const Text('Cetak Laporan Hari Ini', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: const Color(0xFF0F172A),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    final filtered = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final ts = data['timestamp'];
                      if (ts is Timestamp) {
                        final dt = ts.toDate();
                        final diff = DateTime.now().difference(dt).inDays;
                        return diff <= 7;
                      }
                      return false;
                    }).toList();
                    _printHtmlReport('Laporan Per Minggu (7 Hari Terakhir)', filtered);
                  },
                  icon: const Icon(Icons.date_range, size: 16),
                  label: const Text('Cetak Laporan Per Minggu', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: const Color(0xFF0F172A),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    final filtered = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final ts = data['timestamp'];
                      if (ts is Timestamp) {
                        final dt = ts.toDate();
                        final now = DateTime.now();
                        return dt.month == now.month && dt.year == now.year;
                      }
                      return false;
                    }).toList();
                    _printHtmlReport('Laporan Per Bulan (Bulan Ini)', filtered);
                  },
                  icon: const Icon(Icons.calendar_month, size: 16),
                  label: const Text('Cetak Laporan Per Bulan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void _printHtmlReport(String title, List<QueryDocumentSnapshot> docs) {
    String rows = '';
    for (int i = 0; i < docs.length; i++) {
      final data = docs[i].data() as Map<String, dynamic>;
      final dateStr = _formatDateTime(data['timestamp']);
      rows += '''
        <tr>
          <td>${i + 1}</td>
          <td>$dateStr</td>
          <td>${data['nama'] ?? '-'} (${data['nis'] ?? '-'})</td>
          <td>${data['kategori'] ?? 'Pengaduan'}</td>
          <td><b>${data['judul'] ?? '-'}</b><br>${data['isi'] ?? ''}</td>
          <td>${data['status'] ?? 'Terkirim'}</td>
        </tr>
      ''';
    }

    String htmlContent = '''
      <html>
        <head>
          <title>$title</title>
          <style>
            body { font-family: Arial, sans-serif; padding: 20px; color: #333; }
            h2 { margin-bottom: 5px; }
            p { color: #666; font-size: 12px; margin-top: 0; }
            table { width: 100%; border-collapse: collapse; margin-top: 20px; }
            th, td { border: 1px solid #ddd; padding: 8px 12px; font-size: 12px; text-align: left; }
            th { background-color: #0F172A; color: white; }
            tr:nth-child(even) { background-color: #f9f9f9; }
          </style>
        </head>
        <body>
          <h2>REKAPITULASI PENGADUAN SEKOLAH</h2>
          <p>$title | Dicetak pada: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}</p>
          <table>
            <thead>
              <tr>
                <th>No</th>
                <th>Tanggal</th>
                <th>Pelapor (NIS)</th>
                <th>Kategori</th>
                <th>Judul & Isi Pengaduan</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              $rows
            </tbody>
          </table>
          <script>
            window.print();
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
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF38BDF8), size: 18),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'DASHBOARD ADMIN ASPIRASI',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_rounded, color: Color(0xFF38BDF8), size: 20),
            tooltip: 'Kelola Petugas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminPetugasPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            tooltip: 'Keluar',
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pengaduan')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 2));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            );
          }

          final allDocs = snapshot.hasData ? snapshot.data!.docs : <QueryDocumentSnapshot>[];
          int currentTotalCount = allDocs.length;

          // LOGIKA PENDETEKSI PENGADUAN BARU MASUK
          if (_previousTotalCount != null && currentTotalCount > _previousTotalCount!) {
            final latestData = allDocs.first.data() as Map<String, dynamic>;
            final String namaSiswa = latestData['nama'] ?? 'Siswa';
            final String judulPengaduan = latestData['judul'] ?? 'Tanpa Judul';

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _triggerNewComplaintNotification(namaSiswa, judulPengaduan);
            });
          }
          _previousTotalCount = currentTotalCount;

          int totalLaporan = allDocs.length;
          int totalTerkirim = allDocs
              .where((d) => (d.data() as Map)['status'] == 'Terkirim' || (d.data() as Map)['status'] == null)
              .length;
          int totalDiproses = allDocs.where((d) => (d.data() as Map)['status'] == 'Diproses').length;
          int totalSelesai = allDocs.where((d) => (d.data() as Map)['status'] == 'Selesai').length;

          final docs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            String status = data['status'] ?? 'Terkirim';
            
            bool matchStatus = (_selectedFilter == 'Semua') || (status.toLowerCase() == _selectedFilter.toLowerCase());

            bool matchTime = true;
            final ts = data['timestamp'];
            if (_selectedTimeFilter != 'Semua Waktu' && ts is Timestamp) {
              final dt = ts.toDate();
              final now = DateTime.now();
              if (_selectedTimeFilter == 'Hari Ini') {
                matchTime = (dt.year == now.year && dt.month == now.month && dt.day == now.day);
              } else if (_selectedTimeFilter == 'Minggu Ini') {
                final diff = now.difference(dt).inDays;
                matchTime = (diff <= 7);
              } else if (_selectedTimeFilter == 'Bulan Ini') {
                matchTime = (dt.month == now.month && dt.year == now.year);
              }
            } else if (_selectedTimeFilter != 'Semua Waktu' && ts == null) {
              matchTime = false;
            }

            bool matchSearch = true;
            if (_searchQuery.isNotEmpty) {
              final nama = (data['nama'] ?? '').toString().toLowerCase();
              final nis = (data['nis'] ?? '').toString().toLowerCase();
              final query = _searchQuery.toLowerCase();
              matchSearch = nama.contains(query) || nis.contains(query);
            }

            return matchStatus && matchTime && matchSearch;
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final double screenWidth = constraints.maxWidth;
              final bool isDesktop = screenWidth >= 900;
              final bool isTablet = screenWidth >= 600 && screenWidth < 900;

              final int metricColumns = screenWidth < 600 ? 2 : 4;
              final double metricAspectRatio = screenWidth < 600 ? 2.6 : (isDesktop ? 2.3 : 2.0);

              final int reportColumns = isDesktop ? 3 : (isTablet ? 2 : 1);

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1300),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 14, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.count(
                          crossAxisCount: metricColumns,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: metricAspectRatio,
                          children: [
                            _buildMetricCard('Total Laporan', '$totalLaporan', Icons.folder_shared, Colors.blue, 'Semua', isDesktop),
                            _buildMetricCard('Menunggu', '$totalTerkirim', Icons.hourglass_top, Colors.orange, 'Terkirim', isDesktop),
                            _buildMetricCard('Diproses', '$totalDiproses', Icons.sync, Colors.purple, 'Diproses', isDesktop),
                            _buildMetricCard('Selesai', '$totalSelesai', Icons.check_circle, Colors.teal, 'Selesai', isDesktop),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Filter Detail Laporan Berdasarkan Waktu:',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: () => _showCetakDialog(allDocs),
                                icon: const Icon(Icons.print_rounded, size: 16),
                                label: const Text('Cetak Laporan (Semua)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildTimeFilterChip('Semua Waktu', Icons.all_inclusive),
                                  _buildTimeFilterChip('Hari Ini', Icons.today),
                                  _buildTimeFilterChip('Laporan Minggu Ini', Icons.date_range),
                                  _buildTimeFilterChip('Laporan Bulan Ini', Icons.calendar_month),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari berdasarkan NIS atau Nama Siswa...',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF38BDF8), size: 20),
                            filled: true,
                            fillColor: const Color(0xFF1E293B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 14),
                        docs.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 30),
                                  child: Column(
                                    children: [
                                      Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[700]),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tidak ada data laporan ditemukan.',
                                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : reportColumns == 1
                                ? ListView.builder(
                                    itemCount: docs.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final docId = docs[index].id;
                                      final data = docs[index].data() as Map<String, dynamic>;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _buildReportCard(context, docId, data, isDesktop),
                                      );
                                    },
                                  )
                                : GridView.builder(
                                    itemCount: docs.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: reportColumns,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: isDesktop ? 0.78 : 0.85,
                                    ),
                                    itemBuilder: (context, index) {
                                      final docId = docs[index].id;
                                      final data = docs[index].data() as Map<String, dynamic>;
                                      return _buildReportCard(context, docId, data, isDesktop);
                                    },
                                  ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTimeFilterChip(String label, IconData icon) {
    bool isSelected = _selectedTimeFilter == label;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, size: 12, color: isSelected ? const Color(0xFF0F172A) : Colors.grey[400]),
      selected: isSelected,
      selectedColor: const Color(0xFF38BDF8),
      backgroundColor: const Color(0xFF0F172A),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF0F172A) : Colors.grey[300],
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      onSelected: (selected) {
        setState(() => _selectedTimeFilter = label);
      },
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildReportCard(BuildContext context, String docId, Map<String, dynamic> data, bool isDesktop) {
    final dateStr = _formatDateTime(data['timestamp']);
    String status = data['status'] ?? 'Terkirim';
    String feedback = data['feedback'] ?? '';
    String feedbackFoto = data['feedback_foto'] ?? '';

    String fotoSiswa = data['image_url'] ?? data['foto_url'] ?? data['imageUrl'] ?? data['foto'] ?? '';
    String kategori = data['kategori'] ?? 'Pengaduan';

    Color statusColor = status == 'Selesai'
        ? Colors.teal
        : status == 'Diproses'
            ? Colors.purple
            : Colors.orange;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kategori == 'Saran' ? Colors.blue.withValues(alpha: 0.15) : Colors.deepOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    kategori.toUpperCase(),
                    style: TextStyle(
                      color: kategori == 'Saran' ? Colors.blue[300] : Colors.orange[300],
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Oleh: ${data['nama'] ?? 'Siswa'} (${data['nis'] ?? '-'})',
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Color(0xFF334155), height: 1),
            ),
            Text(
              data['judul'] ?? 'Tanpa Judul',
              style: TextStyle(
                fontSize: isDesktop ? 15 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data['isi'] ?? '',
              style: TextStyle(fontSize: 12, color: Colors.grey[300], height: 1.3),
            ),
            if (fotoSiswa.isNotEmpty) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _showImageDialog(context, fotoSiswa, 'Lampiran Foto Siswa'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.image, color: Color(0xFF38BDF8), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Siswa melampirkan foto. Ketuk untuk melihat.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ),
                      Icon(Icons.open_in_new, color: Colors.grey, size: 14),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
            const SizedBox(height: 6),
            _buildAssignmentBadge(data),
            if (feedback.isNotEmpty || feedbackFoto.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggapan Admin:',
                      style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                    if (feedback.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(feedback, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                    if (feedbackFoto.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _showImageDialog(context, feedbackFoto, 'Foto Balasan Admin'),
                        child: const Row(
                          children: [
                            Icon(Icons.photo_camera_back, color: Colors.tealAccent, size: 14),
                            SizedBox(width: 6),
                            Text('Lihat Foto Balasan / Koreksi Admin',
                                style: TextStyle(color: Colors.tealAccent, fontSize: 11, decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Color(0xFF334155), height: 1),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 34,
                  child: ElevatedButton.icon(
                    onPressed: () => _tugaskanPetugasDialog(docId, data),
                    icon: const Icon(Icons.assignment_ind_rounded, size: 14),
                    label: Text(
                      _isAssigned(data) ? 'Ubah / Batalkan Penugasan' : 'Tugaskan ke Petugas',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 32,
                  child: OutlinedButton.icon(
                    onPressed: () => _kirimFeedbackDialog(docId, feedback, feedbackFoto, context),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 13, color: Color(0xFF38BDF8)),
                    label: Text((feedback.isEmpty && feedbackFoto.isEmpty) ? 'Beri Tanggapan & Foto' : 'Edit Tanggapan / Foto',
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Status:', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      const SizedBox(width: 4),
                      _buildStatusActionButton(docId, 'Terkirim', status == 'Terkirim', Colors.orange, context),
                      const SizedBox(width: 3),
                      _buildStatusActionButton(docId, 'Diproses', status == 'Diproses', Colors.purple, context),
                      const SizedBox(width: 3),
                      _buildStatusActionButton(docId, 'Selesai', status == 'Selesai', Colors.teal, context),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _assignedPetugasId(Map<String, dynamic> data) {
    for (final key in const [
      'assignedPetugasId',
      'petugasId',
      'idPetugas',
      'assignedTo',
      'ditugaskanKe',
      'petugasDitugaskan',
      'penanggungJawab',
    ]) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is Map) {
        for (final subKey in const ['id', 'idPetugas', 'petugasId', 'uid', 'username']) {
          final subValue = value[subKey];
          if (subValue != null && subValue.toString().trim().isNotEmpty) {
            return subValue.toString().trim();
          }
        }
      }
    }
    return '';
  }

  bool _isAssigned(Map<String, dynamic> data) => _assignedPetugasId(data).isNotEmpty;

  Widget _buildAssignmentBadge(Map<String, dynamic> data) {
    final id = _assignedPetugasId(data);
    final nama = (data['petugasNama'] ?? data['namaPetugas'] ?? '').toString().trim();
    final assigned = id.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: assigned
            ? const Color(0xFF4F46E5).withValues(alpha: 0.12)
            : const Color(0xFF334155).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: assigned
              ? const Color(0xFF818CF8).withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Icon(
            assigned ? Icons.assignment_ind_rounded : Icons.assignment_late_outlined,
            size: 16,
            color: assigned ? const Color(0xFFA5B4FC) : Colors.grey[500],
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              assigned
                  ? 'Ditugaskan: ${nama.isEmpty ? id : '$nama • $id'}'
                  : 'Belum ditugaskan ke petugas',
              style: TextStyle(
                color: assigned ? const Color(0xFFC7D2FE) : Colors.grey[400],
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _tugaskanPetugasDialog(String docId, Map<String, dynamic> reportData) async {
    String selectedId = _assignedPetugasId(reportData);
    String selectedNama = (reportData['petugasNama'] ?? reportData['namaPetugas'] ?? '').toString();
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> saveAssignment() async {
              setDialogState(() => saving = true);
              try {
                final reportRef = FirebaseFirestore.instance.collection('pengaduan').doc(docId);
                if (selectedId.isEmpty) {
                  await reportRef.update({
                    'assignedTo': FieldValue.delete(),
                    'assignedPetugasId': FieldValue.delete(),
                    'petugasId': FieldValue.delete(),
                    'idPetugas': FieldValue.delete(),
                    'ditugaskanKe': FieldValue.delete(),
                    'petugasDitugaskan': FieldValue.delete(),
                    'penanggungJawab': FieldValue.delete(),
                    'petugasNama': FieldValue.delete(),
                    'namaPetugas': FieldValue.delete(),
                    'assignedAt': FieldValue.delete(),
                    'assignedByUid': FieldValue.delete(),
                    'assignmentStatus': FieldValue.delete(),
                  });
                } else {
                  await reportRef.update({
                    // Semua alias utama ditulis agar aplikasi petugas versi lama/baru
                    // tetap dapat menemukan tugas yang diberikan admin.
                    'assignedTo': selectedId,
                    'assignedPetugasId': selectedId,
                    'petugasId': selectedId,
                    'idPetugas': selectedId,
                    'ditugaskanKe': selectedId,
                    'petugasDitugaskan': selectedId,
                    'penanggungJawab': selectedId,
                    'petugasNama': selectedNama,
                    'namaPetugas': selectedNama,
                    'assignedAt': FieldValue.serverTimestamp(),
                    'assignedByUid': FirebaseAuth.instance.currentUser?.uid,
                    'assignmentStatus': 'Ditugaskan',
                  });
                }

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        selectedId.isEmpty
                            ? 'Penugasan berhasil dibatalkan.'
                            : 'Laporan berhasil ditugaskan kepada $selectedNama ($selectedId).',
                      ),
                      backgroundColor: Colors.teal[700],
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menyimpan penugasan: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              } finally {
                if (dialogContext.mounted) setDialogState(() => saving = false);
              }
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.assignment_ind_rounded, color: Color(0xFF818CF8)),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Tugaskan Laporan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                height: 390,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (reportData['judul'] ?? 'Tanpa Judul').toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Pilih petugas yang akan menerima dan menangani laporan ini.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('petugas')
                            .orderBy('nama')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Color(0xFF818CF8), strokeWidth: 2));
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Gagal memuat petugas: ${snapshot.error}',
                                style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                              ),
                            );
                          }

                          final petugas = snapshot.data?.docs ?? [];
                          if (petugas.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline_rounded, color: Colors.grey[600], size: 42),
                                  const SizedBox(height: 8),
                                  Text('Belum ada petugas.', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text('Tambahkan petugas terlebih dahulu.', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: petugas.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 7),
                            itemBuilder: (context, index) {
                              final doc = petugas[index];
                              final data = doc.data();
                              final id = (data['idPetugas'] ?? doc.id).toString();
                              final nama = (data['nama'] ?? data['username'] ?? 'Petugas').toString();
                              final tugas = (data['tugas'] ?? data['bidang'] ?? '').toString();
                              final isSelected = selectedId == id;

                              return InkWell(
                                onTap: () => setDialogState(() {
                                  selectedId = id;
                                  selectedNama = nama;
                                }),
                                borderRadius: BorderRadius.circular(11),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF4F46E5).withValues(alpha: 0.18)
                                        : const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF818CF8) : Colors.white.withValues(alpha: 0.06),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.18),
                                        child: const Icon(Icons.person_rounded, color: Color(0xFFA5B4FC), size: 21),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(nama, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$id${tugas.isEmpty ? '' : ' • $tugas'}',
                                              style: TextStyle(color: Colors.grey[400], fontSize: 10),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                        color: isSelected ? const Color(0xFF818CF8) : Colors.grey[600],
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              actions: [
                if (selectedId.isNotEmpty)
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => setDialogState(() {
                              selectedId = '';
                              selectedNama = '';
                            }),
                    child: const Text('Batalkan Tugas', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                  ),
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Tutup', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ),
                ElevatedButton.icon(
                  onPressed: saving ? null : saveAssignment,
                  icon: saving
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 14),
                  label: Text(saving ? 'Menyimpan...' : 'Simpan Penugasan', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusActionButton(String docId, String targetStatus, bool isActive, Color color, BuildContext context) {
    return InkWell(
      onTap: isActive ? null : () => _updateStatus(docId, targetStatus, context),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? color : Colors.grey[700]!),
        ),
        child: Text(
          targetStatus,
          style: TextStyle(
            color: isActive ? color : Colors.grey[400],
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String count, IconData icon, Color color, String targetFilter, bool isDesktop) {
    bool isSelected = _selectedFilter == targetFilter;
    return InkWell(
      onTap: () {
        setState(() => _selectedFilter = targetFilter);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.04),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 8 : 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: isDesktop ? 18 : 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[400],
                          fontSize: isDesktop ? 11 : 9,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 1),
                  Text(count,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isDesktop ? 17 : 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
