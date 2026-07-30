import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              body:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
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
          SnackBar(
              content: Text(pesanError), backgroundColor: Colors.redAccent),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.redAccent),
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
                      child: const Icon(Icons.shield_rounded,
                          color: Color(0xFF38BDF8), size: 36),
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
                        labelStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 12),
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Color(0xFF38BDF8), size: 20),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Email wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 12),
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: Color(0xFF38BDF8), size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Password wajib diisi' : null,
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
                                child: CircularProgressIndicator(
                                    color: Color(0xFF0F172A), strokeWidth: 2),
                              )
                            : const Text(
                                'MASUK',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
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
// HALAMAN DASHBOARD UTAMA (MINIMALIS & RAPI)
// =========================================================================
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _selectedFilter = 'Semua';

  void _updateStatus(
      String docId, String statusBaru, BuildContext context) async {
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

  void _kirimFeedbackDialog(
      String docId, String feedbackLama, BuildContext context) {
    final TextEditingController feedbackController =
        TextEditingController(text: feedbackLama);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.rate_review_rounded,
                      color: Color(0xFF38BDF8), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tanggapan Admin',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 340,
                child: TextField(
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
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('pengaduan')
                          .doc(docId)
                          .update({'feedback': feedbackController.text.trim()});

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tanggapan berhasil dikirim!'),
                          backgroundColor: Colors.teal,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Gagal: $e'),
                            backgroundColor: Colors.redAccent),
                      );
                    }
                  },
                  child: const Text('Kirim',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            );
          },
        );
      },
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
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: Color(0xFF38BDF8), size: 18),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'ADMIN DASHBOARD',
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
            icon: const Icon(Icons.logout_rounded,
                color: Colors.redAccent, size: 20),
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
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF38BDF8), strokeWidth: 2));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 12)),
            );
          }

          final allDocs = snapshot.hasData ? snapshot.data!.docs : [];

          int totalLaporan = allDocs.length;
          int totalTerkirim = allDocs
              .where((d) =>
                  (d.data() as Map)['status'] == 'Terkirim' ||
                  (d.data() as Map)['status'] == null)
              .length;
          int totalDiproses = allDocs
              .where((d) => (d.data() as Map)['status'] == 'Diproses')
              .length;
          int totalSelesai = allDocs
              .where((d) => (d.data() as Map)['status'] == 'Selesai')
              .length;

          final docs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            String status = data['status'] ?? 'Terkirim';
            if (_selectedFilter == 'Semua') return true;
            return status.toLowerCase() == _selectedFilter.toLowerCase();
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER RINGKAS
                const Text(
                  'Pusat Kontrol Pengaduan',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kelola dan pantau pengaduan siswa secara real-time.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
                const SizedBox(height: 12),

                // KARTU STATISTIK MINIMALIS (2x2 GRID)
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.6,
                  children: [
                    _buildMetricCard('Total', '$totalLaporan',
                        Icons.folder_shared, Colors.blue),
                    _buildMetricCard('Terkirim', '$totalTerkirim',
                        Icons.hourglass_top, Colors.orange),
                    _buildMetricCard(
                        'Diproses', '$totalDiproses', Icons.sync, Colors.amber),
                    _buildMetricCard('Selesai', '$totalSelesai',
                        Icons.check_circle, Colors.teal),
                  ],
                ),

                const SizedBox(height: 12),

                // FILTER CHIPS MINIMALIS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', Icons.dashboard_outlined),
                      const SizedBox(width: 6),
                      _buildFilterChip('Terkirim', Icons.send_rounded),
                      const SizedBox(width: 6),
                      _buildFilterChip('Diproses', Icons.autorenew_rounded),
                      const SizedBox(width: 6),
                      _buildFilterChip('Selesai', Icons.verified_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // DAFTAR LAPORAN KARTU RAPI
                docs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Column(
                            children: [
                              Icon(Icons.inbox_rounded,
                                  size: 48, color: Colors.grey[700]),
                              const SizedBox(height: 8),
                              Text(
                                'Tidak ada data untuk status "$_selectedFilter".',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12),
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
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final dateStr = _formatDateTime(data['timestamp']);
                          String status = data['status'] ?? 'Terkirim';
                          String feedback = data['feedback'] ?? '';
                          String kategori = data['kategori'] ?? 'Pengaduan';

                          Color statusColor = status == 'Selesai'
                              ? Colors.teal
                              : status == 'Diproses'
                                  ? Colors.amber
                                  : Colors.orange;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // BARIS KATEGORI & STATUS
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: kategori == 'Saran'
                                              ? Colors.blue
                                                  .withValues(alpha: 0.15)
                                              : Colors.deepOrange
                                                  .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          kategori.toUpperCase(),
                                          style: TextStyle(
                                            color: kategori == 'Saran'
                                                ? Colors.blue[300]
                                                : Colors.orange[300],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                              alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: statusColor.withValues(
                                                  alpha: 0.3)),
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
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(
                                        color: Color(0xFF334155), height: 1),
                                  ),
                                  Text(
                                    data['judul'] ?? 'Tanpa Judul',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['isi'] ?? '',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[300],
                                        height: 1.3),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 10),
                                  ),
                                  if (feedback.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFF38BDF8)
                                                .withValues(alpha: 0.2)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Tanggapan Admin:',
                                            style: TextStyle(
                                                color: Color(0xFF38BDF8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(feedback,
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(
                                        color: Color(0xFF334155), height: 1),
                                  ),

                                  // TOMBOL AKSI COMPACT
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(
                                        height: 32,
                                        child: OutlinedButton.icon(
                                          onPressed: () => _kirimFeedbackDialog(
                                              docId, feedback, context),
                                          icon: const Icon(
                                              Icons.chat_bubble_outline_rounded,
                                              size: 13,
                                              color: Color(0xFF38BDF8)),
                                          label: Text(
                                              feedback.isEmpty
                                                  ? 'Beri Tanggapan'
                                                  : 'Edit Tanggapan',
                                              style: const TextStyle(
                                                  color: Color(0xFF38BDF8),
                                                  fontSize: 11)),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                                color: const Color(0xFF38BDF8)
                                                    .withValues(alpha: 0.4)),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6)),
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
                                            const Text('Status:',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10)),
                                            const SizedBox(width: 4),
                                            _buildStatusActionButton(
                                                docId,
                                                'Terkirim',
                                                status == 'Terkirim',
                                                Colors.orange,
                                                context),
                                            const SizedBox(width: 3),
                                            _buildStatusActionButton(
                                                docId,
                                                'Diproses',
                                                status == 'Diproses',
                                                Colors.amber,
                                                context),
                                            const SizedBox(width: 3),
                                            _buildStatusActionButton(
                                                docId,
                                                'Selesai',
                                                status == 'Selesai',
                                                Colors.teal,
                                                context),
                                          ],
                                        ),
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

  Widget _buildStatusActionButton(String docId, String targetStatus,
      bool isActive, Color color, BuildContext context) {
    return InkWell(
      onTap:
          isActive ? null : () => _updateStatus(docId, targetStatus, context),
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

  Widget _buildMetricCard(
      String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: TextStyle(color: Colors.grey[400], fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Text(count,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    bool isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon,
          size: 12,
          color: isSelected ? const Color(0xFF0F172A) : Colors.grey[400]),
      selected: isSelected,
      selectedColor: const Color(0xFF38BDF8),
      backgroundColor: const Color(0xFF1E293B),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF0F172A) : Colors.grey[300],
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF38BDF8)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      onSelected: (selected) {
        setState(() => _selectedFilter = label);
      },
      visualDensity: VisualDensity.compact,
    );
  }
}
