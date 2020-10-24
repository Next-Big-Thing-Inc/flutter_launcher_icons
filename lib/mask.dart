// ignore: deprecated_member_use
import 'package:resource/resource.dart';

enum Mask{
  androidSquare,
  ios
}

const Map<Mask, Resource> _MASK_RESOURCES = {
  Mask.androidSquare: Resource('package:flutter_launcher_icons/assets/mask_android_square.png'),
  Mask.ios: Resource('package:flutter_launcher_icons/assets/mask_ios.png')
};

extension MaskResource on Mask {
  Resource get resource{
    return _MASK_RESOURCES[this];
  }
}