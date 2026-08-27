# 🏫✨ Web Admin Pengaduan Sekolah

Halo hai! 👋 Ini dia si **panel admin pengaduan sekolah**, dibangun pakai Flutter Web 💙 + Firebase 🔥. Tugasnya nemenin admin & petugas buat mantau laporan pengaduan siswa biar nggak keteteran ngurusnya 😤➡️😌

Anggap aja ini markas komandonya aplikasi mobile pengaduan siswa 🕹️

---

## 🌟 Fitur-fitur Kece

- 🔐 **Login Admin & Petugas** — pakai Firebase Auth. Petugas login cukup pakai username aja, di belakang layar otomatis jadi email `username@petugas.pengaduanapp.com` 🪄 (canggih kan, padahal cuma nyambung-nyambungin doang 😎)
- 📊 **Dashboard** — biar admin nggak buta info, ada kartu ringkasan status pengaduan: 🟠 Terkirim, 🟣 Diproses, 🟢 Selesai
- 📝 **Manajemen Pengaduan** — liat daftar & detail laporan dari koleksi `pengaduan`, cek foto lampiran siswa 📸, ubah status, sampai kirim tanggapan + foto balesan
- 👮 **Manajemen Petugas** — CRUD data petugas (koleksi `petugas`), bikin akun Auth otomatis pas nambah petugas baru. Username petugas **dikunci** pas diedit ⚠️ biar nggak putus nyambungnya sama akun Auth (udah pernah kena masalah ini, jangan diulang ya woy 😭)
- 📱💻 **Layout Responsif** — pakai `LayoutBuilder` + `ConstrainedBox` (maks 1300px) biar tampilan tetep rapi walau layarnya gede kayak bioskop
- 🖼️ **Upload Foto** — `image_picker` + Firebase Storage, siap nampung foto-foto bukti pengaduan

---

## 🛠️ Tech Stack

| Komponen | Teknologi |
|---|---|
| 🖥️ Framework | Flutter (Web) |
| 🔑 Auth | Firebase Authentication |
| 🗄️ Database | Cloud Firestore |
| ☁️ Storage | Firebase Storage |
| 🌐 Hosting | Firebase Hosting / InfinityFree |
| 🤖 CI/CD | GitHub Actions (`firebase-hosting-merge.yml`) |

---

## 🗃️ Struktur Data Firestore

- **`pengaduan`** 📮 — status, foto siswa, tanggapan, foto tanggapan, dkk
- **`petugas`** 🧑‍💼 — data petugas yang nyambung ke akun Firebase Auth-nya

---

## ✅ Yang Harus Disiapin Dulu

- Flutter SDK stable channel 🎯
- Project Firebase yang udah aktif Authentication, Firestore, sama Storage-nya 🔥
- Dart SDK `>=3.0.0 <4.0.0`

---

## 🚀 Cara Jalanin di Lokal

1. Clone dulu reponya 📦
   ```bash
   git clone <url-repo-ini>
   cd web-admin-sekolah-main
   ```
2. Install dependency-nya 🧩
   ```bash
   flutter pub get
   ```
3. Pastiin konfigurasi Firebase udah kepasang bener, dan kalau perlu tambahin domain lokal ke **Authorized Domains** di Firebase Console biar login-nya nggak ngambek 🙅‍♂️
4. Gaskeun! 🏁
   ```bash
   flutter run -d chrome
   ```

---

## 📦 Build buat Production

```bash
flutter build web --release
```

Hasilnya nongol di folder `build/web`, isinya `index.html` sebagai gerbang utama plus aset lainnya ✨

---

## ☁️ Deployment

### Firebase Hosting (Otomatis via GitHub Actions) 🤖

Tiap kali `push` ke branch `main`, robotnya langsung kerja:
1. Install Flutter 🛬
2. `flutter pub get` 🧩
3. `flutter build web --release` 🔨
4. Deploy ke Firebase Hosting project `pengduanapp` 🚀

Workflow-nya ada di `.github/workflows/firebase-hosting-merge.yml`, butuh secret `FIREBASE_SERVICE_ACCOUNT_PENGADUANSEKOLAH` yang udah disetel di GitHub 🔒

### Deploy Manual ke InfinityFree (atau hosting statis lain) 🐢

1. `flutter build web --release` dulu ya
2. Upload semua isi folder `build/web` ke `htdocs` 📤
3. Cek lagi `<base href="/">` di `index.html`, jangan sampe salah alamat 🧭
4. Jangan lupa tambahin domainnya ke **Authorized Domains** Firebase Console, kalau kelupaan login-nya bakal error mulu 😩

---

## ⚠️ Catatan Penting (Wajib Baca!)

- **JANGAN** asal ubah username petugas yang udah punya akun Auth! Soalnya username itu bahan bikin email login (`username@petugas.pengaduanapp.com`). Kalau berubah sembarangan, putus deh koneksi Firestore sama Auth-nya 💔
- Selalu double-check `firebase.json` (bagian `hosting.public` & `rewrites`) sebelum deploy, biar routing SPA-nya nggak nyasar 🗺️

---

## 📄 Lisensi

Belum ada, masih bebas merdeka 🕊️

---

Made with 💻, ☕, dan sedikit drama debugging Firebase Auth 😅
