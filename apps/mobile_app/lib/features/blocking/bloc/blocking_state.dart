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
  final Map<String, bool> socialMediaSettings;

  const BlockingStatusLoaded({
    required this.isVpnActive,
    required this.isAccessibilityActive,
    required this.localDomains,
    this.socialMediaSettings = const {},
  });

  BlockingStatusLoaded copyWith({
    bool? isVpnActive,
    bool? isAccessibilityActive,
    List<String>? localDomains,
    Map<String, bool>? socialMediaSettings,
  }) {
    return BlockingStatusLoaded(
      isVpnActive: isVpnActive ?? this.isVpnActive,
      isAccessibilityActive: isAccessibilityActive ?? this.isAccessibilityActive,
      localDomains: localDomains ?? this.localDomains,
      socialMediaSettings: socialMediaSettings ?? this.socialMediaSettings,
    );
  }

  @override
  List<Object?> get props => [isVpnActive, isAccessibilityActive, localDomains, socialMediaSettings];
}

class BlockingError extends BlockingState {
  final String message;
  const BlockingError(this.message);
  @override
  List<Object?> get props => [message];
}
