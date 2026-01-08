import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/events/event_card.dart';
import 'package:gonullunet_app/widgets/events/add_event_modal.dart';

import '../logic/event_cubit.dart';
import '../logic/event_state.dart';
import '../widgets/events/event_filter_modal.dart';
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

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<EventCubit>(),
          child: const EventFilterModal(),
        );
      },
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
            icon: const Icon(Icons.map, color: Colors.black54),
            tooltip: "Haritada Göster",
            onPressed: () {
              final state = context.read<EventCubit>().state;

              if (state is EventLoaded) {
                final activeEvents = state.events
                    .where((e) => e.date.isAfter(DateTime.now()))
                    .toList();

                if (activeEvents.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventsMapPage(events: activeEvents),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text("Haritada gösterilecek güncel etkinlik yok.")),
                  );
                }
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
            icon: const Icon(Icons.filter_list_sharp, color: Colors.black54),
            onPressed: _showFilterModal,
            tooltip: "Etkinlikleri Filtrele",
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
                      'Henüz hiç etkinlik yok veya filtreye uygun sonuç bulunamadı.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<EventCubit>().clearFilters();
                      },
                      child: const Text("Filtreleri Temizle",
                          style: TextStyle(color: AppColors.primaryColor)),
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
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
