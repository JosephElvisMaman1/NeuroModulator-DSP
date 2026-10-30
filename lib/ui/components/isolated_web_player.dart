import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../i18n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'neuromorphic_card.dart';

enum WebPlayerPlatform {
  spotify,
  youtubeMusic,
}

/// Isolated Web Player & Sandbox Audio Launcher for PC.
/// Works seamlessly with WASAPI Loopback Capture.
class IsolatedWebPlayer extends StatefulWidget {
  final AppStrings strings;

  const IsolatedWebPlayer({
    super.key,
    required this.strings,
  });

  @override
  State<IsolatedWebPlayer> createState() => _IsolatedWebPlayerState();
}

class _IsolatedWebPlayerState extends State<IsolatedWebPlayer> {
  WebPlayerPlatform _platform = WebPlayerPlatform.spotify;

  Future<void> _openWebSandbox(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;

    return NeuromorphicCard(
      title: s.webPlayerTitle,
      subtitle: s.webPlayerSub,
      borderColor: AppColors.cyan500.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform Selector Tabs
          Row(
            children: [
              Expanded(
                child: _buildPlatformTab(
                  label: 'Spotify Web',
                  icon: Icons.music_note,
                  isSelected: _platform == WebPlayerPlatform.spotify,
                  activeColor: const Color(0xFF1DB954),
                  onTap: () => setState(() => _platform = WebPlayerPlatform.spotify),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildPlatformTab(
                  label: 'YouTube Music',
                  icon: Icons.play_circle_fill,
                  isSelected: _platform == WebPlayerPlatform.youtubeMusic,
                  activeColor: const Color(0xFFFF0000),
                  onTap: () => setState(() => _platform = WebPlayerPlatform.youtubeMusic),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Sandbox & WASAPI Info Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.slate800.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.slate700),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.emerald500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _platform == WebPlayerPlatform.spotify
                            ? 'SPOTIFY + WASAPI LOOPBACK BRIDGE'
                            : 'YOUTUBE MUSIC + WASAPI LOOPBACK BRIDGE',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  s.webSandboxDesc,
                  style: const TextStyle(color: AppColors.slate400, fontSize: 11.5, height: 1.4),
                ),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _platform == WebPlayerPlatform.spotify
                        ? const Color(0xFF1DB954)
                        : const Color(0xFFFF0000),
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.launch, size: 15),
                  label: Text(
                    _platform == WebPlayerPlatform.spotify ? s.openSpotifyBtn : s.openYoutubeBtn,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    final url = _platform == WebPlayerPlatform.spotify
                        ? 'https://open.spotify.com'
                        : 'https://music.youtube.com';
                    _openWebSandbox(url);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : AppColors.slate800,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.slate700,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? activeColor : AppColors.slate400),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.slate400,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
