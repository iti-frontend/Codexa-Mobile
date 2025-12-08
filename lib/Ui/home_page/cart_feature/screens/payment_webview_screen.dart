import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:codexa_mobile/localization/localization_service.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

/// Result returned from the PaymentWebViewScreen
class PaymentWebViewResult {
  final bool success;
  final String? sessionId;
  final bool cancelled;

  PaymentWebViewResult({
    required this.success,
    this.sessionId,
    this.cancelled = false,
  });

  factory PaymentWebViewResult.success(String sessionId) {
    return PaymentWebViewResult(success: true, sessionId: sessionId);
  }

  factory PaymentWebViewResult.cancelled() {
    return PaymentWebViewResult(success: false, cancelled: true);
  }

  factory PaymentWebViewResult.failed() {
    return PaymentWebViewResult(success: false, cancelled: false);
  }
}

/// WebView screen for Stripe Checkout
///
/// Opens the Stripe checkout URL and monitors for success/cancel redirects
class PaymentWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String sessionId;

  const PaymentWebViewScreen({
    Key? key,
    required this.checkoutUrl,
    required this.sessionId,
  }) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0.0;

  late LocalizationService _localizationService;
  late generated.S _translations;

  @override
  void initState() {
    super.initState();
    _initializeLocalization();
    _initializeWebView();
  }

  void _initializeLocalization() {
    _localizationService = LocalizationService();
    _translations = generated.S(_localizationService.locale);
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
              if (progress == 100) {
                _isLoading = false;
              }
            });
          },
          onPageStarted: (String url) {
            print('🌐 [PAYMENT_WEBVIEW] Page started: $url');
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            print('✅ [PAYMENT_WEBVIEW] Page finished: $url');
            setState(() => _isLoading = false);
            _checkUrlForPaymentResult(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🔗 [PAYMENT_WEBVIEW] Navigation request: ${request.url}');

            // Check if this is a success or cancel redirect
            if (_isSuccessUrl(request.url)) {
              print('✅ [PAYMENT_WEBVIEW] Success URL detected!');
              _handleSuccess();
              return NavigationDecision.prevent;
            }

            if (_isCancelUrl(request.url)) {
              print('🚫 [PAYMENT_WEBVIEW] Cancel URL detected!');
              _handleCancel();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ [PAYMENT_WEBVIEW] Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  /// Check if URL indicates successful payment
  bool _isSuccessUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('success') ||
        lowerUrl.contains('payment_intent=succeeded') ||
        lowerUrl.contains('redirect_status=succeeded') ||
        lowerUrl.contains('/success');
  }

  /// Check if URL indicates cancelled payment
  bool _isCancelUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('cancel') ||
        lowerUrl.contains('canceled') ||
        lowerUrl.contains('/cancel');
  }

  /// Check current URL for payment result
  void _checkUrlForPaymentResult(String url) {
    if (_isSuccessUrl(url)) {
      _handleSuccess();
    } else if (_isCancelUrl(url)) {
      _handleCancel();
    }
  }

  /// Handle successful payment
  void _handleSuccess() {
    print('✅ [PAYMENT_WEBVIEW] Payment success detected, returning result');
    Navigator.of(context).pop(PaymentWebViewResult.success(widget.sessionId));
  }

  /// Handle cancelled payment
  void _handleCancel() {
    print('🚫 [PAYMENT_WEBVIEW] Payment cancelled, returning result');
    Navigator.of(context).pop(PaymentWebViewResult.cancelled());
  }

  /// Show cancel confirmation dialog
  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_translations.cancelPayment),
        content: Text(_translations.cancelPaymentConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_translations.no),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_translations.yes),
          ),
        ],
      ),
    );

    if (shouldPop == true) {
      _handleCancel();
    }

    return false; // We handle the pop ourselves
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = _localizationService.isRTL();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_translations.securePayment),
            backgroundColor:
                theme.appBarTheme.backgroundColor ?? theme.cardColor,
            foregroundColor:
                theme.appBarTheme.foregroundColor ?? theme.iconTheme.color,
            leading: IconButton(
              icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back),
              onPressed: () => _onWillPop(),
            ),
            bottom: _isLoading
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(4),
                    child: LinearProgressIndicator(
                      value: _loadingProgress,
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.progressIndicatorTheme.color ??
                            theme.primaryColor,
                      ),
                    ),
                  )
                : null,
          ),
          body: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading && _loadingProgress < 0.1)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.progressIndicatorTheme.color ??
                              theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _translations.loadingPaymentPage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.iconTheme.color,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
