import 'dart:html' as html;

Future<String?> fetchReleaseString(String url) async {
  try {
    final response = await html.HttpRequest.request(
      url,
      requestHeaders: {
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    if (response.status == 200) {
      return response.responseText;
    }
  } catch (_) {}
  return null;
}
