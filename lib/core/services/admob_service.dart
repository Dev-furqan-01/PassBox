import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService extends ChangeNotifier {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  InterstitialAd? _interstitialAd;
  final Map<String, BannerAd> _bannerAds = {};
  final Map<String, bool> _bannerLoaded = {};
  final Set<String> _bannerLoading = {};
  bool _isInterstitialLoaded = false;
  bool _isAdShowing = false;
  bool _isLoadingAd = false;

  // Banner slots
  static const String vaultBannerSlot = 'vault';
  static const String generateBannerSlot = 'generate';

  // Production ad unit IDs
  static const String _interstitialAdUnitId = 'ca-app-pub-4348379947126050/2436009846';
  static const String _vaultBannerAdUnitId = 'ca-app-pub-4348379947126050/1314499862';
  static const String _generateBannerAdUnitId = 'ca-app-pub-4348379947126050/7688336521';

  static String _bannerAdUnitIdFor(String slot) {
    switch (slot) {
      case generateBannerSlot:
        return _generateBannerAdUnitId;
      default:
        return _vaultBannerAdUnitId;
    }
  }

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
  bool isBannerLoaded([String slot = vaultBannerSlot]) =>
      _bannerLoaded[slot] ?? false;

  /// Get the loaded banner ad widget for a slot
  Widget? getBannerAdWidget([String slot = vaultBannerSlot]) {
    final ad = _bannerAds[slot];
    if (ad == null || !(_bannerLoaded[slot] ?? false)) {
      return null;
    }
    return AdWidget(ad: ad);
  }

  /// Load a banner ad for the given slot.
  /// Skips if the slot is already loaded (unless [force] is true) or a load
  /// is already in progress.
  Future<void> loadBannerAd({String slot = vaultBannerSlot, bool force = false}) async {
    if (_bannerLoading.contains(slot)) {
      debugPrint('Banner ad already loading for slot: $slot');
      return;
    }
    if (!force && (_bannerLoaded[slot] ?? false)) {
      return;
    }
    _bannerLoading.add(slot);

    // Dispose existing banner ad in this slot before loading a new one
    _bannerAds[slot]?.dispose();
    _bannerAds.remove(slot);
    _bannerLoaded[slot] = false;
    notifyListeners();

    debugPrint('Loading banner ad for slot: $slot');

    try {
      final ad = BannerAd(
        adUnitId: _bannerAdUnitIdFor(slot),
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            debugPrint('Banner ad loaded successfully ($slot)');
            _bannerLoaded[slot] = true;
            notifyListeners();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            debugPrint('Banner ad failed to load ($slot): ${error.message}');
            _bannerLoaded[slot] = false;
            ad.dispose();
            _bannerAds.remove(slot);
            notifyListeners();
          },
          onAdOpened: (Ad ad) {
            debugPrint('Banner ad opened ($slot)');
          },
          onAdClosed: (Ad ad) {
            debugPrint('Banner ad closed ($slot)');
          },
        ),
      );

      _bannerAds[slot] = ad;
      await ad.load();
    } catch (e) {
      debugPrint('Error loading banner ad ($slot): $e');
      _bannerLoaded[slot] = false;
      _bannerAds.remove(slot);
    } finally {
      _bannerLoading.remove(slot);
    }
  }

  /// Dispose of the current interstitial ad
  @override
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialLoaded = false;
    _isAdShowing = false;
    _isLoadingAd = false;

    for (final ad in _bannerAds.values) {
      ad.dispose();
    }
    _bannerAds.clear();
    _bannerLoaded.clear();
    super.dispose();
  }
}
