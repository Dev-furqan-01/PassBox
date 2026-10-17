import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/core.dart';
import '../models/security_metrics.dart'
    show SecurityMetrics, UrgentAction, VaultSetting;
import 'components/web_header_banner.dart';
import 'components/web_critical_issues_card.dart';
import 'components/web_reused_passwords_card.dart';
import 'components/web_strength_overview_card.dart';
import 'components/web_recommended_actions_card.dart';

/// Desktop/Web Security Screen with modern grid dashboard layout
/// Top header banner + multi-card content grid
class WebSecurityScreen extends StatefulWidget {
  final SecurityMetrics metrics;
  final List<UrgentAction> urgentActions;
  final List<VaultSetting> vaultSettings;
  final bool isLoading;
  final VoidCallback onRunAudit;
  final Function(UrgentAction) onUrgentAction;

  const WebSecurityScreen({
    super.key,
    required this.metrics,
    required this.urgentActions,
    required this.vaultSettings,
    required this.isLoading,
    required this.onRunAudit,
    required this.onUrgentAction,
  });

  @override
  State<WebSecurityScreen> createState() => _WebSecurityScreenState();
}

class _WebSecurityScreenState extends State<WebSecurityScreen> {
  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) => _handleKeyEvent(event) ? KeyEventResult.handled : KeyEventResult.ignored,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Banner
              WebHeaderBanner(
                metrics: widget.metrics,
                onRunAudit: widget.onRunAudit,
              ),
              const SizedBox(height: 24),
              // Main Content Grid
              _buildContentGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.2,
      children: [
        // Critical Issues
        WebCriticalIssuesCard(
          weakPasswords: widget.metrics.weakPasswords,
          onActionTap: widget.onUrgentAction,
        ),
        // Reused Passwords
        WebReusedPasswordsCard(
          reusedPasswords: widget.metrics.reusedPasswords,
          onActionTap: widget.onUrgentAction,
        ),
        // Strength Overview
        WebStrengthOverviewCard(
          metrics: widget.metrics,
        ),
        // Recommended Actions
        WebRecommendedActionsCard(
          urgentActions: widget.urgentActions,
          onActionTap: widget.onUrgentAction,
        ),
      ],
    );
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isMac = Theme.of(context).platform == TargetPlatform.macOS;
      final controlPressed = isMac
          ? HardwareKeyboard.instance.isMetaPressed
          : HardwareKeyboard.instance.isControlPressed;

      // Cmd/Ctrl + R: Run Audit
      if (controlPressed && event.logicalKey == LogicalKeyboardKey.keyR) {
        widget.onRunAudit();
        return true;
      }
    }
    return false;
  }
}
