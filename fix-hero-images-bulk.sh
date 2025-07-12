#!/bin/bash

# Bulk Fix Hero Images CLS Script
# Removes problematic inline styles from all hero images

echo "=== Bulk Hero Images CLS Fix ==="
echo "This script will remove 'style=\"width: 100%; height: auto\"' from all hero images"
echo ""

# Safety check
read -p "Are you sure you want to proceed? (y/N): " confirm
if [[ $confirm != [yY] ]]; then
    echo "Aborted."
    exit 1
fi

# Create backup
echo "Creating backup branch..."
git branch backup-bulk-hero-fix-$(date +%Y%m%d-%H%M%S)
if [ $? -eq 0 ]; then
    echo "✅ Backup created successfully"
else
    echo "❌ Failed to create backup"
    exit 1
fi

# Count files before
echo "Counting files with problematic hero images..."
total_files=$(grep -r -l 'style="width: 100%; height: auto"' --include="*.html" . | wc -l)
echo "Found $total_files files to fix"
echo ""

# Apply the fix
echo "Applying bulk fix..."
find . -name "*.html" -exec sed -i 's/style="width: 100%; height: auto"//g' {} \;

# Count files after
remaining_files=$(grep -r -l 'style="width: 100%; height: auto"' --include="*.html" . | wc -l)
fixed_files=$((total_files - remaining_files))

echo ""
echo "=== Results ==="
echo "✅ Fixed $fixed_files files"
echo "⚠️  Remaining problematic files: $remaining_files"
echo ""

if [ $remaining_files -eq 0 ]; then
    echo "🎉 All files fixed successfully!"
else
    echo "⚠️  Some files still need manual attention"
fi

echo ""
echo "Next steps:"
echo "1. Test a few random pages to ensure they work"
echo "2. Run PageSpeed tests on different page types"
echo "3. If successful: git add . && git commit -m 'Bulk fix: Remove CLS-causing inline styles from all hero images'"
echo "4. If problems occur: git checkout backup-bulk-hero-fix-*"
echo ""
echo "Recommended test pages:"
echo "- /en/posts/scuba-knowledge/nitrox-info/"
echo "- /en/product/divemaster/"
echo "- /en/about/"
echo "- /en/dive-sites/htms-chang-wreck/"
echo "- /en/faqs/" 