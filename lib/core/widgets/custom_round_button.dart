import '/core/utils/exports.dart';
import '/core/providers/theme_provider.dart';

class CustomRoundButton extends ConsumerWidget {
  final double size;
  final VoidCallback? onPressed;
  final String? imgPath;
  final Widget child;
  final Color? color;
  const CustomRoundButton({
    super.key,
    required this.size,
    this.onPressed,
    this.imgPath,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(size),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color:
              color ??
              (!ref.watch(themeProvider)
                  ? AppColors.instance.surface
                  : AppColors.instance.surfaceDark),
          image: imgPath != null
              ? DecorationImage(
                  fit: BoxFit.cover,
                  invertColors: true,
                  image: AssetImage(imgPath!),
                )
              : null,
        ),
        child: child,
      ),
    );
  }
}
