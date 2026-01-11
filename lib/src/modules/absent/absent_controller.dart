import 'package:get/get.dart';
import '../../data/models/guardian.dart';
import '../../data/services/supabase_service.dart';

class AbsentController extends GetxController {
  final SupabaseService supabase = Get.find<SupabaseService>();

  // =====================
  // EVENT NAME
  // =====================
  final String eventName = 'Wisuda Santri';

  // =====================
  // STATE DATA
  // =====================
  final RxBool isLoading = true.obs;
  final RxList<Guardian> guardians = <Guardian>[].obs;
  final RxList<Guardian> filtered = <Guardian>[].obs;

  // =====================
  // STATE UI
  // =====================
  final RxString selectedLetter = ''.obs;
  final RxBool showBubble = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Load awal
    loadAbsent();

    // 🔥 AUTO REFRESH SAAT ADA ABSENSI BARU
    Get.find<RxBool>(tag: 'globalRefresh').listen((_) {
      loadAbsent();
    });
  }

  // =====================
  // LOAD DATA ABSENT (EVENT + HARI INI)
  // =====================
  Future<void> loadAbsent() async {
    try {
      isLoading.value = true;

      final data = await supabase.getAbsentGuardiansByEvent(eventName);

      guardians.assignAll(data);
      guardians.sort((a, b) => a.idWali.compareTo(b.idWali));
      filtered.assignAll(guardians);
    } catch (_) {
      // dikosongkan agar UI tidak crash
    } finally {
      isLoading.value = false;
    }
  }
}
