#!/bin/bash

# Script to replace "HTMS Chang" with "เรือหลวงช้าง" in all Thai HTML files
# Created: $(date)

echo "🔄 Replacing HTMS Chang with เรือหลวงช้าง in Thai pages..."

# Create backup branch
echo "Creating backup branch..."
git branch backup-htms-chang-thai-replacement-$(date +%Y%m%d-%H%M%S)
if [ $? -eq 0 ]; then
    echo "✅ Backup created successfully"
else
    echo "❌ Failed to create backup"
    exit 1
fi

# Find and count total instances before replacement
echo "📊 Counting total instances..."
total_instances=$(find th/ -name "*.html" -exec grep -o "HTMS Chang" {} \; | wc -l)
echo "Found $total_instances instances of 'HTMS Chang' in Thai files"

# Replace HTMS Chang with เรือหลวงช้าง in all Thai HTML files
echo "🔄 Starting replacement process..."

replaced_files=0
total_replacements=0

for file in $(find th/ -name "*.html" -exec grep -l "HTMS Chang" {} \;); do
    # Count instances in this file before replacement
    instances_before=$(grep -o "HTMS Chang" "$file" | wc -l)
    
    if [ $instances_before -gt 0 ]; then
        # Perform replacement
        sed -i '' 's/HTMS Chang/เรือหลวงช้าง/g' "$file"
        
        # Count instances after replacement (should be 0)
        instances_after=$(grep -o "HTMS Chang" "$file" | wc -l)
        
        if [ $instances_after -eq 0 ]; then
            echo "✅ $file: Replaced $instances_before instances"
            ((replaced_files++))
            ((total_replacements+=instances_before))
        else
            echo "❌ $file: Failed to replace all instances"
        fi
    fi
done

echo ""
echo "📊 REPLACEMENT SUMMARY:"
echo "Files processed: $replaced_files"
echo "Total replacements: $total_replacements"
echo "Original instances: $total_instances"

# Verify no more instances exist
remaining_instances=$(find th/ -name "*.html" -exec grep -o "HTMS Chang" {} \; | wc -l)
echo "Remaining instances: $remaining_instances"

if [ $remaining_instances -eq 0 ]; then
    echo "✅ SUCCESS: All instances of 'HTMS Chang' have been replaced with 'เรือหลวงช้าง'"
else
    echo "❌ WARNING: Some instances may still exist"
fi

echo ""
echo "🔍 Verification: Checking for เรือหลวงช้าง..."
thai_instances=$(find th/ -name "*.html" -exec grep -o "เรือหลวงช้าง" {} \; | wc -l)
echo "Found $thai_instances instances of 'เรือหลวงช้าง' in Thai files"

echo ""
echo "🎯 Next steps:"
echo "1. Review the changes: git diff"
echo "2. Test the website"
echo "3. If satisfied: git add -A && git commit -m 'Replace HTMS Chang with เรือหลวงช้าง in Thai pages'"
echo "4. If problems occur: git reset --hard HEAD" 