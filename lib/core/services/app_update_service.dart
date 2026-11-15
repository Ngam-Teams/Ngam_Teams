import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_translations.dart';
import 'pwa_reloader.dart';
import 'release_fetcher/release_fetcher.dart';
import '../../widgets/glass_toast.dart';

class AppReleaseInfo {
  final String version;
  final String title;
  final String changelog;
  final String downloadUrl;
  final String releaseUrl;
  final DateTime? publishedAt;
  final bool isWebReloadReady;

  AppReleaseInfo({
    required this.version,
    required this.title,
    required this.changelog,
    required this.downloadUrl,
    required this.releaseUrl,
    this.publishedAt,
    this.isWebReloadReady = false,
  });
}

class AppUpdateService {
  static const String fallbackVersion = '0.1.20';
  static String? _cachedVersion;
  static bool _startupDialogShown = false;

  static final ValueNotifier<String> versionNotifier = ValueNotifier<String>(fallbackVersion);
  static final ValueNotifier<AppReleaseInfo?> availableUpdateNotifier = ValueNotifier<AppReleaseInfo?>(null);

  static String get currentVersion => _cachedVersion ?? fallbackVersion;

  static const String appName = 'Ngam Teams';
  static const String repoName = 'Ngam_Teams';
  static const String orgName = 'Ngam-Teams';

