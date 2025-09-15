part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}
final class AppStarted extends AuthEvent {
  
}
final class CompleteWelcomeEvent extends AuthEvent {
  
}

final class CompletedInfo extends AuthEvent {
  String username;
  String password;
  CompletedInfo({required this.username, required this.password});//constructor
}

final class HostelLogin extends AuthEvent {
  
}
final class HostelLogout extends AuthEvent {
}

final class AcademicLogin extends AuthEvent {
  
}
final class AcademicLogout extends AuthEvent {
  
}

final class CheckStatus extends AuthEvent {
  
}

