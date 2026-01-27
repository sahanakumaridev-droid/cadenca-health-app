#!/usr/bin/env python3
import os
from PIL import Image

def resize_logo():
    # Note: You need to place the cadenca logo image as 'Cadenca Logo.png' in this directory
    logo_path = 'Cadenca Logo.png'
    
    if not os.path.exists(logo_path):
        print(f"Please place the Cadenca logo as '{logo_path}' in this directory")
        return
    
    # Open the original logo
    original = Image.open(logo_path)
    
    # Define required sizes for Flutter app icons
    sizes = {
        # Android sizes
        '../android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
        '../android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
        '../android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
        '../android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
        '../android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
        
        # iOS sizes
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png': 20,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png': 40,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png': 60,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png': 29,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png': 58,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png': 87,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png': 40,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png': 80,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png': 120,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png': 120,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png': 180,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png': 76,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png': 152,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png': 167,
        '../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png': 1024,
        
        # Web sizes
        '../web/icons/Icon-192.png': 192,
        '../web/icons/Icon-512.png': 512,
        '../web/icons/Icon-maskable-192.png': 192,
        '../web/icons/Icon-maskable-512.png': 512,
        '../web/favicon.png': 16,
    }
    
    # Create directories if they don't exist
    for path in sizes.keys():
        directory = os.path.dirname(path)
        if directory and not os.path.exists(directory):
            os.makedirs(directory, exist_ok=True)
    
    # Resize and save each size
    for output_path, size in sizes.items():
        resized = original.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(output_path, 'PNG')
        print(f"Created: {output_path} ({size}x{size})")
    
    print("\nAll app icons created successfully!")
    print("Note: For iOS, you may need to update the Contents.json file in the AppIcon.appiconset folder")

if __name__ == "__main__":
    resize_logo()
