import 'dart:io';
import 'package:flutter_launcher_icons/android.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:image/image.dart';
import 'custom_exceptions.dart';

import 'mask.dart';

Future<Image> createImageFromAdaptive(Map<String, dynamic> config, Mask mask, double zoom) async {
  final String foregroundImagePath = config['adaptive_icon_foreground'];
  final Image foregroundImage =
      decodeImage(File(foregroundImagePath).readAsBytesSync());
  final Image backgroundImage = _getBackgroundImage(config, foregroundImage);
  return _createImageFromAdaptive(backgroundImage, foregroundImage, mask, zoom);
}

Image _getBackgroundImage(Map<String, dynamic> config, Image foregroundImage){
  final String backgroundConfig = config['adaptive_icon_background'];
  if(isAdaptiveIconConfigPngFile(backgroundConfig)){
    return decodeImage(File(backgroundConfig).readAsBytesSync());
  } else {
    if(backgroundConfig.length != 7){
      throw const InvalidConfigException('background config has to start with a # followed by 6 hex digits');
    }
    final int color = parseHexColor(backgroundConfig);
    return monochromeImage(foregroundImage.width, foregroundImage.height, color);
  }
}

Future<Image> _createImageFromAdaptive(Image backgroundImage, Image foregroundImage, Mask mask, double zoom) async{
  if (backgroundImage.width != foregroundImage.width ||
      backgroundImage.height != foregroundImage.height) {
    throw const InvalidConfigException(
        'adaptive_icon_background and adaptive_icon_foreground image have to be same size');
  }
  Image image = Image(foregroundImage.width, foregroundImage.height);
  copyIntoWithOpacity(image, backgroundImage, blend: false);
  copyIntoWithOpacity(image, foregroundImage, blend: true);
  image = cropZoom(image, zoom);
  maskImage(image, decodeImage(await mask.resource.readAsBytes()));
  return image;
}


