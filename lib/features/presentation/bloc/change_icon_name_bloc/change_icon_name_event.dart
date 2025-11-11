part of 'change_icon_name_bloc.dart';

abstract class ChangeIconNameEvent {}

final class SaveChangesEvent extends ChangeIconNameEvent {
  final String appPackageName;
  final String? newappName;
  final String? newappIcon;

   SaveChangesEvent({
    required this.appPackageName,
    this.newappName,
    this.newappIcon,
  });
}