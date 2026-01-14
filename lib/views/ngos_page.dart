import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/widgets/ngos/ngos_card.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/logic/ngo_cubit.dart';
import 'package:gonullunet_app/logic/ngo_state.dart';
import 'package:gonullunet_app/repo/ngo_repository.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

class NgosPage extends StatelessWidget {
  const NgosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NgoCubit(NgoRepository())..loadNgos(),
      child: const NgosView(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Kurumlar',
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          )),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            color: AppColors.kBackgroundColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.kTextMain,
                          ),
                          decoration: InputDecoration(
                            hintText: "STK veya kategori ara...",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon:
                                Icon(Icons.search, color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: AppColors.kSecondaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.kSecondaryColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: () {
                          // Detaylı filtre modalını aç
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<NgoCubit, NgoState>(
              builder: (context, state) {
                if (state is NgoLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.kPrimaryColor));
                }

                if (state is NgoError) {
                  return Center(child: Text(state.message));
                }

                if (state is NgoLoaded) {
                  if (state.ngos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('Sonuç bulunamadı.',
                              style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 Sütun
                      childAspectRatio: 0.75, // Kart oranı (Dikey dikdörtgen)
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.ngos.length,
                    itemBuilder: (context, index) {
                      final ngo = state.ngos[index];
                      return NgoCard(ngo: ngo);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
