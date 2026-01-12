# Cadenca Onboarding Flow

Beautiful onboarding screens with cloud animations for first-time users.

## Screens

1. **Sleep & Fatigue Basics** - Explains how Cadenca works
2. **Profession Selection** - Choose pilot/cabin crew role
3. **Demographics** - Gender and age group (removed non-binary as requested)
4. **Time Adaptation Preference** - HT/LT/CD strategy
5. **Home Timezone** - Select primary residence timezone

## Features

- ✅ Smooth cloud animations on all screens
- ✅ Page indicator with worm effect
- ✅ Back/Continue navigation
- ✅ Dark theme matching login screen
- ✅ Teal accent color (#14B8A6)
- ✅ Disabled state for Continue button until selection made

## Integration

### 1. Add to Router

In your `app_router.dart`, add the onboarding route:

```dart
GoRoute(
  path: '/onboarding',
  name: 'onboarding',
  builder: (context, state) => const OnboardingFlow(),
),
```

### 2. Navigate After First Login

In your `AuthBloc` or login success handler:

```dart
if (state is AuthAuthenticated) {
  if (state.user.isFirstLogin) {
    context.go('/onboarding');
  } else {
    context.go('/home');
  }
}
```

### 3. Save Onboarding Data

Create a service to save the onboarding selections:

```dart
class OnboardingService {
  Future<void> saveOnboardingData({
    required String profession,
    required String gender,
    required String ageGroup,
    required String timeStrategy,
    required String homeTimezone,
  }) async {
    // Save to backend API
    // Mark user as onboarded
  }
}
```

## Customization

### Change Colors

Update the teal color throughout:
- Current: `Color(0xFF14B8A6)`
- Background: `Color(0xFF0F172A)`

### Modify Cloud Speed

In each page's `_cloudController`:
```dart
duration: const Duration(seconds: 30), // Adjust speed
```

### Add More Timezones

Edit `onboarding_timezone_page.dart`:
```dart
final List<Map<String, String>> _timezones = [
  {'city': 'YourCity', 'code': 'TZ', 'offset': '+X:00'},
];
```

## Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  smooth_page_indicator: ^1.2.0
```

Run:
```bash
flutter pub get
```

## File Structure

```
lib/features/onboarding/
├── presentation/
│   └── pages/
│       ├── onboarding_flow.dart
│       ├── onboarding_basics_page.dart
│       ├── onboarding_profession_page.dart
│       ├── onboarding_demographics_page.dart
│       ├── onboarding_preference_page.dart
│       └── onboarding_timezone_page.dart
└── ONBOARDING_README.md
```

## Notes

- Cloud animations use `ImageFiltered` with blur for depth effect
- All screens have consistent navigation (back button + continue button)
- Continue button is disabled until user makes a selection
- Removed "Non-binary" option as requested
- Timezones are hardcoded for now (can be made dynamic later)
