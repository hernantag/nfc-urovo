import 'dart:convert';

import 'package:bitmap/bitmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ncf_testing/models/impresion_bitmap_model/impresion_bitmap.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';

class Impresora {
  final MethodChannel channel =
      const MethodChannel("com.macamedia.nfctest/piccmanager");

  Future<void> imprimirImagen(Bitmap bitmap) async {
    try {
      final Map parsedJson = ImpresionBitmap(bitmap: bitmap).toJson();

      await channel.invokeMethod("printBitmap", jsonEncode(parsedJson));
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
}
