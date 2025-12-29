import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final int currentIndex;
  final bool isCompleted;

  const OnboardingState({
    this.currentIndex = 0,
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    int? currentIndex,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentIndex: currentIndex ?? this.currentIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [currentIndex, isCompleted];
}
