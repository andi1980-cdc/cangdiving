import os
from PIL import Image
import glob

def get_image_info(filepath):
    try:
        with Image.open(filepath) as img:
            width, height = img.size
            size_kb = os.path.getsize(filepath) / 1024
            return width, height, size_kb
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return None

def check_images(directory):
    needs_optimization = []  # 600x400 images > 30KB

    for ext in ['*.webp', '*.jpg']:
        for filepath in glob.glob(os.path.join(directory, '**', ext), recursive=True):
            info = get_image_info(filepath)
            if info:
                width, height, size_kb = info
                if width == 600 and height == 400 and size_kb > 30:
                    needs_optimization.append((filepath, size_kb))

    if needs_optimization:
        print("\n=== 600x400 Images That Need Optimization (>30KB) ===")
        print("Target size: 25-30KB")
        for path, size in sorted(needs_optimization, key=lambda x: x[1], reverse=True):
            print(f"{path}: {size:.1f}KB")
        print(f"\nTotal images to optimize: {len(needs_optimization)}")
    else:
        print("\nNo 600x400 images found that need optimization!")

if __name__ == "__main__":
    check_images("img") 