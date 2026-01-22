import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class PrimaryButtonBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool enabled;
  final VoidCallback onPressed;

  const PrimaryButtonBar({
    super.key,
    required this.title,
    this.subtitle,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(.08),
            ),
          ),
        ),
        child: Row(
          children: [
            // ===== Price / Subtitle =====
            if (subtitle != null) ...[
              Expanded(
                child: Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ] else
              const Spacer(),

            // ===== Main Button =====
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: enabled ? onPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withOpacity(.35),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: enabled ? 1 : .6,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}