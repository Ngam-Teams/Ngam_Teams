import 'dart:convert';
import 'dart:io';

Future<String?> fetchReleaseString(String url) async {
  HttpClient? client;
  try {
    client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('User-Agent', 'NgamTeamsApp');
    request.headers.set('Accept', 'application/vnd.github.v3+json');
    final response = await request.close();
    if (response.statusCode == 200) {
      return await response.transform(utf8.decoder).join();
    }
  } catch (_) {
  } finally {
    client?.close();
  }
  return null;
}
