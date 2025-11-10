import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';
import 'package:minilauncher/features/view_model/cubit/screen_timer_cubit.dart';

class TimerPickerWidget extends StatelessWidget {
  const TimerPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScreenTimerCubit, ScreenTimerState>(
      builder: (context, state) {
        return ValueListenableBuilder(
          valueListenable: AppTextStyleNotifier.instance,
          builder: (context, _, __) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Hours Picker
                  Flexible(
                    child: _buildWheelPicker(
                      context: context,
                      itemCount: 24,
                      onSelectedItemChanged: (index) {
                        context.read<ScreenTimerCubit>().updateHours(index);
                      },
                      selectedIndex: state.hours,
                      suffix: 'hours',
                    ),
                  ),
                  
                  // Divider
                  Container(
                    width: 2,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  
                  // Minutes Picker
                  Flexible(
                    child: _buildWheelPicker(
                      context: context,
                      itemCount: 60,
                      onSelectedItemChanged: (index) {
                        context.read<ScreenTimerCubit>().updateMinutes(index);
                      },
                      selectedIndex: state.minutes,
                      suffix: 'min',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWheelPicker({
    required BuildContext context,
    required int itemCount,
    required ValueChanged<int> onSelectedItemChanged,
    required int selectedIndex,
    required String suffix,
  }) {
    return SizedBox(
      height: 350,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection indicator background
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // Wheel Picker
          CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: selectedIndex),
            itemExtent: 50,
            onSelectedItemChanged: onSelectedItemChanged,
            selectionOverlay: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            children: List<Widget>.generate(itemCount, (index) {
              return Center(
                child: ValueListenableBuilder(
                  valueListenable: AppFontSizeNotifier.instance,
                  builder: (context, _, __) {
                    return Text(
                      '$index $suffix',
                      style: GoogleFonts.getFont(
                        AppTextStyleNotifier.instance.fontFamily,
                        textStyle: TextStyle(
                          color: AppTextStyleNotifier.instance.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

