package com.example.ncf_testing

import android.R.attr.bitmap
import android.device.PiccManager
import android.device.PrinterManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Handler
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.ToHex
import org.json.JSONObject
import java.nio.ByteBuffer


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.macamedia.nfctest/piccmanager"


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {


        val piccManager = PiccManager();
        val printer = PrinterManager();

        val handler = Handler(Handler.Callback { msg ->
            // Manejar el mensaje recibido
            when (msg.what) {
                12 -> {

                    // Realizar alguna acción con los datos recibidos en el mensaje
                    val data = msg.obj as String
                    Log.println(Log.DEBUG, "Tag", "$data")
                    // Realizar alguna acción con los datos, como actualizar la interfaz de usuario
                }
                // Agregar otros casos según sea necesario
            }
            true
        });

        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            // This method is invoked on the main thread.
            when(call.method){
                "receiveImage" ->{
                    val imageData = call.argument<ByteArray>("imageData")
                    if (imageData != null) {
                        val bitmap = byteArrayToBitmap(imageData)
                        // Usa el bitmap como desees
                    }
                }
                "antisel"->{val cardType = ByteArray(2)

                    val atq = ByteArray(14)
                    val sak: Char = 1.toChar()
                    val sakByteArray = ByteArray(1)
                    sakByteArray[0] = sak.toByte()
                    val sn = ByteArray(10)
                    val scanCard = piccManager.request(cardType, atq)
                    if (scanCard > 0) {
                        val snLen = piccManager.antisel(sn, sakByteArray)
                        val msg = handler.obtainMessage(12)
                        msg.obj = ToHex().bytesToHexString(sn, snLen)
                        handler.sendMessage(msg)
                        result.success(msg.obj)
                    }
                }
                "printText"->{
                    if(printer.open() == 0){
                            val width = 384
                            val height = -1
                            val re: Int = printer.setupPage(width, height)
                            printer.drawText(call.arguments as String, 0,0,"simsun", 24,false, false, 0)
                            if (re == 0) {
                                try {
                                    printer.printPage(0)
                                }catch (e:Error){
                                    printer.clearPage()
                                }
                                printer.clearPage()
                                printer.paperFeed(16);
                                //setupPage failed
                        }
                    }
                }
                "printBitmap"->{
                    if(printer.open() == 0){
                        val width = 384
                        val height = -1
                        val re: Int = printer.setupPage(width, height)

                        val encodedBitmap = call.arguments as String;
                        val imageData = Base64.decode(encodedBitmap, Base64.DEFAULT)

                        val bitmap = BitmapFactory.decodeByteArray(imageData,0,imageData.size)

                        val aspectRatio = bitmap.height.toDouble() / bitmap.width.toDouble();
                        Log.println(Log.DEBUG,"alturas","${bitmap.height} - ${bitmap.width} - ${aspectRatio}")
                        val fixedHeight = (bitmap.height.toDouble() / aspectRatio).toInt();
                        val bitmapResized = Bitmap.createScaledBitmap(bitmap, 384, fixedHeight,false)

                        printer.drawBitmap(bitmapResized,0,0)
                        //printer.drawBitmapEx (imageData, 0,0, bitmap.width,bitmap.height)
                        if (re == 0) {
                            try {
                                printer.printPage(0)
                            }catch (e:Error){
                                printer.clearPage()
                            }
                            printer.clearPage()
                            printer.paperFeed(60)
                        }
                    }
                }
            }
        }
    }
}
private fun byteArrayToBitmap(byteArray: ByteArray): Bitmap {
    val buffer: ByteBuffer = ByteBuffer.wrap(byteArray)
    val bmp = Bitmap.createBitmap(40, 40, Bitmap.Config.ARGB_8888)
    bmp.copyPixelsFromBuffer(buffer)
    return bmp
}

fun invertirRGBAaARGB(rgbaData: ByteArray, width: Int, height: Int): ByteArray {
    // Verificar que el tamaño del ByteArray sea correcto para el tamaño del bitmap
    require(rgbaData.size == width * height * 4) { "El tamaño del ByteArray no coincide con el tamaño del bitmap RGBA" }

    // Crear un nuevo ByteArray para almacenar los datos en formato ARGB
    val inverted = ByteArray(width * height * 4)

    // Iterar sobre cada píxel en el bitmap RGBA
    var index = 0
    for (i in rgbaData.indices step 4) {
        inverted[index] = rgbaData[i + 3] // Alfa
        inverted[index + 1] = rgbaData[i] // Rojo
        inverted[index + 2] = rgbaData[i + 1] // Verde
        inverted[index + 3] = rgbaData[i + 2] // Azul
        index += 4
    }

    return inverted
}