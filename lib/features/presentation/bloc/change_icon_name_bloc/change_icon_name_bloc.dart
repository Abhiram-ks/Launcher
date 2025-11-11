import 'package:bloc/bloc.dart';
import 'package:minilauncher/features/model/data/app_customization_prefs.dart';

part 'change_icon_name_event.dart';
part 'change_icon_name_state.dart';

class ChangeIconNameBloc extends Bloc<ChangeIconNameEvent, ChangeIconNameState> {
  ChangeIconNameBloc() : super(ChangeIconNameInitial()) {
    on<SaveChangesEvent>(_onSaveChanges);
  }

  Future<void> _onSaveChanges(
    SaveChangesEvent event,
    Emitter<ChangeIconNameState> emit,
  ) async {
    // Check if there are any changes
    if (event.newappName == null && event.newappIcon == null) {
      emit(SaveChangesErrorState(error: 'No changes to save'));
      return;
    }

    emit(SaveChangesLoadingState());

    try {
      await AppCustomizationPrefs.instance.saveAppCustomization(
        appPackageName: event.appPackageName,
        newAppName: event.newappName,
        newAppIcon: event.newappIcon,
      );

      emit(SaveChangesSuccessState());
    } catch (e) {
      emit(SaveChangesErrorState(error: 'Failed to save changes: $e'));
    }
  }
}
