#!/bin/bash

# PDF Compression Script for Chang Diving Center
# Compresses all PDFs in docs/ folder using ghostscript

echo "🚀 Starting PDF compression for Chang Diving Center..."

# Create backup directory if it doesn't exist
mkdir -p docs/backup

# Initialize counters
total_before=0
total_after=0
count=0

echo "📊 Analyzing and compressing PDFs..."

# Process each PDF in docs folder
for pdf in docs/*.pdf; do
    if [ -f "$pdf" ]; then
        filename=$(basename "$pdf")
        
        # Get original file size
        original_size=$(stat -f%z "$pdf")
        original_human=$(ls -lh "$pdf" | awk '{print $5}')
        
        # Backup original
        cp "$pdf" "docs/backup/$filename"
        
        # Compress PDF with ghostscript
        echo "Compressing: $filename ($original_human)"
        gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
           -dNOPAUSE -dQUIET -dBATCH -sOutputFile="docs/temp_$filename" "$pdf"
        
        # Check if compression was successful
        if [ -f "docs/temp_$filename" ]; then
            # Get compressed file size
            compressed_size=$(stat -f%z "docs/temp_$filename")
            compressed_human=$(ls -lh "docs/temp_$filename" | awk '{print $5}')
            
            # Calculate compression ratio
            if [ $original_size -gt 0 ]; then
                percentage=$((100 - (compressed_size * 100 / original_size)))
            else
                percentage=0
            fi
            
            # Only replace if compression achieved more than 10% reduction
            if [ $compressed_size -lt $original_size ] && [ $percentage -gt 10 ]; then
                mv "docs/temp_$filename" "$pdf"
                echo "✅ $filename: $original_human → $compressed_human (-${percentage}%)"
            else
                rm "docs/temp_$filename"
                echo "⚠️  $filename: No significant compression (${percentage}%)"
            fi
        else
            echo "❌ Failed to compress: $filename"
        fi
        
        # Update counters
        total_before=$((total_before + original_size))
        current_size=$(stat -f%z "$pdf")
        total_after=$((total_after + current_size))
        count=$((count + 1))
    fi
done

# Calculate total savings
if [ $total_before -gt 0 ]; then
    total_percentage=$((100 - (total_after * 100 / total_before)))
    saved_bytes=$((total_before - total_after))
    
    # Convert to human readable
    saved_human=$(echo $saved_bytes | awk '{
        if ($1 > 1024*1024) printf "%.1fMB", $1/1024/1024
        else if ($1 > 1024) printf "%.1fKB", $1/1024
        else printf "%dB", $1
    }')
    
    before_human=$(echo $total_before | awk '{
        if ($1 > 1024*1024) printf "%.1fMB", $1/1024/1024
        else if ($1 > 1024) printf "%.1fKB", $1/1024
        else printf "%dB", $1
    }')
    
    after_human=$(echo $total_after | awk '{
        if ($1 > 1024*1024) printf "%.1fMB", $1/1024/1024
        else if ($1 > 1024) printf "%.1fKB", $1/1024
        else printf "%dB", $1
    }')
    
    echo ""
    echo "🎉 PDF Compression Complete!"
    echo "📁 Files processed: $count"
    echo "📊 Total before: $before_human"
    echo "📊 Total after: $after_human"
    echo "💾 Total saved: $saved_human (-${total_percentage}%)"
    echo "🗂️  Originals backed up to: docs/backup/"
else
    echo "❌ No PDFs found or processed"
fi

echo "✅ Done!" 