import '/core/utils/exports.dart';
import '/core/providers/theme_provider.dart';


class CustomListTileWidget extends ConsumerWidget {
  final VoidCallback onTap;
  final String mainHeading;
  final String subHeading;
  const CustomListTileWidget({
    super.key,
    required this.onTap,
    required this.mainHeading,
    required this.subHeading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = ref.watch(themeProvider);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defRadOuter),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.defPadOuter,
          vertical: AppConstants.defPad,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.instance.surfaceDark
              : AppColors.instance.surface,
          borderRadius: BorderRadius.circular(AppConstants.defRad),
        ),
        child: Row(
          children: [
            CustomRoundButton(
              size: 10,
              color: isDark
                  ? AppColors.instance.backgroundDark
                  : AppColors.instance.background,
              child: Icon(Icons.wifi_tethering, size: AppConstants.defIconSize),
            ),
            w16,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mainHeading, style: AppTextStyles.instance.titleSmall),
                Text(
                  subHeading,
                  style: AppTextStyles.instance.body.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Spacer(),
            CustomRoundButton(
              size: 10,
              color: isDark
                  ? AppColors.instance.backgroundDark
                  : AppColors.instance.background,
              child: Icon(
                Icons.arrow_forward_rounded,
                size: AppConstants.defIconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
