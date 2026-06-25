import '/core/utils/exports.dart';
import '/core/providers/theme_provider.dart';


class CustomSearchBar extends ConsumerWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = ref.watch(themeProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(5),
        width: double.maxFinite,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isDark
              ? AppColors.instance.surfaceDark
              : AppColors.instance.surface,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            w16,
            Text(
              'Search for workouts, meals and more...',
              style: AppTextStyles.instance.labelLarge,
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.instance.backgroundDark
                    : AppColors.instance.background,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                CupertinoIcons.search,
                size: AppConstants.defIconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
