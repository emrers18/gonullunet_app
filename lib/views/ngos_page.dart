import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/ngos/ngos_card.dart';

import '../logic/ngo_cubit.dart';
import '../logic/ngo_state.dart';
import '../repo/ngo_repository.dart';

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

class NgosView extends StatelessWidget {
  const NgosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kurumlar',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black54),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Filtreleme yakında!")),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NgoCubit, NgoState>(
        builder: (context, state) {
          if (state is NgoLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (state is NgoError) {
            return Center(child: Text(state.message));
          }

          if (state is NgoLoaded) {
            if (state.ngos.isEmpty) {
              return const Center(
                child: Text('Gösterilecek kurum (STK) bulunamadı.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.ngos.length,
              itemBuilder: (context, index) {
                final ngo = state.ngos[index];
                return NgoCard(ngo: ngo);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 24),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
