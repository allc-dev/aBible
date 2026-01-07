import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerencia as compras no aplicativo (IAP) para a versão PRO.
///
/// Esta classe é um `ChangeNotifier` que encapsula a lógica de:
/// - Verificar a disponibilidade de compras.
/// - Carregar produtos da loja.
/// - Iniciar o fluxo de compra.
/// - Restaurar compras anteriores.
/// - Salvar e carregar o status da compra localmente.
class PurchaseService extends ChangeNotifier {
  /// O ID do produto para a versão PRO.
  static const String _kProVersionId = 'pro_bible';

  /// A chave usada para salvar o status da compra no `SharedPreferences`.
  static const String _kPurchaseStatusKey = 'pro_version_purchased';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  bool _isPurchasing = false;
  bool _isProVersion = false;
  List<ProductDetails> _products = [];
  String _purchaseError = '';

  /// Retorna `true` se a loja de aplicativos está disponível.
  bool get isAvailable => _isAvailable;

  /// Retorna `true` se um processo de compra está em andamento.
  bool get isPurchasing => _isPurchasing;

  /// Retorna `true` se o usuário adquiriu a versão PRO.
  bool get isProVersion => _isProVersion;

  /// A lista de produtos disponíveis para compra.
  List<ProductDetails> get products => _products;

  /// Uma mensagem de erro, se ocorrer algum problema durante a compra.
  String get purchaseError => _purchaseError;

  /// O ID do produto para a versão PRO.
  String get proVersionId => _kProVersionId;

  /// Cria uma nova instância de [PurchaseService] e inicia o processo de inicialização.
  PurchaseService() {
    _initialize();
  }

  /// Carrega o status da compra a partir do `SharedPreferences` de forma síncrona.
  ///
  /// Este método é útil para verificar o status da versão PRO no início do aplicativo,
  /// antes que a UI seja construída.
  Future<void> loadPurchaseStatusSync() async {
    final prefs = await SharedPreferences.getInstance();
    _isProVersion = prefs.getBool(_kPurchaseStatusKey) ?? false;
  }

  Future<void> _initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();

    if (_isAvailable) {
      final Stream<List<PurchaseDetails>> purchaseStream = _inAppPurchase.purchaseStream;
      _subscription = purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) => debugPrint('Purchase stream error: $error'),
      );

      await _loadProducts();
      await _restorePurchases();
    }

    // Garante status inicial do SharedPreferences
    await _loadPurchaseStatus();
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    if (!_isAvailable) return;
    const Set<String> ids = {_kProVersionId};
    final response = await _inAppPurchase.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Produtos não encontrados: ${response.notFoundIDs}');
    }
    _products = response.productDetails;
    notifyListeners();
  }

  Future<void> _loadPurchaseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isProVersion = prefs.getBool(_kPurchaseStatusKey) ?? _isProVersion;
  }

  Future<void> _savePurchaseStatus(bool isPro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPurchaseStatusKey, isPro);
    _isProVersion = isPro;
    notifyListeners();
  }

  ProductDetails? getProVersionProduct() {
    try {
      return _products.firstWhere((p) => p.id == _kProVersionId);
    } catch (_) {
      return null;
    }
  }

  Future<void> buyProVersion() async {
    if (!_isAvailable || _isPurchasing) return;

    final product = getProVersionProduct();
    if (product == null) {
      _purchaseError = 'Produto não encontrado';
      notifyListeners();
      return;
    }

    _isPurchasing = true;
    _purchaseError = '';
    notifyListeners();

    final param = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    await _restorePurchases();
  }

  Future<void> _restorePurchases() async {
    if (!_isAvailable) return;
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Erro ao restaurar compras: $e');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> list) {
    for (final details in list) {
      _handlePurchase(details);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails details) async {
    if (details.productID == _kProVersionId) {
      switch (details.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _savePurchaseStatus(true);
          _isPurchasing = false;
          _purchaseError = '';
          break;
        case PurchaseStatus.error:
          _isPurchasing = false;
          _purchaseError = details.error?.message ?? 'Erro na compra';
          await _savePurchaseStatus(false);
          break;
        case PurchaseStatus.pending:
          _isPurchasing = true;
          _purchaseError = '';
          break;
        case PurchaseStatus.canceled:
          _isPurchasing = false;
          _purchaseError = '';
          break;
      }
    }

    if (details.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(details);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// iOS-specific StoreKit delegate removido para build Android-only.
