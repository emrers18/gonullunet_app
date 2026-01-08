import 'package:equatable/equatable.dart';

abstract class AddEventState extends Equatable {
  const AddEventState();

  @override
  List<Object?> get props => [];
}

// 1. Başlangıç Durumu (Sayfa ilk açıldığında)
class AddEventInitial extends AddEventState {}

// 2. Yükleniyor Durumu (Kaydet butonuna basıldığında)
class AddEventLoading extends AddEventState {}

// 3. Başarılı Durumu (İşlem bittiğinde)
class AddEventSuccess extends AddEventState {}

// 4. Hata Durumu (Bir sorun oluştuğunda)
class AddEventError extends AddEventState {
  final String message;
  const AddEventError(this.message);

  @override
  List<Object?> get props => [message];
}
