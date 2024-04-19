import 'dart:typed_data';

import 'package:bitmap/bitmap.dart';

class ImpresionBitmap {
  ImpresionBitmap({
    required this.bitmap,
  });
  final Bitmap bitmap;

  Map toJson() {
    return {
      "height": bitmap.height,
      "width": bitmap.width,
      "bitmap_array":
          convertRGBAtoMonochrome(bitmap.content, bitmap.width, bitmap.height)
    };
  }
}

Uint8List convertRGBAtoMonochrome(Uint8List rgbaData, int width, int height) {
  // Verificar que el tamaño del Uint8List sea correcto para el tamaño del bitmap
  assert(rgbaData.length == width * height * 4); // 4 bytes por píxel (RGBA)

  // Crear un nuevo Uint8List para almacenar los datos en formato de 1 bit por píxel
  final monochromeData = Uint8List((width * height * 4));

  // Iterar sobre cada píxel en el bitmap RGBA

  for (var i = 0; i < rgbaData.length; i += 4) {
    /* if (i >= rgbaData.length - 5) {
      break;
    } */
    // Calcular el valor de luminancia (brillo) del píxel

    final double R = rgbaData[i] / 255.0;
    final double G = rgbaData[i + 1] / 255.0;
    final double B = rgbaData[i + 2] / 255.0;

    final luminance = 0.2126 * R + 0.7152 * G + 0.0722 * B;

    // Establecer el bit correspondiente en el Uint8List de 1 bit por píxel
    if (luminance < 0.5) {
      // Si el valor de luminancia es bajo, establecer el bit como 1 (negro)
      monochromeData[i] = 255;
      monochromeData[i + 1] = 0;
      monochromeData[i + 2] = 0;
      monochromeData[i + 3] = 0;
    } else {
      monochromeData[i] = 255;
      monochromeData[i + 1] = 255;
      monochromeData[i + 2] = 255;
      monochromeData[i + 3] = 255;
    }
  }

  return monochromeData;
}
