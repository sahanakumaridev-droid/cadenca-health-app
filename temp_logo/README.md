# Cadenca Logo Setup Instructions

## Steps to use your Cadenca logo:

1. **Save the logo image**: Save the Cadenca logo image you uploaded as `cadenca_logo.png` in this `temp_logo` directory.

2. **Install Pillow** (if not already installed):
   ```bash
   pip install Pillow
   ```

3. **Run the resize script**:
   ```bash
   python3 create_logo.py
   ```

This will automatically create all the required app icon sizes for:
- Android (various DPI folders)
- iOS (AppIcon.appiconset)
- Web (favicon and icons)

## Required Sizes Generated:
- Android: 48px, 72px, 96px, 144px, 192px
- iOS: 20px, 29px, 40px, 60px, 76px, 83.5px, 120px, 152px, 167px, 180px, 1024px
- Web: 16px, 192px, 512px

The script will maintain the aspect ratio and quality of your original logo.