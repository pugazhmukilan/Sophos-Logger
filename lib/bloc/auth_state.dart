part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}
final class AuthAuthenticatedState extends AuthState {
  
}

final class AuthShowWelcomeState extends AuthState {
  
}
final class GetInfo extends AuthState {
  
}
final class InfoCompleted extends AuthState {
  
}
final class HosteLoggedIn extends AuthState {
  
}
final class HostelLoggedOut extends AuthState {}
final class AcademicLoggedIn extends AuthState {
  
}
final class AcademicLoggedOut extends AuthState {}

final class LoginFailed extends AuthState{
  final String message;
  LoginFailed({required this.message});
}

final class HostelAuthenticating extends AuthState{
  final String message;
  HostelAuthenticating({required this.message});
}
final class AcademicAuthenticating extends AuthState{
  final String message;
  AcademicAuthenticating({required this.message});
}
