import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder for a future light/dark toggle. QwikLearn ships light-only
/// (dark-ink-on-warm-paper *is* the theme) at MVP, but the provider exists
/// so a dark mode can be added without touching call sites.
final themeModeProvider = StateProvider<bool>((ref) => false); // false = light
