import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class FuelCard extends StatelessWidget {
  final FuelEntryModel entry;
  final HomeController controller;
  const FuelCard({super.key, required this.entry, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final vehicle = controller.veiculosMap[entry.vehicleId];
    final stationName = controller.postosMap[entry.gasStationId]?['nome'];
    final fuelTypeName = controller.tiposMap[entry.fuelTypeId]?['nome'];

    List<String> sharedPhotos = entry.sharedWith.map((uid) {
      final user = controller.usuariosMap[uid];
      return user?['fotoUrl']?.toString() ?? "";
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Dismissible(
        key: Key(entry.id ?? DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => controller.delete(entry.id),
        background: _buildDeleteBackground(),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => controller.navigateToEditEntry(context, entry),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, vehicle, sharedPhotos, theme),
                    const Divider(height: 32, thickness: 0.5),
                    _rowInfo(
                      RemixIcons.map_pin_2_line,
                      stationName,
                      _badge(fuelTypeName),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _miniStat(
                          "hp_odometro".tr,
                          controller.settingsController.formatarDistancia(
                            entry.odometerKm,
                          ),
                        ),
                        _miniStat(
                          "hp_volume".tr,
                          controller.settingsController.formatarVolume(
                            entry.volumeLiters,
                          ),
                        ),
                        if (entry.tankFull) _consumptionTag(),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _priceFooter(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Map<String, dynamic>? vehicle,
    List<String> photos,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    vehicle?['nickname'] ?? "---",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _mostrarCompartilhar(context, entry.id!),
                    icon: Icon(
                      RemixIcons.share_forward_line,
                      size: 20,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _plateWidget(
              vehicle?['plate'] ?? "",
              vehicle?['is_mercosul'] ?? false,
            ),
            if (photos.isNotEmpty) ...[
              const SizedBox(width: 8),
              _buildSharedAvatars(photos, theme),
            ],
          ],
        ),
      ],
    );
  }

  Container _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 25),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(RemixIcons.delete_bin_line, color: Colors.white),
    );
  }

  void _mostrarCompartilhar(BuildContext context, String registroId) {
    final String? currentUid = controller.auth.currentUser?.uid;

    Get.defaultDialog(
      title: "Compartilhar com...",
      content: SizedBox(
        width: double.infinity,
        child: Obx(() {
          final listUsuarios = controller.usuariosMap.values
              .where((u) => u['id'] != currentUid)
              .toList();

          if (listUsuarios.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Nenhuma outro utilizador encontrado."),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: listUsuarios.map((user) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      (user['fotoUrl'] != null && user['fotoUrl'].isNotEmpty)
                      ? NetworkImage(user['fotoUrl'])
                      : null,
                  child: (user['fotoUrl'] == null || user['fotoUrl'].isEmpty)
                      ? Icon(RemixIcons.user_3_line)
                      : null,
                ),
                title: Text(user['nome'] ?? "Sem nome"),
                subtitle: Text(user['email'] ?? ""),
                onTap: () {
                  controller.compartilharComUsuario(registroId, user['id']);
                  Get.back();
                },
              );
            }).toList(),
          );
        }),
      ),
    );
  }

  Widget _buildSharedAvatars(List<String> photos, ThemeData theme) {
    int maxVisible = 3;
    int totalItems = photos.length > maxVisible ? maxVisible : photos.length;

    return SizedBox(
      height: 20,
      width: 20.0 + (totalItems * 12),
      child: Stack(
        children: List.generate(totalItems, (index) {
          String photoUrl = photos[index];
          bool hasPhoto = photoUrl.isNotEmpty;

          return Positioned(
            left: index * 12.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 9,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                child: !hasPhoto
                    ? Icon(
                        RemixIcons.user_3_fill,
                        size: 10,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _priceFooter(ThemeData theme) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.black12,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Preço/L", style: TextStyle(fontSize: 9, color: Colors.grey)),
            Text(
              controller.settingsController.formatarCurrency(
                entry.pricePerLiter,
              ),
              style: GoogleFonts.firaCode(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Total pago",
              style: TextStyle(fontSize: 9, color: Colors.blueAccent),
            ),
            Text(
              controller.settingsController.formatarCurrency(entry.totalCost),
              style: GoogleFonts.inter(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _miniStat(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );

  Widget _consumptionTag() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.green.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text(
      "CHEIO",
      style: TextStyle(
        color: Colors.greenAccent,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _rowInfo(IconData icon, String text, Widget trailing) => Row(
    children: [
      Icon(icon, size: 16, color: Colors.blueAccent),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing,
    ],
  );

  Widget _badge(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 9,
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _plateWidget(String plate, bool mercosul) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(width: 1),
    ),
    child: Text(
      plate,
      style: GoogleFonts.robotoMono(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    ),
  );
}
