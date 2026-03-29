import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
        ),
      )
      ..loadRequest(Uri.parse(widget.gatewayUrl));
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
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closeAsCancelled,
          ),
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
