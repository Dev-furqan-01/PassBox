import 'package:flutter/material.dart';
import '../../../core/core.dart';

class VaultHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onLockTap;
  final VoidCallback onNotificationTap;
  final bool hasUnreadNotifications;

  const VaultHeader({
    super.key,
    required this.userName,
    required this.onLockTap,
    required this.onNotificationTap,
    this.hasUnreadNotifications = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lateralSafeMargin,
        vertical: AppSpacing.spaceXs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Good evening, $userName',
                        style: AppTextStyles.headlineMd.copyWith(
                          color: AppColors.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceXs),
                    const Icon(
                      Icons.verified,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    SizedBox(
                      width: 8,
                      height: 8,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const _PulseAnimation(),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.75),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'ENTERPRISE SHIELD ACTIVE',
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.secondary,
                          letterSpacing: 0.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Row(
            children: [
              _ActionButton(
                icon: Icons.lock,
                onTap: onLockTap,
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Stack(
                children: [
                  _ActionButton(
                    icon: Icons.notifications,
                    onTap: onNotificationTap,
                  ),
                  if (hasUnreadNotifications)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          boxShadow: AppShadows.cardElevation,
        ),
        child: Icon(
          icon,
          color: AppColors.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }
}

class _PulseAnimation extends StatefulWidget {
  const _PulseAnimation();

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(_animation.value * 0.3),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
