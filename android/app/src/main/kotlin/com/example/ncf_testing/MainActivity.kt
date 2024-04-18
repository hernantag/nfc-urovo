package com.example.ncf_testing

import android.device.PiccManager
import android.os.Handler
import android.util.Log
import im.nfc.flutter_nfc_kit.ByteUtils.toHexString
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.ToHex

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.macamedia.nfctest/piccmanager"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        val piccManager = PiccManager();

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
        })
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
            }
        }
    }
}


