import 'dart:convert';

import 'package:bitmap/bitmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';

class Impresora {
  final MethodChannel channel =
      const MethodChannel("com.macamedia.nfctest/piccmanager");

  Future<void> imprimirImagen(Bitmap bitmap) async {
    try {
      final bitmapMono = Bitmap.fromHeadless(
          bitmap.width,
          bitmap.height,
          _convertRGBAtoMonochrome(
              bitmap.content, bitmap.width, bitmap.height));

      await channel.invokeMethod(
          "printBitmap", base64.encode(bitmap.buildHeaded()));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> imprimirPdf(PdfImageRendererPdf pdf) async {
    try {
      await pdf.open();
      await pdf.openPage(pageIndex: 0);

      // get the render size after the page is loaded
      final size = await pdf.getPageSize(pageIndex: 0);

      // get the actual image of the page
      final img = await pdf.renderPage(
        pageIndex: 0,
        x: 0,
        y: 0,
        width: size.width, // you can pass a custom size here to crop the image
        height:
            size.height, // you can pass a custom size here to crop the image
        scale: 1, // increase the scale for better quality (e.g. for zooming)
        background: Colors.white,
      );

      final Bitmap bitmapPdf = await Bitmap.fromProvider(MemoryImage(img!));

      await imprimirImagen(bitmapPdf);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> imprimirTexto(String text) async {
    try {
      await channel.invokeMethod("printText", text);
    } catch (e) {
      rethrow;
    }
  }

  Uint8List _convertRGBAtoMonochrome(
      Uint8List rgbaData, int width, int height) {
    // Verificar que el tamaño del Uint8List sea correcto para el tamaño del bitmap
    assert(rgbaData.length == (width * height * 4)); // 4 bytes por píxel (RGBA)

    // Crear un nuevo Uint8List para almacenar los datos en formato de 1 bit por píxel
    final monochromeData = Uint8List(((width * height * 4)));

    // Iterar sobre cada píxel en el bitmap RGBA

    for (var i = 0; i < rgbaData.length; i += 4) {
      final double R = rgbaData[i] / 255.0;
      final double G = rgbaData[i + 1] / 255.0;
      final double B = rgbaData[i + 2] / 255.0;

      final luminance = 0.2126 * R + 0.7152 * G + 0.0722 * B;

      // Establecer el bit correspondiente en el Uint8List de 1 bit por píxel
      if (luminance < 0.55) {
        // Si el valor de luminancia es bajo, establecer el bit como 1 (negro)
        monochromeData[i] = 0;
        monochromeData[i + 1] = 0;
        monochromeData[i + 2] = 0;
        monochromeData[i + 3] = 255;
      } else {
        monochromeData[i] = 255;
        monochromeData[i + 1] = 255;
        monochromeData[i + 2] = 255;
        monochromeData[i + 3] = 255;
      }
    }

    return monochromeData;
  }
}
