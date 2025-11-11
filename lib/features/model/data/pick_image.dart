import 'package:image_picker/image_picker.dart';

class PickImageClass {
  final ImagePicker imagePicker;
  PickImageClass({required this.imagePicker});
 

  //! pick image from gallery
  Future<String?> pickImage() async {
    final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }
}
