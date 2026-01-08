import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/application_model.dart';
import '../repo/event_repository.dart';
import '../repo/notification_repository.dart';
import 'manage_applications_state.dart';

class ManageApplicationsCubit extends Cubit<ManageApplicationsState> {
  final EventRepository _eventRepository;
  final NotificationRepository _notificationRepo;
  final String eventId;
  final String eventTitle; // Bildirim metni için başlığı tutuyoruz

  ManageApplicationsCubit({
    required EventRepository eventRepository,
    required NotificationRepository notificationRepo,
    required this.eventId,
    required this.eventTitle,
  })  : _eventRepository = eventRepository,
        _notificationRepo = notificationRepo,
        super(ManageApplicationsInitial());

  // Başvuruları Listele
  Future<void> loadApplications() async {
    try {
      emit(ManageApplicationsLoading());
      final apps = await _eventRepository.getEventApplications(eventId);
      emit(ManageApplicationsLoaded(apps));
    } catch (e) {
      emit(ManageApplicationsError("Başvurular yüklenemedi: $e"));
    }
  }

  // Başvuru Durumunu Güncelle (Onayla / Reddet)
  Future<void> updateStatus(ApplicationModel app, String newStatus) async {
    try {
      // 1. Veritabanında durumu güncelle
      await _eventRepository.updateApplicationStatus(
          eventId, app.userId, newStatus);

      // 2. Eğer onaylandıysa (approved), kullanıcıya bildirim gönder
      if (newStatus == 'approved') {
        await _notificationRepo.sendNotification(
          userId: app.userId,
          title: "Başvurunuz Onaylandı! 🎉",
          body:
              "'$eventTitle' projesi için yaptığınız başvuru kabul edildi. Tebrikler!",
          type: 'event_approval',
          relatedId: eventId,
        );
      }

      // 3. Listeyi yenile ki güncel durum görünsün
      await loadApplications();
    } catch (e) {
      emit(ManageApplicationsError("İşlem başarısız: $e"));
      // Hata olsa bile listeyi tekrar yükle ki tutarlı kalsın
      loadApplications();
    }
  }
}
