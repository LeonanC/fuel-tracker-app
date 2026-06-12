import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker_app/data/models/station_model.dart';
import 'package:fuel_tracker_app/modules/gas/controller/station_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class StationScreen extends GetView<StationController> {
  const StationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: Obx(() {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120.h,
              floating: true,
              pinned: true,
              elevation: 0,
              stretch: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.only(bottom: 16.h),
                title: Text(
                  'gs_titulo'.tr,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
            if (controller.isLoading.value)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ),
              )
            else if (controller.gasStationsMap.isEmpty)
              SliverFillRemaining(child: _buildEmptyState(colorScheme))
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 100.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final postos = controller.gasStationsMap.values.toList();
                    final data = postos[index];
                    final posto = StationModel.fromMap(data, data['pk_posto']);
                    return _buildPostoCard(posto, theme);
                  }, childCount: controller.gasStationsMap.length),
                ),
              ),
          ],
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFab(colorScheme, context),
    );
  }

  Widget _buildFab(ColorScheme colorScheme, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        onPressed: () => controller.navigateToAddStation(context),
        elevation: 0,
        label: Text(
          "gs_novo_posto".tr,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
        icon: Icon(RemixIcons.add_fill, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            RemixIcons.gas_station_line,
            size: 80.sp,
            color: colorScheme.primary.withOpacity(0.2),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          "gs_nenhum_posto".tr,
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildPostoCard(StationModel posto, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key(posto.id ?? DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.deletePosto(posto.id!),
      background: _buildDeleteBackground(),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: InkWell(
            onTap: () => controller.navigateToEditStation(posto),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildBrandLogo(posto.brand, colorScheme),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              posto.nome,
                              style: GoogleFonts.montserrat(
                                color: colorScheme.onSurface,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (posto.address != null)
                              Text(
                                posto.address!,
                                style: GoogleFonts.montserrat(
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      if (posto.precoGasolina > 0)
                        _buildPriceChip(
                          RemixIcons.drop_fill,
                          "GAS",
                          posto.precoGasolina,
                          Colors.blueAccent,
                        ),
                      if (posto.precoEtanol > 0)
                        _buildPriceChip(
                          RemixIcons.leaf_fill,
                          "ETA",
                          posto.precoEtanol,
                          Colors.greenAccent,
                        ),
                      if (posto.precoDiesel > 0)
                        _buildPriceChip(
                          RemixIcons.truck_fill,
                          "DIE",
                          posto.precoDiesel,
                          Colors.orangeAccent,
                        ),
                      if (posto.precoGnv > 0)
                        _buildPriceChip(
                          RemixIcons.fire_fill,
                          "GNV",
                          posto.precoGnv,
                          Colors.purpleAccent,
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      _buildStatusBadge(
                        RemixIcons.store_2_line,
                        "gs_loja".tr,
                        posto.hasConvenientStore,
                        colorScheme,
                      ),
                      SizedBox(width: 8.w),
                      _buildStatusBadge(
                        RemixIcons.time_fill,
                        "gs_24h".tr,
                        posto.is24Hours,
                        colorScheme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteBackground(){
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

  Widget _buildPriceChip(
    IconData icon,
    String label,
    double price,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 6.w),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: GoogleFonts.montserrat(
                    color: color.withOpacity(0.8),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: controller.settings.formatarCurrency(price),
                  style: GoogleFonts.montserrat(
                    color: color,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLogo(String brand, ColorScheme colorScheme) {
    String brandLower = brand.toLowerCase();
    IconData icon;
    Color color;

    if (brandLower.contains('petrobras') || brandLower.contains(' br ')) {
      icon = RemixIcons.contrast_drop_line;
      color = Colors.greenAccent;
    } else if (brandLower.contains('shell')) {
      icon = RemixIcons.goblet_line;
      color = Colors.redAccent;
    } else if (brandLower.contains('ipiranga')) {
      icon = RemixIcons.triangle_line;
      color = Colors.orangeAccent;
    } else if (brandLower.contains('ale')) {
      icon = RemixIcons.rhythm_line;
      color = Color(0xFFED1C24);
    } else if (brandLower.contains('amrx')) {
      icon = RemixIcons.star_fill;
      color = Color(0xFFD32F2F);
    } else {
      icon = RemixIcons.gas_station_fill;
      color = colorScheme.primary;
    }

    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Icon(icon, color: color, size: 28.sp),
    );
  }

  Widget _buildStatusBadge(
    IconData icon,
    String label,
    bool isActive,
    ColorScheme colorScheme,
  ) {
    final color = isActive
        ? colorScheme.primary
        : colorScheme.onSurface.withOpacity(0.3);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: color,
              fontSize: 10.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
