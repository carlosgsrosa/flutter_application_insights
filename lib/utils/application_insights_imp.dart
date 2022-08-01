import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:http/http.dart' show Client;

import 'all.dart';

class ApplicationInsightsImp extends ApplicationInsights {
  String key;

  ApplicationInsightsImp(this.key);

  Future<void> track(String type,
      {bool? isFatal,
      Object? error,
      StackTrace? stackTrace,
      Map<String, Object>? additionalProperties,
      Severity severity = Severity.error,
      String? name,
      DateTime? timestamp,
      String? message,
      Map<String, String>? headers,
      String? url}) async {
    final httpClient = Client();

    final processor = BufferedProcessor(
      next: TransmissionProcessor(
        instrumentationKey: key,
        httpClient: httpClient,
        timeout: const Duration(seconds: 10),
      ),
    );

    final telemetryClient = TelemetryClient(
      processor: processor,
    );

    telemetryClient.context
      ..properties['client_id'] = 'ME - CARLOS ROSA'
      ..properties['timestamp'] = DateTime.now().millisecondsSinceEpoch
      ..properties['environment'] = 'DEV';

    switch (type) {
      case "trackError":
        telemetryClient.trackError(
            severity: severity, error: error!, stackTrace: stackTrace);
        break;
      case "trackEvent":
        telemetryClient.trackEvent(name: name!);
        break;
      case "trackPageView":
        telemetryClient.trackPageView(name: name!);
        break;
      case "trackTrace":
        telemetryClient.trackTrace(severity: severity, message: message!);
        break;
      case "trackTraceHttp":
        final telemetryHttpClient = TelemetryHttpClient(
          telemetryClient: telemetryClient,
          inner: httpClient,
        );

        await telemetryHttpClient.get(Uri.parse(url!), headers: headers);
        await telemetryClient.flush();

        break;
      default:
    }
  }

  @override
  Future<void> trackError(
      {bool isFatal = false,
      required Object error,
      StackTrace? stackTrace}) async {
    print("sending trackError ...");
    await track("trackError",
        severity: isFatal ? Severity.critical : Severity.error,
        error: error,
        stackTrace: stackTrace);
  }

  @override
  Future<void> trackEvent({required String name}) async {
    print("sending trackEvent ...");
    await track(
      "trackEvent",
      name: name,
    );
  }

  @override
  Future<void> trackPageView({required String name}) async {
    print("sending trackPageView ...");
    await track(
      "trackPageView",
      name: name,
    );
  }

  @override
  Future<void> trackTrace({required String message}) async {
    print("sending trackTrace ...");
    await track(
      "trackTrace",
      severity: Severity.information,
      message: message,
    );
  }

  @override
  Future<void> trackTraceHttp(String url,
      {Map<String, String>? headers}) async {
    print("sending trackTraceHttp ...");
    await track("trackTraceHttp", url: url, headers: headers);
  }
}
