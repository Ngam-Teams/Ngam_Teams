import 'release_fetcher_stub.dart'
    if (dart.library.html) 'release_fetcher_web.dart'
    if (dart.library.io) 'release_fetcher_io.dart';

abstract class ReleaseFetcher {
  static Future<String?> fetchUrl(String url) => fetchReleaseString(url);
}
