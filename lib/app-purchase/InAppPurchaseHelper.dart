import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:lottie/lottie.dart';
import 'package:sudoku/admob/adMobIntegration.dart';
import '../services/storage_service.dart';
import '../utils/game_routes.dart';
import 'consumable_store.dart';

final bool _kAutoConsume = Platform.isIOS || true;
bool isInAppPurchaseAvailable = false;
// MARK: Added to check if the store is available in main.dart
//   await InAppPurchaseHelper.checkStoreAvailability();

const String _kConsumableId = 'sudoku'; // Only one time purchase we are supporting
const String _kUpgradeId = 'sudoku_subscription';
const String _kSilverSubscriptionId = 'subscription_half_year';
const String _kGoldSubscriptionId = 'subscription_yearly';
const List<String> _kProductIds = <String>[
  // _kUpgradeId,
  // _kSilverSubscriptionId,
  // _kGoldSubscriptionId,
  _kConsumableId,
];
class InAppPurchangeScreen extends StatefulWidget {
  InAppPurchangeScreen({super.key});
  @override
  State<InAppPurchangeScreen> createState() => _MyAppState();
}

class InAppPurchaseHelper {
  static InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static Future<bool> isStoreAvailable() async {
    isInAppPurchaseAvailable = await _inAppPurchase.isAvailable();
    return isInAppPurchaseAvailable;
  }
  static reStorePurchase() async {
    await _inAppPurchase.restorePurchases();
  }
  static Future<void> checkStoreAvailability() async {
    isInAppPurchaseAvailable = await InAppPurchaseHelper.isStoreAvailable();
    await hasActivePlan();
    // Handling the in-app purchase pop up
    final storageService = await StorageService.initialize();
    storageService.saveAppIsOpened();
    final count = await storageService.getNumberOfAppOpenedCount();
    // after 5 th time opening app we will show the in-app purchase
    if (count % 10 == 0) {
      // show the in-app purchase dialog
      GameRoutes.goTo(GameRoutes.inAppPurchase,
          enableBack: true);
    }
  }
  static Future<bool> hasActivePlan() async {
    final purchased = await ConsumableStore.load();
    final isPaidUser = purchased.contains(_kConsumableId);
    shouldShowAdForThisUser = !isPaidUser;
    return isPaidUser;
  }
}

class _MyAppState extends State<InAppPurchangeScreen>
    with SingleTickerProviderStateMixin {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
          (List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () => _subscription.cancel(),
      onError: (Object error) {},
    );
    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
        _notFoundIds = <String>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (Platform.isIOS) {
      final iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final productDetailResponse =
    await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null ||
        productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = productDetailResponse.error?.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> stack = <Widget>[];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Lottie.asset('assets/animations/diwali-lantern.json', height: 150),
            const Text(
              '✨ Go Premium!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enjoy an ad-free experience to play Sudoku without any interruptions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildProductList(),
            const SizedBox(height: 16),
            _buildRestoreButton(),
            const SizedBox(height: 24),
          ],
        ),
      );
    } else {
      stack.add(Center(child: Text(_queryProductError!)));
    }

    if (_purchasePending) {
      stack.add(
        const Stack(
          children: <Widget>[
            Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(children: stack),
    );
  }

  Widget _buildProductList() {
    if (_loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (!_isAvailable) return const Card();

    final purchases = Map<String, PurchaseDetails>.fromEntries(
      _purchases.map((purchase) {
        if (purchase.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchase);
        }
        return MapEntry(purchase.productID, purchase);
      }),
    );

    return Column(
      children: _products.map((productDetails) {
        final previousPurchase = purchases[productDetails.id];
        planSelected() {
          late PurchaseParam purchaseParam;
          if (Platform.isAndroid) {
            final oldSubscription =
            _getOldSubscription(productDetails, purchases);
            purchaseParam = GooglePlayPurchaseParam(
              productDetails: productDetails,
              changeSubscriptionParam: oldSubscription != null
                  ? ChangeSubscriptionParam(
                oldPurchaseDetails: oldSubscription,
                replacementMode:
                ReplacementMode.withTimeProration,
              )
                  : null,
            );
          } else {
            purchaseParam =
                PurchaseParam(productDetails: productDetails);
          }

          if (productDetails.id == _kConsumableId) {
            _inAppPurchase.buyConsumable(
              purchaseParam: purchaseParam,
              autoConsume: _kAutoConsume,
            );
          } else {
            _inAppPurchase
                .buyNonConsumable(purchaseParam: purchaseParam);
          }
        }
        return
          Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 15, // You can adjust the elevation for shadow effect
            color: Colors.transparent, // Keeps the background transparent
            child: InkWell(
              onTap: () {
                planSelected();
                // You can add an onTap gesture here if you want the card to be clickable
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    productDetails.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    productDetails.description,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: previousPurchase != null && Platform.isIOS
                      ? IconButton(
                    onPressed: () => confirmPriceChange(context),
                    icon: const Icon(Icons.upgrade, color: Colors.white),
                  )
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      planSelected();
                    },
                    child: Text(productDetails.price),
                  ),
                ),
              ),
            ),
          );
      }).toList(),
    );
  }

  Widget _buildRestoreButton() {
    if (_loading) return Container();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: Alignment.center,
        child: TextButton(
          onPressed: () => _inAppPurchase.restorePurchases(),
          child: const Text('Restore Purchases'),
        ),
      ),
    );
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == _kConsumableId) {
      await ConsumableStore.save(purchaseDetails.purchaseID!);
      shouldShowAdForThisUser = false;
      final consumables = await ConsumableStore.load();
      setState(() {
        _purchasePending = false;
        _consumables = consumables;
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
  }

  void showPendingUI() => setState(() => _purchasePending = true);
  void handleError(IAPError error) => setState(() => _purchasePending = false);
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) => Future.value(true);
  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {}

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            unawaited(deliverProduct(purchaseDetails));
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid &&
            !_kAutoConsume &&
            purchaseDetails.productID == _kConsumableId) {
          final androidAddition = _inAppPurchase
              .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
          await androidAddition.consumePurchase(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> confirmPriceChange(BuildContext context) async {
    if (Platform.isIOS) {
      final iapStoreKitPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
      ProductDetails productDetails,
      Map<String, PurchaseDetails> purchases,
      ) {
    if (productDetails.id == _kSilverSubscriptionId &&
        purchases[_kGoldSubscriptionId] != null) {
      return purchases[_kGoldSubscriptionId]! as GooglePlayPurchaseDetails;
    } else if (productDetails.id == _kGoldSubscriptionId &&
        purchases[_kSilverSubscriptionId] != null) {
      return purchases[_kSilverSubscriptionId]! as GooglePlayPurchaseDetails;
    }
    return null;
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction,
      SKStorefrontWrapper storefront,
      ) => true;

  @override
  bool shouldShowPriceConsent() => false;
}