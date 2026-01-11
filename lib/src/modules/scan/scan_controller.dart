import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../data/models/guardian.dart';
import '../../data/services/supabase_service.dart';

enum ScanStatus { idle, success, notFound, error }

class ScanController extends GetxController {
  ScanController({required this.supabaseService, required this.eventName});

  final SupabaseService supabaseService;
  final String eventName;

  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final AudioPlayer _player = AudioPlayer();

  final RxBool isProcessing = false.obs;
  final RxBool isFlashOn = false.obs;
  final RxBool isFrontCamera = false.obs;

  // =====================
  // DATA HASIL SCAN
  // =====================
  final Rx<Guardian?> lastGuardian = Rx<Guardian?>(null);
  final Rx<ScanStatus> scanStatus = ScanStatus.idle.obs;
  final RxString statusMessage = ''.obs;

  // =============================================================
  // SOUND EFFECT
  // =============================================================
  Future<void> _playSuccessSound() async {
    try {
      await _player.play(AssetSource("sounds/success.mp3"));
    } catch (_) {}
  }

  Future<void> _playErrorSound() async {
    try {
      await _player.play(AssetSource("sounds/error.mp3"));
    } catch (_) {}
  }

  // =============================================================
  // FLASH
  // =============================================================
  Future<void> toggleFlash() async {
    try {
      await cameraController.toggleTorch();
      isFlashOn.value = !isFlashOn.value;
    } catch (_) {
      _showError("Flash gagal digunakan.");
      _playErrorSound();
    }
  }

  // =============================================================
  // SWITCH CAMERA
  // =============================================================
  Future<void> switchCamera() async {
    try {
      await cameraController.switchCamera();
      isFrontCamera.value = !isFrontCamera.value;
      isFlashOn.value = false;
    } catch (_) {
      _showError("Kamera gagal diganti.");
      _playErrorSound();
    }
  }

  // =============================================================
  // HANDLE QR SCAN (ALUR FINAL & AMAN)
  // =============================================================
  Future<void> handleBarcodeCapture(BarcodeCapture capture) async {
    if (isProcessing.value) return;

    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) {
      _showError("QR tidak terbaca.");
      _playErrorSound();
      return;
    }

    int id;
    try {
      id = int.parse(raw.trim());
    } catch (_) {
      _showError("Format QR tidak valid (harus angka).");
      _playErrorSound();
      return;
    }

    if (id < 1 || id > 1500) {
      _showError("ID harus dalam rentang 1–1500.");
      _playErrorSound();
      return;
    }

    isProcessing.value = true;

    try {
      // ===============================
      // 1. AMBIL DATA WALI
      // ===============================
      final guardian = await supabaseService.getGuardianById(id);

      if (guardian == null) {
        _showNotFound("Data wali tidak ditemukan.");
        _playErrorSound();
        return;
      }

      // ===============================
      // 2. CEK SUDAH ABSEN HARI INI
      // ===============================
      final alreadyToday = await supabaseService.hasAttendanceToday(
        guardian.idWali,
        eventName,
      );

      if (alreadyToday) {
        _showError("Wali ini sudah absen hari ini.");
        _playErrorSound();
        return;
      }

      // ===============================
      // 3. SIMPAN ABSENSI
      // ===============================
      await supabaseService.insertAttendance(
        guardianId: guardian.idWali,
        eventName: eventName,
      );

      // ===============================
      // 4. 🔥 SET DATA UNTUK UI (WAJIB)
      // ===============================
      lastGuardian.value = guardian;
      scanStatus.value = ScanStatus.success;
      statusMessage.value = "Absensi berhasil";

      _playSuccessSound();
      _triggerGlobalRefresh();
    } catch (e) {
      _showError("Terjadi kesalahan sistem.");
      _playErrorSound();
    } finally {
      isProcessing.value = false;
    }
  }

  // =============================================================
  // GLOBAL REFRESH (OPTIONAL)
  // =============================================================
  void _triggerGlobalRefresh() {
    if (Get.isRegistered<RxBool>(tag: "globalRefresh")) {
      Get.find<RxBool>(tag: "globalRefresh").toggle();
    }
  }

  // =============================================================
  // ERROR HANDLER (TIDAK RESET DI SUKSES)
  // =============================================================
  void _showNotFound(String msg) {
    lastGuardian.value = null;
    scanStatus.value = ScanStatus.notFound;
    statusMessage.value = msg;
  }

  void _showError(String msg) {
    lastGuardian.value = null;
    scanStatus.value = ScanStatus.error;
    statusMessage.value = msg;
  }

  // =============================================================
  @override
  void onClose() {
    cameraController.dispose();
    _player.dispose();
    super.onClose();
  }
}
