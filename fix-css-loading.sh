#!/bin/bash

# Fix CSS Loading Script - Phase 1 (Critical CLS Fix)
# This addresses the most critical layout shift issue

echo "🔧 CSS Loading Fix - Phase 1"
echo "============================="
echo "This script fixes the critical CSS loading issue:"
echo "  Current: media='print' onload='this.media=all'"
echo "  Problem: CSS loads after page, causing massive layout shift"
echo "  Solution: Direct CSS loading"
echo ""

# Safety check
read -p "Are you sure you want to proceed? (y/N): " confirm
if [[ $confirm != [yY] ]]; then
    echo "Aborted."
    exit 1
fi

# Create backup
echo "Creating backup branch..."
git branch backup-css-loading-fix-$(date +%Y%m%d-%H%M%S)
if [ $? -eq 0 ]; then
    echo "✅ Backup created successfully"
else
    echo "❌ Failed to create backup"
    exit 1
fi

echo ""
echo "🔍 Analyzing CSS loading issues..."

# Count files with the problematic CSS loading
total_files=$(grep -r -l 'media="print"' --include="*.html" . | wc -l)
echo "Found $total_files files with problematic CSS loading"

# Show examples
echo ""
echo "Example of problematic code:"
echo "  <link rel=\"stylesheet\" href=\"/style.css\" media=\"print\" onload=\"this.media='all'\" />"
echo ""
echo "Will be changed to:"
echo "  <link rel=\"stylesheet\" href=\"/style.css\" media=\"all\" />"
echo ""

echo "🔧 Applying fix..."

# Replace the problematic CSS loading
find . -name "*.html" -exec sed -i '' 's/media="print" onload="this\.media=.all."/media="all"/g' {} \;

# Count affected files
affected_files=$(git diff --name-only | wc -l)
echo "✅ $affected_files files modified"

echo ""
echo "📊 Summary:"
echo "- Fixed CSS loading technique on $affected_files files"
echo "- CSS now loads immediately (no delayed styling)"
echo "- Expected CLS improvement: Major reduction in layout shifts"
echo ""
echo "⚠️  Note: This may make initial page load slightly slower"
echo "   but will dramatically reduce CLS score"
echo ""
echo "Next steps:"
echo "1. Test a few pages to verify improvement"
echo "2. If successful, commit changes"
echo "3. Consider Phase 2 fixes (footer, breadcrumbs)" 