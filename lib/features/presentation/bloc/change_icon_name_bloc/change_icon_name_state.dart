part of 'change_icon_name_bloc.dart';

abstract class ChangeIconNameState {}

final class ChangeIconNameInitial extends ChangeIconNameState {}

final class SaveChangesLoadingState extends ChangeIconNameState {}

final class SaveChangesSuccessState extends ChangeIconNameState {}

final class SaveChangesErrorState extends ChangeIconNameState {
  final String error;
  
 SaveChangesErrorState({required this.error});

}