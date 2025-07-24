import os
from PIL import Image
import shutil
from datetime import datetime

def optimize_image(filepath, target_size_kb=27):
    # Create backup directory if it doesn't exist
    backup_dir = os.path.join(os.path.dirname(filepath), 'backup_' + datetime.now().strftime('%Y%m%d'))
    os.makedirs(backup_dir, exist_ok=True)
    
    # Create backup
    backup_path = os.path.join(backup_dir, os.path.basename(filepath))
    shutil.copy2(filepath, backup_path)
    
    # Open and verify image size
    with Image.open(filepath) as img:
        if img.size != (600, 400):
            print(f"Skipping {filepath} - not 600x400 pixels")
            return False
            
        # Start with quality 90 and adjust down until we hit target size
        quality = 90
        while quality > 10:
            # Save with current quality
            img.save(filepath, 'WEBP', quality=quality)
            
            # Check file size
            size_kb = os.path.getsize(filepath) / 1024
            
            if size_kb <= target_size_kb:
                print(f"Optimized {filepath}: {size_kb:.1f}KB (quality={quality})")
                return True
                
            # Reduce quality and try again
            quality -= 5
            
        print(f"Could not optimize {filepath} to target size")
        # Restore backup if we couldn't optimize
        shutil.copy2(backup_path, filepath)
        return False

def main():
    # Get list of images to optimize from check_images.py
    os.system('python3 check_images.py > images_to_optimize.txt')
    
    # Read the file and extract paths
    with open('images_to_optimize.txt', 'r') as f:
        lines = f.readlines()
    
    # Process each image path
    for line in lines:
        if '.webp:' in line:
            filepath = line.split(': ')[0]
            if os.path.exists(filepath):
                optimize_image(filepath)

if __name__ == "__main__":
    main() 