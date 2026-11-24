import 'package:integration_test/integration_test_driver.dart';

/// Writes integration_test/perf_test.dart's frame timings to
/// `build/perf_summary.json`.
Future<void> main() => integrationDriver(
  responseDataCallback: (data) =>
      writeResponseData(data, testOutputFilename: 'perf_summary'),
);
