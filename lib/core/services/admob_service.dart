import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  bool _isInterstitialLoaded = false;
  bool _isBannerLoaded = false;
  bool _isAdShowing = false;
  bool _isLoadingAd = false;

  // Test interstitial ad unit ID (use this during development)
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // Test banner ad unit ID (use this during development)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  // Production interstitial ad unit ID (replace with your actual AdMob ID before release)
  static const String _productionInterstitialAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';

  // Production banner ad unit ID (replace with your actual AdMob ID before release)
  static const String _productionBannerAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';

  // Current ad unit IDs (switch to production before release)
  static const String _interstitialAdUnitId = kDebugMode
      ? _testInterstitialAdUnitId
      : _productionInterstitialAdUnitId;

  static const String _bannerAdUnitId = kDebugMode
      ? _testBannerAdUnitId
      : _productionBannerAdUnitId;

  /// Initialize Mobile Ads SDK
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      debugPrint('AdMob initialized successfully');
    } catch (e) {
      debugPrint('AdMob initialization failed: $e');
    }
  }

  /// Load an interstitial ad
  Future<void> loadInterstitialAd() async {
    if (_isLoadingAd || _isInterstitialLoaded) {
      debugPrint('Interstitial ad already loading or loaded');
      return;
    }

    _isLoadingAd = true;
    debugPrint('Loading interstitial ad...');

    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('Interstitial ad loaded successfully');
            _interstitialAd = ad;
            _isInterstitialLoaded = true;
            _isLoadingAd = false;

            // Set full screen content callback
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (InterstitialAd ad) {
                debugPrint('Interstitial ad showed full screen content');
                _isAdShowing = true;
              },
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                debugPrint('Interstitial ad dismissed');
                _isAdShowing = false;
                _isInterstitialLoaded = false;
                ad.dispose();
                _interstitialAd = null;

                // Preload next ad after dismissal
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
                debugPrint('Interstitial ad failed to show: ${error.message}');
                _isAdShowing = false;
                _isInterstitialLoaded = false;
                ad.dispose();
                _interstitialAd = null;

                // Try loading another ad
                loadInterstitialAd();
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('Interstitial ad failed to load: ${error.message}');
            _isInterstitialLoaded = false;
            _isLoadingAd = false;
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
      _isLoadingAd = false;
    }
  }

  /// Show the interstitial ad if loaded
  /// Returns true if ad was shown, false otherwise
  Future<bool> showInterstitialAd() async {
    if (_isAdShowing) {
      debugPrint('Interstitial ad already showing, skipping');
      return false;
    }

    if (_interstitialAd == null || !_isInterstitialLoaded) {
      debugPrint('No interstitial ad loaded, showing action immediately');
      // Start loading in background for next time
      loadInterstitialAd();
      return false;
    }

    try {
      debugPrint('Showing interstitial ad');
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
      _isInterstitialLoaded = false;
      _interstitialAd = null;
      // Try loading another ad
      loadInterstitialAd();
      return false;
    }
  }

  /// Check if an interstitial ad is loaded and ready to show
  bool get isInterstitialLoaded => _isInterstitialLoaded;

  /// Check if a banner ad is loaded and ready to show
  bool get isBannerLoaded => _isBannerLoaded;

  /// Get the loaded banner ad widget
  Widget? getBannerAdWidget() {
    if (_bannerAd == null || !_isBannerLoaded) {
      return null;
    }
    return AdWidget(ad: _bannerAd!);
  }

  /// Load a banner ad
  Future<void> loadBannerAd() async {
    if (_isBannerLoaded) {
      debugPrint('Banner ad already loaded');
      return;
    }

    debugPrint('Loading banner ad...');

    try {
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            debugPrint('Banner ad loaded successfully');
            _isBannerLoaded = true;
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            debugPrint('Banner ad failed to load: ${error.message}');
            _isBannerLoaded = false;
            ad.dispose();
            _bannerAd = null;
          },
          onAdOpened: (Ad ad) {
            debugPrint('Banner ad opened');
          },
          onAdClosed: (Ad ad) {
            debugPrint('Banner ad closed');
          },
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
      _isBannerLoaded = false;
      _bannerAd = null;
    }
  }

  /// Dispose of the current interstitial ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialLoaded = false;
    _isAdShowing = false;
    _isLoadingAd = false;

    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }
}
