import 'dart:typed_data';

import 'package:image/image.dart';

Image createResizedImage(int iconSize, Image image) {
  if (image.width >= iconSize) {
    return copyResize(
      image,
      width: iconSize,
      height: iconSize,
      interpolation: Interpolation.average,
    );
  } else {
    return copyResize(
      image,
      width: iconSize,
      height: iconSize,
      interpolation: Interpolation.linear,
    );
  }
}

void printStatus(String message) {
  print('• $message');
}

String generateError(Exception e, String error) {
  return '\n✗ ERROR: ${(e).runtimeType.toString()} \n$error';
}

extension ImageUtils on Image {
  int getPixelOpacity(int x, int y) {
    return getPixel(x, y) >> 24;
  }

  /// with full opacity
  int getPixelColor(int x, int y) {
    return getPixel(x, y) | 0xFF000000;
  }

  /// not changes color
  void setOpacity(int x, int y, int opacity) {
    final int color = (getPixel(x, y) & 0x00FFFFFF) | (opacity << 24);
    setPixel(x, y, color);
  }
}/// format #RRGGBB
int parseHexColor(String string){
  string = string.replaceFirst('#', '');
  if(string.length != 6){
    throw ArgumentError("illegal string format");
  }
  string += 'ff';
  final int data = int.parse(string, radix: 16);
  final int reversedData = (Uint8List(4)
    ..buffer.asByteData().setInt32(0, data, Endian.big))
      .buffer.asInt32List()[0];
  return reversedData;
}

Image monochromeImage(int width, int height, int abgrColor){
  final Image image = Image(width, height);
  for (int y = 0; y < image.height; ++y) {
    for (int x = 0; x < image.width; ++x) {
      image.setPixel(x, y, abgrColor);
    }
  }
  return image;
}

/// 0 means image does not change
/// 1 means result image has half the size
/// image is zoomed on center
Image cropZoom(Image image, double zoom) {
  final Image newImage = Image(
      image.width ~/ (zoom + 1),
      image.height ~/ (zoom + 1));
  copyIntoWithOpacity(newImage, image,
      dstX: (newImage.width - image.width) ~/ 2,
      dstY: (newImage.height - image.width) ~/ 2);
  return newImage;
}

void maskImage(Image image, Image mask) {
  mask = copyResize(mask,
      width: image.width,
      height: image.height,
      interpolation: Interpolation.cubic);
  for (int y = 0; y < image.height; ++y) {
    for (int x = 0; x < image.width; ++x) {
      final int opacity = mask.getPixelOpacity(x, y);
      image.setOpacity(x, y, opacity);
    }
  }
}

/// fixed copyInto of std library
void copyIntoWithOpacity(Image dst, Image src,
    {int dstX,
      int dstY,
      int srcX,
      int srcY,
      int srcW,
      int srcH,
      bool blend = true}) {
  dstX ??= 0;
  dstY ??= 0;
  srcX ??= 0;
  srcY ??= 0;
  srcW ??= src.width;
  srcH ??= src.height;

  for (int y = 0; y < srcH; ++y) {
    for (int x = 0; x < srcW; ++x) {
      final int color = src.getPixelColor(srcX + x, srcY + y);
      final int opacity = src.getPixelOpacity(srcX + x, srcY + y);
      if (blend) {
        drawPixel(dst, dstX + x, dstY + y, color, opacity);
      } else {
        dst.setPixel(dstX + x, dstY + y, color);
      }
    }
  }
}