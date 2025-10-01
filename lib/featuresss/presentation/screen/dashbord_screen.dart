import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minilauncher/core/common/custom_appbar.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/themes/app_colors.dart';

class DashbordScreen extends StatelessWidget {
  const DashbordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
    
        return Scaffold(
          appBar: CustomAppBar(
            isTitle: true,
            title: 'Application Management',
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.help_outline, color: AppPalette.greyColor),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: width * .05),
            child: Column(
              children: [
                ConstantWidgets.hight20(context),
                ElevatedButton(
                  onPressed: () {
                    context.push('/lanch_screen');
                  },
                  child: Text('App Management'),
                ),
                ElevatedButton(
                  onPressed: () {

                  },
                  child: Text('Wallpepar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
