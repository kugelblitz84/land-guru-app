import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'dart:async';
import '../../../core/services/api_client.dart';
import '../model/payment_models.dart';

export '../model/payment_models.dart';

class PaymentServices extends GetxService {
  PaymentServices(this._apiClient);

  final ApiClient _apiClient;

  Future<SslCommerzSession> createSslCommerzSession({
    required String postId,
  }) async {
    final response = await _apiClient.post(
      '/sell-posts/$postId/quote-payment/session',
    );

    return SslCommerzSession.fromPayload(response.data);
  }

  Future<PaymentGatewayResult> openPaymentGateway(String gatewayUrl) async {
    if (gatewayUrl.trim().isEmpty) {
      return const PaymentGatewayResult(status: PaymentGatewayStatus.failed);
    }

    final result = await Get.to<PaymentGatewayResult>(
      () => PaymentGatewayWebViewPage(gatewayUrl: gatewayUrl),
      fullscreenDialog: true,
      preventDuplicates: false,
    );

    return result ??
        const PaymentGatewayResult(status: PaymentGatewayStatus.cancelled);
  }

  Future<PaymentSessionValidation> validatePaymentSession({
    required String postId,
  }) async {
    final response = await _apiClient.get(
      '/sell-posts/$postId/quote-payment/session',
    );

    return PaymentSessionValidation.fromPayload(response.data);
  }
}

class PaymentGatewayWebViewPage extends StatefulWidget {
  const PaymentGatewayWebViewPage({super.key, required this.gatewayUrl});

  final String gatewayUrl;

  @override
  State<PaymentGatewayWebViewPage> createState() =>
      _PaymentGatewayWebViewPageState();
}

class _PaymentGatewayWebViewPageState extends State<PaymentGatewayWebViewPage> {
  late final WebViewController _controller;
  bool _isHandled = false;
  bool _isLoading = true;
  String? _pageError;
  static const String _androidPaymentUserAgent =
      'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final status = _resolveStatusFromUrl(request.url);
            if (status == null) {
              return NavigationDecision.navigate;
            }

            _complete(status, request.url);
            return NavigationDecision.prevent;
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _pageError = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            final isMainFrame = error.isForMainFrame ?? true;
            if (!isMainFrame || !mounted) return;
            setState(() {
              _isLoading = false;
              _pageError = error.description;
            });
          },
        ),
      );

    _controller = controller;

    try {
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();

      if (controller.platform is AndroidWebViewController) {
        final androidController =
            controller.platform as AndroidWebViewController;

        AndroidWebViewController.enableDebugging(true);
        await androidController.setMixedContentMode(
          MixedContentMode.alwaysAllow,
        );
        await androidController.setMediaPlaybackRequiresUserGesture(false);
        await controller.setUserAgent(_androidPaymentUserAgent);

        final platformCookieManager = cookieManager.platform;
        if (platformCookieManager is AndroidWebViewCookieManager) {
          await platformCookieManager.setAcceptThirdPartyCookies(
            androidController,
            true,
          );
        }
      }

      await controller.loadRequest(Uri.parse(widget.gatewayUrl));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _pageError = error.toString();
      });
    }
  }

  PaymentGatewayStatus? _resolveStatusFromUrl(String url) {
    final normalized = url.toLowerCase();

    if (normalized.contains('success')) {
      return PaymentGatewayStatus.success;
    }
    if (normalized.contains('fail') || normalized.contains('failed')) {
      return PaymentGatewayStatus.failed;
    }
    if (normalized.contains('cancel') || normalized.contains('cancelled')) {
      return PaymentGatewayStatus.cancelled;
    }

    return null;
  }

  void _complete(PaymentGatewayStatus status, String url) {
    if (_isHandled) return;
    _isHandled = true;

    Get.back(
      result: PaymentGatewayResult(status: status, redirectedUrl: url),
    );
  }

  void _closeAsCancelled() {
    if (_isHandled) return;
    _isHandled = true;
    Get.back(
      result: const PaymentGatewayResult(
        status: PaymentGatewayStatus.cancelled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closeAsCancelled();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Payment'),
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              tooltip: 'Open in browser',
              onPressed: _openInExternalBrowser,
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closeAsCancelled,
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_pageError != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load payment page.\\n$_pageError',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _pageError = null;
                          });
                          _controller.loadRequest(Uri.parse(widget.gatewayUrl));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInExternalBrowser() async {
    final uri = Uri.tryParse(widget.gatewayUrl);
    if (uri == null) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened || !mounted) return;

    final action = await showModalBottomSheet<_ExternalPaymentAction>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Payment opened in browser',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'After completing payment in the browser, come back and tap "I have completed payment".',
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(_ExternalPaymentAction.completed);
                  },
                  child: const Text('I have completed payment'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(_ExternalPaymentAction.cancelled);
                  },
                  child: const Text('Cancel payment'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == _ExternalPaymentAction.completed) {
      _complete(PaymentGatewayStatus.success, widget.gatewayUrl);
      return;
    }

    _closeAsCancelled();
  }
}

enum _ExternalPaymentAction { completed, cancelled }
