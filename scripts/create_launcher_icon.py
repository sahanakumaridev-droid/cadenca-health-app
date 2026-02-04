#!/usr/bin/env python3
"""
Use the exact Cadenca logo image for launcher icons
Resizes the provided logo image to all required launcher icon sizes
"""

from PIL import Image
import os

def resize_logo_for_launcher(source_path, output_path, size):
    """Resize the logo image to specified size for launcher icon"""
    try:
        with Image.open(source_path) as img:
            # Convert to RGB if needed (remove alpha channel for some formats)
            if img.mode in ('RGBA', 'LA'):
                # Create white background
                background = Image.new('RGB', img.size, (255, 255, 255))
                if img.mode == 'RGBA':
                    background.paste(img, mask=img.split()[-1])  # Use alpha channel as mask
                else:
                    background.paste(img)
                img = background
            elif img.mode != 'RGB':
                img = img.convert('RGB')
            
            # Resize to target size with high quality
            resized = img.resize((size, size), Image.Resampling.LANCZOS)
            
            # Save the resized icon
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            resized.save(output_path, 'PNG', quality=95)
            print(f"✅ Created: {output_path} ({size}x{size})")
            
    except Exception as e:
        print(f"❌ Error creating {output_path}: {e}")

def generate_android_launcher_icons(source_path):
    """Generate Android launcher icons from your logo"""
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    print("📱 Generating Android launcher icons...")
    for folder, size in android_sizes.items():
        output_path = f"android/app/src/main/res/{folder}/ic_launcher.png"
        resize_logo_for_launcher(source_path, output_path, size)

def generate_ios_launcher_icons(source_path):
    """Generate iOS launcher icons from your logo"""
    ios_icons = [
        ('Icon-App-20x20@1x.png', 20),
        ('Icon-App-20x20@2x.png', 40),
        ('Icon-App-20x20@3x.png', 60),
        ('Icon-App-29x29@1x.png', 29),
        ('Icon-App-29x29@2x.png', 58),
        ('Icon-App-29x29@3x.png', 87),
        ('Icon-App-40x40@1x.png', 40),
        ('Icon-App-40x40@2x.png', 80),
        ('Icon-App-40x40@3x.png', 120),
        ('Icon-App-60x60@2x.png', 120),
        ('Icon-App-60x60@3x.png', 180),
        ('Icon-App-76x76@1x.png', 76),
        ('Icon-App-76x76@2x.png', 152),
        ('Icon-App-83.5x83.5@2x.png', 167),
        ('Icon-App-1024x1024@1x.png', 1024),
    ]
    
    print("🍎 Generating iOS launcher icons...")
    base_path = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for filename, size in ios_icons:
        output_path = f"{base_path}/{filename}"
        resize_logo_for_launcher(source_path, output_path, size)

def main():
    source_path = "assets/images/cadenca_new_logo.png"
    
    if not os.path.exists(source_path):
        print(f"❌ Logo image not found at: {source_path}")
        print("\n📋 Please:")
        print("1. Save your logo image as 'assets/images/cadenca_new_logo.png'")
        print("2. Make sure it's high resolution (at least 1024x1024)")
        print("3. Run this script again")
        return
    
    print("🎨 Using your exact Cadenca logo for launcher icons...")
    print(f"📂 Source: {source_path}")
    
    # Generate icons for both platforms
    generate_android_launcher_icons(source_path)
    generate_ios_launcher_icons(source_path)
    
    print("\n🎉 Launcher icons updated successfully!")
    print("📦 Next steps:")
    print("1. Run: flutter clean")
    print("2. Run: flutter build apk --debug")
    print("3. Install the APK to see your new launcher icon!")

if __name__ == "__main__":
    main()