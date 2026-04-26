import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  var isLoading = true.obs;
  var userModel = Rxn<UserModel2>();

  final int xpPorNivel = 1000;
  RealtimeChannel? _userChannel;

  @override
  void onInit() {
    super.onInit();
    carregarDadosUsuario();
  }

  @override
  void onClose() {
    _desinscreverRealtime();
    super.onClose();
  }

  void _desinscreverRealtime(){
    if(_userChannel != null){
      _supabase.removeChannel(_userChannel!);
      _userChannel = null;
    }
  }

  void carregarDadosUsuario() async {
    try {
      isLoading.value = true;
      User? user = _supabase.auth.currentUser;

      if (user != null) {
        final data = await _supabase
            .from('usuarios')
            .select()
            .eq('id', user.id)
            .single();

        userModel.value = UserModel2.fromMap(data);

        _userChannel = _supabase
            .channel('public:usuarios:id=${user.id}')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'usuarios',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'id',
                value: user.id,
              ),
              callback: (payload) {
                if (payload.newRecord.isNotEmpty) {
                  userModel.value = UserModel2.fromMap(payload.newRecord);
                }
              },
            )
            .subscribe();
      }
    } catch (e) {
      debugPrint("Erro ao carregar perfil: $e");
      _carregarDadosBasicosDoAuth();
    } finally {
      isLoading.value = false;
    }
  }

  void _carregarDadosBasicosDoAuth(){
    final user = _supabase.auth.currentUser;
    if(user != null && userModel.value == null){
      userModel.value = UserModel2(
        nome: user.userMetadata?['nome'] ?? "Usuário",
        email: user.email ?? "",
        telefone: user.userMetadata?['telefone'] ?? "",
        fotoUrl: user.userMetadata?['foto_url'],
        vehicle: user.userMetadata?['fk_vehicle'] ?? "",
        xp: 0,
      );
    }
  }

  int get nivelAtual => ((userModel.value?.xp ?? 0) / xpPorNivel).floor() + 1;

  double get progressoDoNivel {
    double xpAtual = userModel.value?.xp ?? 0;
    return (xpAtual % xpPorNivel) / xpPorNivel;
  }

  double get xpRestante =>
      xpPorNivel - ((userModel.value?.xp ?? 0) % xpPorNivel);

  void logout() async {
    _supabase.auth.signOut();
    Get.offAllNamed('/welcome');
  }
}
