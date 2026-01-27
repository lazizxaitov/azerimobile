package com.azeri.app

import android.app.Application

class AzeriApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        try {
            val clazz = Class.forName("com.yandex.mapkit.MapKitFactory")
            val method = clazz.getMethod("setApiKey", String::class.java)
            method.invoke(null, "b47843c9-9d6c-4e80-910d-5e9142f30591")
        } catch (_: Throwable) {
        }
    }
}
