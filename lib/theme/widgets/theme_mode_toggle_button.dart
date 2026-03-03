import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/theme/theme_mode_controller.dart';

class ThemeModeToggleButton extends ConsumerWidget {
  const ThemeModeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeModeControllerProvider);

    IconData icon;
    switch (state.preference) {
      case AppThemePreference.light:
        icon = Icons.light_mode;
        break;
      case AppThemePreference.dark:
        icon = Icons.dark_mode;
        break;
      case AppThemePreference.auto:
        icon = Icons.brightness_auto;
        break;
    }

    return IconButton(
      icon: Icon(icon, size: 22),
      tooltip: 'Theme mode',
      onPressed: () => _showThemePicker(context, ref, state.preference),
    );
  }

  Future<void> _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    AppThemePreference selected,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Theme Mode',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              RadioListTile<AppThemePreference>(
                value: AppThemePreference.light,
                groupValue: selected,
                title: const Text('Light'),
                onChanged: (value) async {
                  if (value != null) {
                    await ref
                        .read(themeModeControllerProvider.notifier)
                        .setPreference(value);
                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
                  }
                },
              ),
              RadioListTile<AppThemePreference>(
                value: AppThemePreference.dark,
                groupValue: selected,
                title: const Text('Dark'),
                onChanged: (value) async {
                  if (value != null) {
                    await ref
                        .read(themeModeControllerProvider.notifier)
                        .setPreference(value);
                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
                  }
                },
              ),
              RadioListTile<AppThemePreference>(
                value: AppThemePreference.auto,
                groupValue: selected,
                title: const Text('Auto (ambient light)'),
                onChanged: (value) async {
                  if (value != null) {
                    await ref
                        .read(themeModeControllerProvider.notifier)
                        .setPreference(value);
                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
