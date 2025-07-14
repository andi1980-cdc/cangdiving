#!/bin/bash

# Script to replace user-visible "Chang Diving" with Thai transliteration
# "Chang Diving Center" → "ช้างไดฟ์วิ่ง เซ็นเตอร์"
# "Chang Diving" → "ช้างไดฟ์วิ่ง"
# Preserves technical meta tags for SEO
# Created: $(date)

echo "🔄 Replacing user-visible Chang Diving with Thai transliteration..."

# Create backup branch
echo "Creating backup branch..."
git branch backup-chang-diving-thai-$(date +%Y%m%d-%H%M%S)
if [ $? -eq 0 ]; then
    echo "✅ Backup created successfully"
else
    echo "❌ Failed to create backup"
    exit 1
fi

# Count instances before replacement
echo "📊 Counting instances before replacement..."
total_center=$(find th/ -name "*.html" -exec grep -o "Chang Diving Center" {} \; | wc -l)
total_diving=$(find th/ -name "*.html" -exec grep -o "Chang Diving" {} \; | wc -l)

echo "Found $total_center instances of 'Chang Diving Center'"
echo "Found $total_diving total instances of 'Chang Diving'"

# Replace user-visible instances only
echo "🔄 Starting replacement process..."

replaced_files=0

# Process each file
for file in $(find th/ -name "*.html"); do
    if grep -q "Chang Diving" "$file"; then
        echo "Processing: $file"
        
        # Create backup of original
        cp "$file" "$file.bak"
        
        # IMPORTANT: Replace in correct order - longer strings first!
        # Replace only in user-visible contexts (titles, alt text, visible content)
        # Exclude technical meta tags
        sed -i '' '
            # Replace in title tags - CENTER FIRST!
            /<title>/s/Chang Diving Center/ช้างไดฟ์วิ่ง เซ็นเตอร์/g
            /<title>/s/Chang Diving/ช้างไดฟ์วิ่ง/g
            
            # Replace in page content (not in meta tags) - CENTER FIRST!
            /<h[1-6]/s/Chang Diving Center/ช้างไดฟ์วิ่ง เซ็นเตอร์/g
            /<h[1-6]/s/Chang Diving/ช้างไดฟ์วิ่ง/g
            
            /<p>/s/Chang Diving Center/ช้างไดฟ์วิ่ง เซ็นเตอร์/g
            /<p>/s/Chang Diving/ช้างไดฟ์วิ่ง/g
            
            /<strong>/s/Chang Diving Center/ช้างไดฟ์วิ่ง เซ็นเตอร์/g
            /<strong>/s/Chang Diving/ช้างไดฟ์วิ่ง/g
            
            # Replace in alt text - CENTER FIRST!
            /alt="Chang Diving Logo"/s/Chang Diving Logo/โลโก้ ช้างไดฟ์วิ่ง/g
            /alt="[^"]*Chang Diving Center/s/Chang Diving Center/ช้างไดฟ์วิ่ง เซ็นเตอร์/g
            /alt="[^"]*Chang Diving/s/Chang Diving/ช้างไดฟ์วิ่ง/g
            
            # Replace in visible content but not meta properties - CENTER FIRST!
            /content="[^"]*Chang Diving[^"]*"/!s/Chang Diving Center/ช้างไดฟ์วิ่ง เซ็นเตอร์/g
            /content="[^"]*Chang Diving[^"]*"/!s/Chang Diving/ช้างไดฟ์วิ่ง/g
            
            # Replace in FAQ content - CENTER FIRST!
            /"text":/s/Chang Diving Center/ช้างไดฟ์วิ่ง เซ็นเตอร์/g
            /"text":/s/Chang Diving/ช้างไดฟ์วิ่ง/g
            
            # Replace in questions/names - CENTER FIRST!
            /"name":/s/Chang Diving Center/ช้างไดฟ์วิ่ง เซ็นเตอร์/g
            /"name":/s/Chang Diving/ช้างไดฟ์วิ่ง/g
        ' "$file"
        
        # Check if file was actually changed
        if ! diff -q "$file" "$file.bak" > /dev/null 2>&1; then
            ((replaced_files++))
            echo "✅ $file: Changes applied"
        else
            echo "⚪ $file: No changes needed"
        fi
        
        # Remove backup
        rm "$file.bak"
    fi
done

echo ""
echo "📊 REPLACEMENT SUMMARY:"
echo "Files processed: $replaced_files"

# Count instances after replacement
echo "📊 Counting instances after replacement..."
remaining_center=$(find th/ -name "*.html" -exec grep -o "Chang Diving Center" {} \; | wc -l)
remaining_diving=$(find th/ -name "*.html" -exec grep -o "Chang Diving" {} \; | wc -l)
thai_center=$(find th/ -name "*.html" -exec grep -o "ช้างไดฟ์วิ่ง เซ็นเตอร์" {} \; | wc -l)
thai_diving=$(find th/ -name "*.html" -exec grep -o "ช้างไดฟ์วิ่ง" {} \; | wc -l)

echo "Remaining 'Chang Diving Center': $remaining_center"
echo "Remaining 'Chang Diving' total: $remaining_diving"
echo "New 'ช้างไดฟ์วิ่ง เซ็นเตอร์': $thai_center"
echo "New 'ช้างไดฟ์วิ่ง' total: $thai_diving"

echo ""
echo "🎯 Next steps:"
echo "1. Review the changes: git diff"
echo "2. Test the website"
echo "3. If satisfied: git add -A && git commit -m 'Replace user-visible Chang Diving with Thai transliteration'"
echo "4. If problems occur: git reset --hard HEAD" 