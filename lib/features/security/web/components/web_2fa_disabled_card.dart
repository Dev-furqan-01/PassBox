import 'package:flutter/material.dart';

/// 2FA Disabled Card showing accounts without 2FA
class Web2faDisabledCard extends StatelessWidget {
  final int missing2FA;

  const Web2faDisabledCard({
    super.key,
    required this.missing2FA,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.phonelink_lock,
                      color: Color(0xFF6366F1),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '2FA DISABLED',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$missing2FA',
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // List of accounts without 2FA
          if (missing2FA > 0)
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: missing2FA > 3 ? 3 : missing2FA,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _2faDisabledItem(
                    serviceName: _getSampleService(index),
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: Color(0xFF10B981),
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'All accounts have 2FA',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getSampleService(int index) {
    const services = ['Twitter', 'Instagram', 'GitHub', 'Discord', 'Steam'];
    return services[index % services.length];
  }
}

class _2faDisabledItem extends StatefulWidget {
  final String serviceName;

  const _2faDisabledItem({
    required this.serviceName,
  });

  @override
  State<_2faDisabledItem> createState() => _2faDisabledItemState();
}

class _2faDisabledItemState extends State<_2faDisabledItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isHovered
              ? const Color(0xFF6366F1).withOpacity(0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF6366F1).withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getServiceIcon(widget.serviceName),
                color: const Color(0xFF64748B),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.serviceName,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '2FA not enabled',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: _isHovered
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF64748B),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'twitter':
        return Icons.flutter_dash;
      case 'instagram':
        return Icons.camera_alt;
      case 'github':
        return Icons.code;
      case 'discord':
        return Icons.chat;
      case 'steam':
        return Icons.videogame_asset;
      default:
        return Icons.web;
    }
  }
}
