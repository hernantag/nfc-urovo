package com.example.ncf_testing
import android.device.PiccManager
import android.device.PrinterManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Handler
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
                        val jsonDecodificado = JSONObject(call.arguments as String);
                        val width = 384
                        val height = -1
                        val re: Int = printer.setupPage(width, height)

                        val bitmapArray = jsonDecodificado.getJSONArray("bitmap_array");
                        val intArray = IntArray(bitmapArray.length()) { bitmapArray.getInt(it) }

                        val byteArray = ByteArray(intArray.size)

                        for (i in intArray) {
                            byteArray[i] = intArray[i].toByte()
                        }

                        Log.println(Log.DEBUG, "json", "${jsonDecodificado.getJSONArray("bitmap_array").length()}")

                        val bmp = Bitmap.createBitmap(jsonDecodificado.getInt("width") , jsonDecodificado.getInt("height"), Bitmap.Config.ARGB_8888)
                        val buffer: ByteBuffer = ByteBuffer.wrap(byteArray)
                        Log.println(Log.DEBUG, "json", "${buffer.capacity()} - ${bmp.byteCount}")
                        bmp.copyPixelsFromBuffer(buffer)
                        Log.println(Log.DEBUG, "test", "test");

                        bmp.gey
                        printer.drawBitmap(bmp, 0,0)
                        if (re == 0) {
                            try {
                                printer.printPage(0)
                            }catch (e:Error){
                                printer.clearPage()
                            }
                            printer.clearPage()
                            printer.paperFeed(16)
                        }
                    }
                }
            }
        }
    }
}
