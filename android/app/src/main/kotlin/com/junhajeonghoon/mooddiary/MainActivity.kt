package com.junhajeonghoon.smooddiary

import android.view.LayoutInflater
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory


class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.plugins.add(GoogleMobileAdsPlugin())
        super.configureFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine,
                "adFactoryExample",
                NativeAdFactoryExample(layoutInflater))
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "adFactoryExample")
    }
}

class NativeAdFactoryExample : NativeAdFactory {
    private var layoutInflater: LayoutInflater

    constructor(layoutInflater: LayoutInflater) {
        this.layoutInflater = layoutInflater
    }

    override fun createNativeAd(nativeAd: NativeAd?, customOptions: MutableMap<String, Any>?): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.my_native_ad, null) as NativeAdView


        adView.headlineView = adView.findViewById(R.id.ad_headline)


        (adView.headlineView as TextView).text = nativeAd?.headline
        adView.mediaView?.mediaContent = nativeAd?.mediaContent

        if (nativeAd != null) {
            adView.setNativeAd(nativeAd)
        }

        return adView
    }
}
