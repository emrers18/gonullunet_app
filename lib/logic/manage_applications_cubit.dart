import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/application_model.dart';
import 'package:gonullunet_app/services/firebase_error_translator.dart';
import '../repo/event_repository.dart';
import 'manage_applications_state.dart';

class ManageApplicationsCubit extends Cubit<ManageApplicationsState> {
  final EventRepository _eventRepository;
  final String eventId;

  ManageApplicationsCubit({
    required EventRepository eventRepository,
    required this.eventId,
    // eventTitle artık gerekli değil; Cloud Function etkinlik adını
    // Firestore'dan kendi okuyor.
    String? eventTitle,
  })  : _eventRepository = eventRepository,
        super(ManageApplicationsInitial());

  // Başvuruları Listele
  Future<void> loadApplications() async {
    try {
      if (isClosed) return;
      emit(ManageApplicationsLoading());
      final apps = await _eventRepository.getEventApplications(eventId);
      if (isClosed) return;
      emit(ManageApplicationsLoaded(apps));
    } catch (e) {
      if (isClosed) return;
      emit(ManageApplicationsError(FirebaseErrorTranslator.translate(e)));
    }
  }

  Future<void> updateStatus(ApplicationModel app, String newStatus) async {
    try {
      await _eventRepository.updateApplicationStatus(
          eventId, app.userId, newStatus);

      // Listeyi güncel durumla yenile
      await loadApplications();
    } catch (e) {
      if (isClosed) return;
      emit(ManageApplicationsError(FirebaseErrorTranslator.translate(e)));
      if (isClosed) return;
      loadApplications();
    }
  }
}
