import 'dart:io';
import 'dart:typed_data';

import 'package:bitmap/bitmap.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:ncf_testing/models/impresora_model/impresora.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  String? valor;

  final MethodChannel channel =
      MethodChannel("com.macamedia.nfctest/piccmanager");
  final Impresora impresora = Impresora();

  void imprimirPdf() async {
    try {
      final Dio dio = Dio();

      final Directory tempDir = await getTemporaryDirectory();
      final String path = "${tempDir.path}/ult-ticket.pdf";

      final respuesta =
          await dio.download("https://pdfobject.com/pdf/sample.pdf", path);

      await impresora.imprimirPdf(PdfImageRendererPdf(path: path));

      print(respuesta);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Titulo"),
      ),
      body: Column(
        children: [
          Text(valor ?? "No escaneamos nada aun"),
          ElevatedButton(
              onPressed: () async {
                final respuesta = await channel.invokeMethod("antisel");
                valor = respuesta;
                setState(() {});
              },
              child: Text("ESCANEAR TAG")),
          ElevatedButton(
              onPressed: () async {
                Bitmap bitmap = await Bitmap.fromProvider(AssetImage(
                  "assets/doblaje.jpg",
                ));
                final respuesta = impresora.imprimirImagen(bitmap);
              },
              child: Text("print bitmap")),
          ElevatedButton(
              onPressed: () async {
                final respuesta = impresora.imprimirTexto(
                    "TICKET MACAMEDIA!!!!!!!\nBuenas este es un ticketazo\n1000peso");
              },
              child: Text("print texto")),
          ElevatedButton(onPressed: imprimirPdf, child: Text("print pdf")),
        ],
      ),
    );
  }
}
