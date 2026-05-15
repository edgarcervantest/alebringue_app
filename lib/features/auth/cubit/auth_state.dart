part of "auth_cubit.dart";

sealed class AuthState {}

final class AuthUserInitial extends AuthState {}

final class AuthUserLoggedIn extends AuthState {
  final UserModel user;
  AuthUserLoggedIn(this.user);
}
