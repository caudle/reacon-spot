part of 'theme_cubit.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

class ThemeLoading extends ThemeState {
  const ThemeLoading();
}

class ThemeLoaded extends ThemeState {
  const ThemeLoaded({required this.themeData, required this.name});
  final ThemeData themeData;
  final String name;

  @override
  List<Object> get props => [themeData, name];
}
