import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/events/event_card.dart';
import 'package:gonullunet_app/widgets/events/add_event_modal.dart';

import '../logic/event_cubit.dart';
import '../logic/event_state.dart';
import 'events_map_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  void initState() {
    super.initState();
    context.read<EventCubit>().loadEvents();
  }

  void _showAddEventModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddEventModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Etkinlikler',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Colors.black54),
            tooltip: "Haritada Göster",
            onPressed: () {
              final state = context.read<EventCubit>().state;

              if (state is EventLoaded) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventsMapPage(events: state.events),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text("Etkinlikler yükleniyor, lütfen bekleyin.")),
                );
              }
            },
          ),
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
      body: BlocBuilder<EventCubit, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryColor));
          }

          if (state is EventError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (state is EventLoaded) {
            if (state.events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz hiç etkinlik yok.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
                return EventCard(event: event);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 24),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<EventCubit, EventState>(
        builder: (context, state) {
          if (state is EventLoaded && state.isNgo) {
            return FloatingActionButton(
              onPressed: _showAddEventModal,
              heroTag: 'add_event_fab',
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
