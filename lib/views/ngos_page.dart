import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/ngos/ngos_card.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/logic/ngo_cubit.dart';
import 'package:gonullunet_app/logic/ngo_state.dart';
import 'package:gonullunet_app/repo/ngo_repository.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';

class NgosPage extends StatelessWidget {
  const NgosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => NgoRepository(),
      child: BlocProvider(
        create: (context) =>
            NgoCubit(context.read<NgoRepository>())..loadNgos(),
        child: const NgosView(),
      ),
    );
  }
}

class NgosView extends StatefulWidget {
  const NgosView({super.key});

  @override
  State<NgosView> createState() => _NgosViewState();
}

class _NgosViewState extends State<NgosView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _activeCity;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      context.read<NgoCubit>().searchNgos(query);
    });
  }

  void _openCityFilterSheet() {
    final cubit = context.read<NgoCubit>();
    final allCities = cubit.availableCities;
    String citySearchQuery = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filteredCities = allCities
                .where((city) =>
                    city.toLowerCase().contains(citySearchQuery.toLowerCase()))
                .toList();

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Şehre Göre Filtrele',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kTextColor,
                        ),
                      ),
                      if (_activeCity != null)
                        TextButton(
                          onPressed: () {
                            setState(() => _activeCity = null);
                            cubit.filterByCity(null);
                            Navigator.pop(sheetContext);
                          },
                          child: Text(
                            'Temizle',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.kSecondaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // City Search Bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setSheetState(() {
                          citySearchQuery = value;
                        });
                      },
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: "Şehir ara...",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon:
                            Icon(Icons.search, size: 20, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (allCities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Henüz şehir bilgisi mevcut değil.',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else if (filteredCities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Eşleşen şehir bulunamadı.',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: filteredCities.map((city) {
                            final isSelected = _activeCity == city;
                            return ChoiceChip(
                              label: Text(city),
                              selected: isSelected,
                              onSelected: (selected) {
                                final selectedCity = selected ? city : null;
                                setState(() => _activeCity = selectedCity);
                                cubit.filterByCity(selectedCity);
                                Navigator.pop(sheetContext);
                              },
                              selectedColor: AppColors.kSecondaryColor,
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.kTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.kSecondaryColor
                                      : Colors.transparent,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<NgoCubit, NgoState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // ── Blue Hero Header ──
              SliverToBoxAdapter(
                child: _buildHeader(context, state),
              ),

              // ── Active Filter Badge & Counter ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'Tüm Kurumlar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (state is NgoLoaded)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${state.ngos.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (_activeCity != null) _buildCityBadge(),
                    ],
                  ),
                ),
              ),

              // ── Grid Content ──
              _buildContent(context, state),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NgoState state) {
    const Color headerStart = Color(0xFF1565C0);
    const Color headerEnd = Color(0xFF42A5F5);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [headerStart, headerEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kurumlar',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sivil toplum kuruluşlarını keşfet ve destek ol',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              // Search & Filter Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.kTextColor,
                        ),
                        decoration: const InputDecoration(
                          hintText: "STK veya kategori ara...",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon:
                              Icon(Icons.search_rounded, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _openCityFilterSheet,
                    child: Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: _activeCity != null
                            ? Colors.white
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: _activeCity == null
                            ? Border.all(color: Colors.white.withOpacity(0.3))
                            : null,
                      ),
                      child: Icon(
                        _activeCity != null
                            ? Icons.location_on_rounded
                            : Icons.tune_rounded,
                        color: _activeCity != null ? headerStart : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 13, color: Colors.orange),
          const SizedBox(width: 5),
          Text(
            _activeCity!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF1565C0),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() => _activeCity = null);
              context.read<NgoCubit>().filterByCity(null);
            },
            child: const Icon(Icons.close, size: 14, color: Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, NgoState state) {
    if (state is NgoLoading) {
      return const SliverFillRemaining(
        child: AppLoadingCenter(),
      );
    }

    if (state is NgoError) {
      return SliverFillRemaining(
        child: Center(child: Text(state.message)),
      );
    }

    if (state is NgoLoaded) {
      if (state.ngos.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Sonuç bulunamadı.',
                    style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => NgoCard(ngo: state.ngos[index]),
            childCount: state.ngos.length,
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
