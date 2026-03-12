part of 'blocking_bloc.dart';

abstract class BlockingState extends Equatable {
  const BlockingState();
  @override
  List<Object?> get props => [];
}

class BlockingInitial extends BlockingState {}
class BlockingLoading extends BlockingState {}

class BlockingStatusLoaded extends BlockingState {
  final bool isVpnActive;
  final bool isAccessibilityActive;
  final List<String> localDomains;

  const BlockingStatusLoaded({
    required this.isVpnActive,
    required this.isAccessibilityActive,
    required this.localDomains,
  });

  @override
  List<Object?> get props => [isVpnActive, isAccessibilityActive, localDomains];
}

class BlockingError extends BlockingState {
  final String message;
  const BlockingError(this.message);
  @override
  List<Object?> get props => [message];
}
