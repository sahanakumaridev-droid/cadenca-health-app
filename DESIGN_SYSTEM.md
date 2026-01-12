# Cadenca Design System

## Color Palette - Aviation Health Theme

### Philosophy
The color scheme is designed for a **medical-grade aviation fatigue management app** targeting pilots. Colors convey trust, safety, professionalism, and calm—essential for both aviation and health contexts.

---

## Primary Colors

### Sky Blue `#3B82F6`
- **Usage:** Primary actions, links, brand color
- **Meaning:** Clear skies, trust, medical reliability
- **Aviation Context:** Clear weather, safe conditions
- **Health Context:** Medical blue (hospital/healthcare standard)

### Soft Blue `#60A5FA` (Dark Mode)
- **Usage:** Primary color in dark mode
- **Meaning:** Night-friendly, calm, sleep-focused
- **Aviation Context:** Night sky, cockpit lighting
- **Health Context:** Sleep-friendly, non-stimulating

---

## Accent Colors

### Emerald Green `#10B981`
- **Usage:** Success states, health indicators, recovery status
- **Meaning:** Health, vitality, good status
- **Aviation Context:** "Go" signal, safe to proceed
- **Health Context:** Healthy metrics, good sleep quality

### Amber/Gold `#F59E0B`
- **Usage:** Warnings, alerts, important information
- **Meaning:** Caution, attention needed
- **Aviation Context:** Standard aviation warning color
- **Health Context:** Moderate fatigue, attention required

### Red `#EF4444`
- **Usage:** Critical alerts, errors, high fatigue warnings
- **Meaning:** Danger, critical attention needed
- **Aviation Context:** Critical warnings, unsafe conditions
- **Health Context:** Severe fatigue, immediate action required

---

## Neutral Colors

### Deep Navy `#0F172A`
- **Usage:** Text, dark backgrounds, professional elements
- **Meaning:** Aviation professionalism, night operations
- **Aviation Context:** Cockpit, night sky, professional uniform
- **Health Context:** Serious, medical-grade reliability

### Slate Gray `#64748B`
- **Usage:** Secondary text, subtle elements
- **Meaning:** Professional, readable, non-distracting
- **Aviation Context:** Instrument panels, technical displays
- **Health Context:** Medical charts, data displays

### Light Background `#F8FAFC`
- **Usage:** Main background (light mode)
- **Meaning:** Clean, medical, professional
- **Aviation Context:** Clear day, visibility
- **Health Context:** Hospital white, sterile, trustworthy

### Dark Background `#0A0E1A`
- **Usage:** Main background (dark mode)
- **Meaning:** Night operations, sleep-friendly
- **Aviation Context:** Night sky, cockpit at night
- **Health Context:** Sleep mode, circadian-friendly

---

## Color Usage Guidelines

### Light Mode
```dart
Background: #F8FAFC (Clean Medical White)
Surface: #FFFFFF (Pure White)
Primary: #3B82F6 (Sky Blue)
Text Primary: #0F172A (Deep Navy)
Text Secondary: #64748B (Slate Gray)
Border: #E2E8F0 (Light Slate)
```

### Dark Mode
```dart
Background: #0A0E1A (Deep Navy - Night Sky)
Surface: #1E293B (Slate - Cockpit Dark)
Primary: #60A5FA (Soft Blue - Night-friendly)
Text Primary: #FFFFFF (White)
Text Secondary: #94A3B8 (Light Slate)
Border: #334155 (Dark Slate)
```

---

## Status Colors

### Fatigue Levels
- **Low Fatigue (Good):** `#10B981` Emerald Green
- **Moderate Fatigue (Caution):** `#F59E0B` Amber
- **High Fatigue (Critical):** `#EF4444` Red

### Sleep Quality
- **Excellent:** `#10B981` Emerald Green
- **Good:** `#3B82F6` Sky Blue
- **Fair:** `#F59E0B` Amber
- **Poor:** `#EF4444` Red

---

## Typography

### Font Weights
- **Bold (700):** Headings, important information
- **Semibold (600):** Buttons, labels, emphasis
- **Medium (500):** Subheadings
- **Regular (400):** Body text

### Font Sizes
- **32px:** Main titles
- **24px:** Section headings
- **16px:** Buttons, important text
- **14px:** Body text, labels
- **12px:** Captions, helper text
- **11px:** Small labels, badges

---

## Design Principles

### 1. Trust & Safety
- Use blue tones to convey reliability
- Clear hierarchy and readable text
- Consistent spacing and alignment

### 2. Medical-Grade Professionalism
- Clean, minimal design
- Ample whitespace
- Professional color palette
- Clear data visualization

### 3. Aviation Standards
- Familiar color coding (green=good, amber=caution, red=critical)
- Night-mode friendly (dark mode optimized)
- High contrast for readability
- Clear visual hierarchy

### 4. Sleep-Focused
- Dark mode as default for night use
- Non-stimulating colors in dark mode
- Calm, soothing color palette
- Reduced blue light in dark mode

---

## Component Styling

### Buttons
- **Primary:** Sky Blue background, white text
- **Secondary:** White/Dark background with border
- **Destructive:** Red background, white text

### Cards
- **Light Mode:** White background, subtle shadow
- **Dark Mode:** Slate background, no shadow

### Forms
- **Border:** Light slate in light mode, dark slate in dark mode
- **Focus:** Sky blue border (2px)
- **Error:** Red border with red text

### Badges
- **Info:** Sky blue background
- **Success:** Emerald background
- **Warning:** Amber background
- **Error:** Red background

---

## Accessibility

### Contrast Ratios
- All text meets WCAG AA standards (4.5:1 minimum)
- Interactive elements have clear focus states
- Color is never the only indicator of status

### Dark Mode
- Optimized for night use by pilots
- Reduced eye strain
- Maintains readability
- Preserves night vision

---

## Competitive Advantage

This color scheme differentiates Cadenca from:
- **Generic health apps:** More professional, aviation-focused
- **Aviation apps:** More health-conscious, sleep-friendly
- **Consumer apps:** Medical-grade reliability, professional trust

The palette balances:
- **Aviation professionalism** (navy, slate, structured)
- **Medical reliability** (blue, clean, trustworthy)
- **Sleep focus** (calm, night-friendly, soothing)
- **Scandinavian design** (minimal, clean, functional)
