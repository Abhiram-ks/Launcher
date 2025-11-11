import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';

/// Reusable save button for priority app selection screen
class PrioritySaveButton extends StatelessWidget {
  final int selectedCount;
  final List<String> selectedPackages;
  final int maxSelectable;

  const PrioritySaveButton({
    super.key,
    required this.selectedCount,
    required this.selectedPackages,
    this.maxSelectable = 10,
  });

  @override
  Widget build(BuildContext context) {
    final bool canSave = selectedCount > 0 && selectedCount <= maxSelectable;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 55,
      child: FloatingActionButton.extended(
        backgroundColor: canSave
            ? AppTextStyleNotifier.instance.textColor
            : AppPalette.blackColor.withValues(alpha: 0.5),
        label: Text(
          _getButtonText(),
          style: GoogleFonts.getFont(
            AppTextStyleNotifier.instance.fontFamily,
            textStyle: TextStyle(
              fontWeight: AppTextStyleNotifier.instance.fontWeight,
              fontSize: AppFontSizeNotifier.instance.value,
            ),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        onPressed: canSave ? () => _handleSave(context) : null,
      ),
    );
  }

  String _getButtonText() {
    if (selectedCount == 0) {
      return 'Select at least one';
    } else if (selectedCount > maxSelectable) {
      return 'Max $maxSelectable apps allowed';
    } else {
      return 'Save';
    }
  }

  void _handleSave(BuildContext context) {
    context.read<RootBloc>().add(
      SavePriorityAppsEvent(packageNames: selectedPackages),
    );
  }
}

