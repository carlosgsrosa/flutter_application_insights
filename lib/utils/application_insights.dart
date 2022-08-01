abstract class ApplicationInsights {
  Future<void> trackTrace({required String message});

  Future<void> trackPageView({required String name});

  Future<void> trackEvent({required String name});

  Future<void> trackTraceHttp(String url, {Map<String, String> headers});

  Future<void> trackError(
      {bool isFatal = false, required Object error, StackTrace stackTrace});
}
