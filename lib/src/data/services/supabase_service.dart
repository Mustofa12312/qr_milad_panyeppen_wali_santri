import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guardian.dart';

class SupabaseService {
  SupabaseService(this._client);

  final SupabaseClient _client;

  // ===============================
  // UTIL: tanggal hari ini (YYYY-MM-DD)
  // ===============================
  String _todayDate() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // =====================================================
  // CEK APAKAH WALI SUDAH ABSEN HARI INI
  // (AMAN: scan_date DATE)
  // =====================================================
  Future<bool> hasAttendanceToday(int guardianId, String eventName) async {
    final data = await _client
        .from('attendances')
        .select('id')
        .eq('guardian_id', guardianId)
        .eq('event_name', eventName)
        .eq('scan_date', _todayDate())
        .maybeSingle();

    return data != null;
  }

  // =====================================================
  // GET GUARDIAN BY ID
  // =====================================================
  Future<Guardian?> getGuardianById(int idWali) async {
    final data = await _client
        .from('guardians')
        .select()
        .eq('id_wali', idWali)
        .maybeSingle();

    if (data == null) return null;
    return Guardian.fromMap(data as Map<String, dynamic>);
  }

  // =====================================================
  // INSERT ATTENDANCE (KOMPATIBEL LAMA)
  // =====================================================
  Future<void> insertAttendance({
    required int guardianId,
    String? eventName,
  }) async {
    await _client.from('attendances').insert({
      'guardian_id': guardianId,
      'event_name': eventName ?? 'Wisuda Santri',
    });
  }

  // =====================================================
  // TOTAL GUARDIANS
  // =====================================================
  Future<int> getTotalGuardians() async {
    final data = await _client.from('guardians').select('id_wali');
    return data.length;
  }

  // =====================================================
  // TOTAL ATTENDANCES (MODE LAMA)
  // =====================================================
  Future<int> getTotalAttendances() async {
    final data = await _client.from('attendances').select('id');
    return data.length;
  }

  // =====================================================
  // TOTAL ATTENDANCES (HARI INI + EVENT)
  // =====================================================
  Future<int> getTotalAttendancesToday(String eventName) async {
    final data = await _client
        .from('attendances')
        .select('id')
        .eq('event_name', eventName)
        .eq('scan_date', _todayDate());

    return data.length;
  }

  // =====================================================
  // GET PRESENT GUARDIANS (MODE LAMA)
  // =====================================================
  Future<List<Guardian>> getPresentGuardians() async {
    final data = await _client
        .from('attendances')
        .select('guardians!inner(*)')
        .order('guardian_id');

    return data
        .map<Guardian>((row) => Guardian.fromMap(row['guardians']))
        .toList();
  }

  // =====================================================
  // GET PRESENT GUARDIANS (HARI INI + EVENT)
  // =====================================================
  Future<List<Guardian>> getPresentGuardiansByEvent(String eventName) async {
    final data = await _client
        .from('attendances')
        .select('guardians!inner(*)')
        .eq('event_name', eventName)
        .eq('scan_date', _todayDate())
        .order('guardian_id');

    return data
        .map<Guardian>((row) => Guardian.fromMap(row['guardians']))
        .toList();
  }

  // =====================================================
  // GET ABSENT GUARDIANS (MODE LAMA)
  // =====================================================
  Future<List<Guardian>> getAbsentGuardians() async {
    final present = await _client.from('attendances').select('guardian_id');

    final presentIds = present
        .map<int>((e) => e['guardian_id'] as int)
        .toList();

    if (presentIds.isEmpty) {
      final all = await _client.from('guardians').select().order('id_wali');
      return all.map<Guardian>((e) => Guardian.fromMap(e)).toList();
    }

    final data = await _client
        .from('guardians')
        .select()
        .not('id_wali', 'in', presentIds)
        .order('id_wali');

    return data.map<Guardian>((e) => Guardian.fromMap(e)).toList();
  }

  // =====================================================
  // GET ABSENT GUARDIANS (HARI INI + EVENT)
  // =====================================================
  Future<List<Guardian>> getAbsentGuardiansByEvent(String eventName) async {
    final present = await _client
        .from('attendances')
        .select('guardian_id')
        .eq('event_name', eventName)
        .eq('scan_date', _todayDate());

    final presentIds = present
        .map<int>((e) => e['guardian_id'] as int)
        .toList();

    if (presentIds.isEmpty) {
      final all = await _client.from('guardians').select().order('id_wali');
      return all.map<Guardian>((e) => Guardian.fromMap(e)).toList();
    }

    final data = await _client
        .from('guardians')
        .select()
        .not('id_wali', 'in', presentIds)
        .order('id_wali');

    return data.map<Guardian>((e) => Guardian.fromMap(e)).toList();
  }
}
