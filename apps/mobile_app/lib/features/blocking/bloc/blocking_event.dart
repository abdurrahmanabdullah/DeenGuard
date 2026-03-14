part of 'blocking_bloc.dart';

abstract class BlockingEvent extends Equatable {
  const BlockingEvent();
  @override
  List<Object?> get props => [];
}

class LoadBlockingStatus extends BlockingEvent {}

class ToggleProtection extends BlockingEvent {
  final bool enabled;
  const ToggleProtection(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class SyncBlockedDomains extends BlockingEvent {}

class AddCustomDomain extends BlockingEvent {
  final String domain;
  const AddCustomDomain(this.domain);
  @override
  List<Object?> get props => [domain];
}

class RemoveCustomDomain extends BlockingEvent {
  final String domainId;
  const RemoveCustomDomain(this.domainId);
  @override
  List<Object?> get props => [domainId];
}
