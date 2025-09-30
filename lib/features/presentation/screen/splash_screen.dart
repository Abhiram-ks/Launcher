import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/constant/app_images.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/presentation/bloc/splash_bloc/splash_bloc.dart';
import 'package:minilauncher/features/presentation/widget/splash_widget/splash_state_handle.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc()..add(SplashRequest()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, splashState) {
         splashStateHandle(context, splashState);
        },
        child: Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              AppImages.logo,
                              fit: BoxFit.contain,
                              height: 70,
                              width: 70,
                            ),
                            ConstantWidgets.hight10(context),
                            Text(
                              "PivotOS:",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppPalette.whiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                             Text(
                              "Minimalist launcher",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppPalette.whiteColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: AppPalette.greyColor,
                            color: AppPalette.orengeColor,
                          ),
                        ),
                        ConstantWidgets.width20(context),
                        Text(
                          "Loading...",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppPalette.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ConstantWidgets.hight30(context),
                    Text(
                      "Protect your flow, launch with confidence.",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppPalette.whiteColor,
                      ),
                    ), ConstantWidgets.hight30(context),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
