import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/services/supabase_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Supabase Service (GLOBAL)
    Get.put<SupabaseService>(
      SupabaseService(Supabase.instance.client),
      permanent: true,
    );

    // GLOBAL REFRESH SIGNAL (🔥 PENTING)
    Get.put<RxBool>(false.obs, tag: 'globalRefresh', permanent: true);
  }
}
