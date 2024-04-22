import 'dart:io';

import 'package:bitmap/bitmap.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
      builder: EasyLoading.init(),
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
  Bitmap? muestra;
  final MethodChannel channel =
      const MethodChannel("com.macamedia.nfctest/piccmanager");
  final Impresora impresora = Impresora();

  void imprimirPdf() async {
    try {
      final Dio dio = Dio();

      final Directory tempDir = await getTemporaryDirectory();
      final String path = "${tempDir.path}/ult-ticket.pdf";

      /* final respuesta = await dio.download(
          "https://elblogdehiara.wordpress.com/wp-content/uploads/2015/01/interpretar-un-ticket-de-la-compra.pdf",
          path); */

      /* File(path).writeAsBytesSync(respuesta.data); */

      final bytes = await rootBundle.load("assets/doc.pdf");

      final buffer = bytes.buffer;
      await File(path).writeAsBytes(
          buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));

      await impresora.imprimirPdf(PdfImageRendererPdf(path: path));
    } on DioException catch (e) {
      if (e.response?.statusCode == null) {
        EasyLoading.showToast("Fallo en la conexión");
      }
      rethrow;
    } catch (e) {
      EasyLoading.showToast("Ocurrio un error ${e}");
      rethrow;
    }
  }

  Future<void> imprimirBitmap() async {
    try {
      final Bitmap bitmap =
          await Bitmap.fromProvider(AssetImage("assets/doblaje2.jpg"));

      muestra = bitmap;
      setState(() {});

      await Impresora().imprimirImagen(bitmap);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> imprimirTexto(String texto) async {
    impresora.imprimirTexto(
        "TICKET MACAMEDIA!!!!!!!\nBuenas este es un ticketazo\n1000peso");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Titulo"),
      ),
      body: Column(
        children: [
          Text(valor ?? "No escaneamos nada auna"),
          ElevatedButton(
              onPressed: () async {
                final respuesta = await channel.invokeMethod("antisel");
                valor = respuesta;
                setState(() {});
              },
              child: Text("ESCANEAR TAG")),
          if (muestra != null) Image.memory(muestra!.buildHeaded()),
          ElevatedButton(
              onPressed: imprimirBitmap, child: const Text("print bitmap")),
          ElevatedButton(
              onPressed: () => imprimirTexto("Holitas"),
              child: Text("print texto")),
          ElevatedButton(onPressed: imprimirPdf, child: Text("print pdf")),
        ],
      ),
    );
  }
}
