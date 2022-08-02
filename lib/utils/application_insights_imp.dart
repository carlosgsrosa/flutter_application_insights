import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:http/http.dart' show Client;

import 'all.dart';

enum TrackType {
  trackError,
  trackEvent,
  trackPageView,
  trackTrace,
  trackTraceHttp
}

class ApplicationInsightsImp extends ApplicationInsights {
  String key;

  ApplicationInsightsImp(this.key);

  Future<void> track(TrackType type,
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
      case TrackType.trackError:
        telemetryClient.trackError(
            severity: severity, error: error!, stackTrace: stackTrace);
        break;
      case TrackType.trackEvent:
        telemetryClient.trackEvent(name: name!);
        break;
      case TrackType.trackPageView:
        telemetryClient.trackPageView(name: name!);
        break;
      case TrackType.trackTrace:
        telemetryClient.trackTrace(severity: severity, message: message!);
        break;
      case TrackType.trackTraceHttp:
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
    await track(TrackType.trackError,
        severity: isFatal ? Severity.critical : Severity.error,
        error: error,
        stackTrace: stackTrace);
  }

  @override
  Future<void> trackEvent({required String name}) async {
    print("sending trackEvent ...");
    await track(
      TrackType.trackEvent,
      name: name,
    );
  }

  @override
  Future<void> trackPageView({required String name}) async {
    print("sending trackPageView ...");
    await track(
      TrackType.trackPageView,
      name: name,
    );
  }

  @override
  Future<void> trackTrace({required String message}) async {
    print("sending trackTrace ...");
    await track(
      TrackType.trackTrace,
      severity: Severity.information,
      message: message,
    );
  }

  @override
  Future<void> trackTraceHttp(String url,
      {Map<String, String>? headers}) async {
    print("sending trackTraceHttp ...");
    await track(TrackType.trackTraceHttp, url: url, headers: headers);
  }
}