  /// Get active installed app version dynamically from platform
  static Future<String> getAppVersion() async {
    if (_cachedVersion != null && _cachedVersion!.isNotEmpty) {
      return _cachedVersion!;
    }
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        _cachedVersion = info.version;
        versionNotifier.value = _cachedVersion!;
        return _cachedVersion!;
      }
    } catch (e) {
      debugPrint('[AppUpdateService] Error fetching package version: $e');
    }
    versionNotifier.value = fallbackVersion;
    return fallbackVersion;
  }

  /// Compare semantic versions (e.g. "0.1.20" vs "0.1.19")
  static bool isNewerVersion(String remote, String current) {
    try {
      final cleanRemote = remote.replaceAll(RegExp(r'[^0-9.]'), '');
      final cleanCurrent = current.replaceAll(RegExp(r'[^0-9.]'), '');

      final rParts = cleanRemote.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final cParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLen = rParts.length > cParts.length ? rParts.length : cParts.length;
      while (rParts.length < maxLen) {
        rParts.add(0);
      }
      while (cParts.length < maxLen) {
        cParts.add(0);
      }

      for (int i = 0; i < maxLen; i++) {
        if (rParts[i] > cParts[i]) return true;
        if (rParts[i] < cParts[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Fetch live deployed Web / PWA version from root /version.json
  static Future<String?> _fetchWebLiveVersion() async {
    if (!kIsWeb) return null;
    try {
      final url = Uri.base.resolve('/version.json?t=${DateTime.now().millisecondsSinceEpoch}').toString();
      final body = await ReleaseFetcher.fetchUrl(url).timeout(const Duration(seconds: 6));
      if (body != null && body.isNotEmpty) {
        final decoded = json.decode(body);
        if (decoded is Map && decoded['version'] != null) {
          final ver = decoded['version'].toString().trim();
          if (ver.isNotEmpty) return ver;
        }
      }
    } catch (e) {
      debugPrint('[AppUpdateService] Error fetching web /version.json: $e');
    }
    return null;
  }

  /// Check live Web /version.json and GitHub Releases API for latest update
  static Future<AppReleaseInfo?> checkForUpdate({
    String? current,
    String repo = repoName,
  }) async {
    try {
      final activeVersion = current ?? await getAppVersion();

      final futures = await Future.wait([
        (kIsWeb && repo == repoName) ? _fetchWebLiveVersion() : Future<String?>.value(null),
        _fetchGitHubRelease(repo),
      ]);

      final webVersion = futures[0] as String?;
      final ghRelease = futures[1] as AppReleaseInfo?;

      final bool hasWebNewer = webVersion != null && isNewerVersion(webVersion, activeVersion);
      final bool hasGhNewer = ghRelease != null && isNewerVersion(ghRelease.version, activeVersion);

      AppReleaseInfo? result;
      if (hasWebNewer) {
        final bool sameOrNewerFromWeb =
            ghRelease != null && !isNewerVersion(ghRelease.version, webVersion);
        result = AppReleaseInfo(
          version: webVersion,
          title: sameOrNewerFromWeb ? ghRelease.title : '$appName v$webVersion',
          changelog: sameOrNewerFromWeb ? ghRelease.changelog : '',
          downloadUrl: ghRelease?.downloadUrl ?? 'https://github.com/$orgName/$repo/releases',
          releaseUrl: ghRelease?.releaseUrl ?? 'https://github.com/$orgName/$repo/releases',
          publishedAt: ghRelease?.publishedAt,
          isWebReloadReady: true,
        );
      } else if (hasGhNewer) {
        result = AppReleaseInfo(
          version: ghRelease.version,
          title: ghRelease.title,
          changelog: ghRelease.changelog,
          downloadUrl: ghRelease.downloadUrl,
          releaseUrl: ghRelease.releaseUrl,
          publishedAt: ghRelease.publishedAt,
          isWebReloadReady: false,
        );
      }

      if (repo == repoName) {
        availableUpdateNotifier.value = result;
      }
      return result;
    } catch (e) {
      debugPrint('[AppUpdateService] Error checking for update: $e');
      return null;
    }
  }

  static Future<AppReleaseInfo?> _fetchGitHubRelease(String repo) async {
    try {
      final url = 'https://api.github.com/repos/$orgName/$repo/releases/latest';
      final body = await ReleaseFetcher.fetchUrl(url).timeout(const Duration(seconds: 10));
      if (body == null || body.isEmpty) {
        return null;
      }

      final data = json.decode(body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      final releaseName = data['name'] as String? ?? tagName;
      final changelog = data['body'] as String? ?? '';
      final htmlUrl = data['html_url'] as String? ?? 'https://github.com/$orgName/$repo/releases';

      final publishedStr = data['published_at'] as String?;
      DateTime? publishedAt;
      if (publishedStr != null) {
        publishedAt = DateTime.tryParse(publishedStr);
      }

      String downloadUrl = htmlUrl;
      final assets = data['assets'] as List<dynamic>? ?? [];
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.apk')) {
          downloadUrl = asset['browser_download_url'] as String? ?? downloadUrl;
          break;
        }
      }

      final remoteVersion = tagName.replaceFirst('v', '').trim();
      if (remoteVersion.isEmpty) return null;

      return AppReleaseInfo(
        version: remoteVersion,
        title: releaseName,
        changelog: changelog,
        downloadUrl: downloadUrl,
        releaseUrl: htmlUrl,
        publishedAt: publishedAt,
      );
    } catch (e) {
      debugPrint('[AppUpdateService] GitHub release lookup error: $e');
      return null;
    }
  }

  /// Launch download URL
  static Future<void> launchDownload(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Show gorgeous modern glassmorphic dialog when an update is found
  static Future<void> showUpdateDialog(
    BuildContext context,
    AppReleaseInfo update, {
    String? current,
  }) async {
    final activeCurrent = current ?? await getAppVersion();
    if (!context.mounted) return;

    final String titleTxt = context.tr('update.available_title');
    final String subTxt = kIsWeb && update.isWebReloadReady
        ? context.tr('update.web_ready_sub')
        : context.tr('update.ready_sub');
    final String curVerTxt = context.tr('update.current_ver').replaceAll('{v}', activeCurrent);
    final String viewReleaseTxt = context.tr('update.view_release');
    final String descTxt = (kIsWeb ? context.tr('update.desc_web') : context.tr('update.desc_mobile'))
        .replaceAll('{app}', appName)
        .replaceAll('{v}', update.version);
    final String changelogTxt = update.changelog.trim().isNotEmpty
        ? update.changelog.trim()
        : context.tr('update.fallback_changelog');
    final String laterTxt = context.tr('update.later');
    final String actionTxt = kIsWeb ? context.tr('update.reload_now') : context.tr('update.update_now');
    final String reloadingTxt = context.tr('update.reloading_web');

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E293B).withValues(alpha: 0.85),
                      const Color(0xFF0F172A).withValues(alpha: 0.92),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top header with glowing rocket icon & title
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF38BDF8),
                                Color(0xFF0284C7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titleTxt,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subTxt,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Version Pill Badge (Glass) + optional Release Info button on Web
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                curVerTxt,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Color(0xFF38BDF8),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'v${update.version}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7DD3FC),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (kIsWeb && update.releaseUrl.isNotEmpty)
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => launchDownload(update.releaseUrl),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.open_in_new_rounded, size: 13, color: Color(0xFF7DD3FC)),
                                  const SizedBox(width: 5),
                                  Text(
                                    viewReleaseTxt,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7DD3FC),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Description
                    Text(
                      descTxt,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.78),
                        height: 1.45,
                      ),
                    ),

                    // Changelog Box
                    if (changelogTxt.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            changelogTxt,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.65),
                              fontFamily: 'monospace',
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                            ),
                            child: Text(
                              laterTxt,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                if (kIsWeb) {
                                  if (context.mounted) {
                                    showGlassToast(
                                      context,
                                      reloadingTxt,
                                      type: GlassToastType.info,
                                      color: const Color(0xFF38BDF8),
                                    );
                                  }
                                  reloadWebPwa(update.version);
                                } else {
                                  launchDownload(update.downloadUrl);
                                }
                              },
                              icon: Icon(
                                kIsWeb ? Icons.refresh_rounded : Icons.download_rounded,
                                size: 18,
                              ),
                              label: Text(actionTxt),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Automatically check on app startup and prompt if newer release is found
  static Future<void> checkOnStartup(
    BuildContext context, {
    String? current,
    String repo = repoName,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    if (!context.mounted) return;

    final activeCurrent = current ?? await getAppVersion();
    final update = await checkForUpdate(current: activeCurrent, repo: repo);
    if (update != null && context.mounted && !_startupDialogShown) {
      _startupDialogShown = true;
      await showUpdateDialog(context, update, current: activeCurrent);
    }
  }

  /// Explicit check triggered from Settings / TopBar / Login page with user feedback
  static Future<void> checkManually(
    BuildContext context, {
    String? current,
    String repo = repoName,
  }) async {
    showGlassToast(
      context,
      context.tr('update.checking'),
      type: GlassToastType.info,
      color: Colors.blueAccent,
      duration: const Duration(seconds: 2),
    );

    final activeCurrent = current ?? await getAppVersion();
    final update = await checkForUpdate(current: activeCurrent, repo: repo);
    if (!context.mounted) return;

    if (update != null) {
      await showUpdateDialog(context, update, current: activeCurrent);
    } else {
      showGlassToast(
        context,
        context.tr('update.up_to_date')
            .replaceAll('{app}', appName)
            .replaceAll('{v}', activeCurrent),
        type: GlassToastType.success,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
