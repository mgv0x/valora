import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../presentation/screens/shopping/shopping_list_sheet.dart';
import '../../state/settings_provider.dart';
import '../../state/shopping_list_provider.dart';
import '../theme/app_colors.dart';
import 'valora_logo.dart';

/// Reusable Top Header exactly reproducing the Stitch navigation header.
class ValoraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onProfilePressed;
  final Widget? trailing;

  const ValoraAppBar({
    super.key,
    required this.title,
    this.onProfilePressed,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  Widget _buildInitialsOrIcon(String initials) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.forestGreen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider? settings;
    try {
      settings = context.watch<SettingsProvider>();
    } catch (_) {}

    final userInitials = settings?.userInitials ?? 'V';
    final avatar = settings?.userAvatar;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = (isDark ? AppColors.darkSurface : AppColors.canvas).withValues(alpha: 0.95);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final slashColor = isDark ? AppColors.darkBorder : const Color(0xFFC1C8C1);
    final titleColor = isDark ? AppColors.textSecondaryDark : AppColors.subHeader;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Logo + App Name + '/' + Current Screen Breadcrumb
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ValoraLogo(size: 24),
              const SizedBox(width: 8),
              Text(
                'Valora',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.forestGreen,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '/',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: slashColor,
                  ),
                ),
              ),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                ),
              ),
            ],
          ),

          // Right: Shopping List shortcut + User profile avatar or custom trailing widget
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (ctx) {
                  int count = 0;
                  try {
                    count = ctx.watch<ShoppingListProvider>().uncheckedCount;
                  } catch (_) {}
                  return IconButton(
                    tooltip: 'Lista de Compras',
                    icon: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      backgroundColor: AppColors.forestGreen,
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 20,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    onPressed: () => ShoppingListSheet.show(ctx),
                  );
                },
              ),
              const SizedBox(width: 4),
              trailing ??
                  GestureDetector(
                    onTap: onProfilePressed,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceContainerHigh,
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (avatar != null && avatar.isNotEmpty && avatar.startsWith('http'))
                            ? Image.network(
                                avatar,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _buildInitialsOrIcon(userInitials),
                              )
                            : _buildInitialsOrIcon(userInitials),
                      ),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
