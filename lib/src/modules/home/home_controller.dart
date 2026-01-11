import 'package:get/get.dart';
import '../../data/services/supabase_service.dart';

class HomeController extends GetxController {
  final SupabaseService supabase = Get.find<SupabaseService>();

  // =====================
  // EVENT NAME
  // =====================
  final RxString eventName = 'Wisuda Santri 2025'.obs;

  // =====================
  // STATISTIK
  // =====================
  final RxInt totalWali = 0.obs;
  final RxInt totalHadir = 0.obs;

  int get totalBelumHadir => totalWali.value - totalHadir.value;

  @override
  void onInit() {
    super.onInit();

    // Load awal
    fetchStats();

    // 🔥 AUTO REFRESH SAAT ADA ABSENSI BARU
    Get.find<RxBool>(tag: 'globalRefresh').listen((_) {
      fetchStats();
    });
  }

  // =====================
  // AMBIL DATA DARI SUPABASE
  // =====================
  Future<void> fetchStats() async {
    try {
      totalWali.value = await supabase.getTotalGuardians();
      totalHadir.value = await supabase.getTotalAttendances();
    } catch (_) {
      // sengaja dikosongkan agar tidak crash UI
    }
  }

  // =====================
  // MANUAL REFRESH (OPSIONAL)
  // =====================
  void refreshData() => fetchStats();
}
