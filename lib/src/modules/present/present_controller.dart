import 'package:get/get.dart';
import '../../data/models/guardian.dart';
import '../../data/services/supabase_service.dart';

class PresentController extends GetxController {
  final SupabaseService supabase = Get.find<SupabaseService>();

  // =====================
  // EVENT NAME
  // =====================
  final String eventName = 'Wisuda Santri';

  // =====================
  // STATE
  // =====================
  final RxBool isLoading = true.obs;
  final RxList<Guardian> guardians = <Guardian>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Load awal
    loadPresent();

    // 🔥 AUTO REFRESH SAAT ADA ABSENSI BARU
    Get.find<RxBool>(tag: 'globalRefresh').listen((_) {
      loadPresent();
    });
  }

  // =====================
  // LOAD PRESENT DATA (EVENT + HARI INI)
  // =====================
  Future<void> loadPresent() async {
    try {
      isLoading.value = true;

      final data = await supabase.getPresentGuardiansByEvent(eventName);

      guardians.assignAll(data);
    } catch (_) {
      // sengaja dikosongkan agar UI tidak crash
    } finally {
      isLoading.value = false;
    }
  }
}
