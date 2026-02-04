#!/usr/bin/env python3
"""
Script to generate app icons from the new Cadenca logo
Place your cadenca_logo_light_green.png in the assets/images/ folder and run this script
"""

import os
from PIL import Image, ImageDraw
import sys

def create_app_icon(source_path, output_path, size, background_color=None):
    """Create an app icon of specified size from source image"""
    try:
        # Open the source image
        with Image.open(source_path) as img:
            # Convert to RGBA if not already
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            
            # Create a new image with the target size
            icon = Image.new('RGBA', (size, size), background_color or (0, 0, 0, 0))
            
            # Calculate scaling to fit the logo nicely in the icon
            # Leave some padding around the logo
            padding = size * 0.1  # 10% padding
            target_size = int(size - (2 * padding))
            
            # Resize the logo to fit
            img_resized = img.resize((target_size, target_size), Image.Resampling.LANCZOS)
            
            # Center the logo in the icon
            x = (size - target_size) // 2
            y = (size - target_size) // 2
            
            # Paste the logo onto the icon
            icon.paste(img_resized, (x, y), img_resized)
            
            # Save the icon
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            icon.save(output_path, 'PNG')
            print(f"Created: {output_path} ({size}x{size})")
            
    except Exception as e:
        print(f"Error creating {output_path}: {e}")

def generate_android_icons(source_path):
    """Generate Android app icons"""
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    for folder, size in android_sizes.items():
        output_path = f"android/app/src/main/res/{folder}/ic_launcher.png"
        create_app_icon(source_path, output_path, size)

def generate_ios_icons(source_path):
    """Generate iOS app icons"""
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
    
    base_path = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for filename, size in ios_icons:
        output_path = f"{base_path}/{filename}"
        create_app_icon(source_path, output_path, size)

def main():
    source_path = "assets/images/cadenca_logo_light_green.png"
    
    if not os.path.exists(source_path):
        print(f"Error: Source image not found at {source_path}")
        print("Please place your cadenca_logo_light_green.png in the assets/images/ folder")
        sys.exit(1)
    
    print("Generating app icons from cadenca_logo_light_green.png...")
    
    # Generate Android icons
    print("\nGenerating Android icons...")
    generate_android_icons(source_path)
    
    # Generate iOS icons
    print("\nGenerating iOS icons...")
    generate_ios_icons(source_path)
    
    print("\n✅ App icons generated successfully!")
    print("Run 'flutter clean && flutter build apk --debug' to see the new icons")

if __name__ == "__main__":
    main()