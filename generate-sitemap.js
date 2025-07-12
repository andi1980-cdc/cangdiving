#!/usr/bin/env node

/**
 * Automatic Sitemap Generator for Chang Diving Center
 * Scans all HTML files and generates XML sitemap with proper URLs
 */

const fs = require('fs');
const path = require('path');

// Configuration
const config = {
  baseUrl: 'https://changdiving.com',
  languages: ['en', 'de', 'th'],
  outputFile: 'sitemap.xml',
  excludePatterns: [
    'node_modules',
    '.git',
    'docs',
    'img',
    'js',
    'fonts',
    'style.css',
    'robots.txt',
    '_redirects.txt'
  ]
};

// Priority mapping for different page types
const priorityMap = {
  'index.html': 1.0,           // Homepage
  'about': 0.8,                // About pages
  'product': 0.9,              // Course/Product pages
  'dive-sites': 0.7,           // Dive sites
  'posts': 0.6,                // Blog posts
  'faqs': 0.5,                 // FAQ pages
  'store': 0.4,                // Store categories
  'contact': 0.7,              // Contact
  'prices': 0.8,               // Pricing
  'default': 0.5               // Everything else
};

// Change frequency for different page types
const changefreqMap = {
  'index.html': 'weekly',
  'about': 'monthly',
  'product': 'monthly',
  'dive-sites': 'monthly',
  'posts': 'weekly',
  'faqs': 'monthly',
  'store': 'weekly',
  'contact': 'monthly',
  'prices': 'weekly',
  'default': 'monthly'
};

function shouldExclude(filePath) {
  return config.excludePatterns.some(pattern => 
    filePath.includes(pattern)
  );
}

function getPriority(urlPath) {
  for (const [key, priority] of Object.entries(priorityMap)) {
    if (key === 'default') continue;
    if (urlPath.includes(key)) {
      return priority;
    }
  }
  return priorityMap.default;
}

function getChangeFreq(urlPath) {
  for (const [key, freq] of Object.entries(changefreqMap)) {
    if (key === 'default') continue;
    if (urlPath.includes(key)) {
      return freq;
    }
  }
  return changefreqMap.default;
}

function scanDirectory(dir, urls = []) {
  const files = fs.readdirSync(dir);
  
  for (const file of files) {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    
    if (shouldExclude(filePath)) {
      continue;
    }
    
    if (stat.isDirectory()) {
      scanDirectory(filePath, urls);
    } else if (file === 'index.html') {
      // Convert file path to URL
      let urlPath = filePath.replace(/\\/g, '/');
      
      // Remove index.html from path
      urlPath = urlPath.replace('/index.html', '');
      
      // Add leading slash if not present
      if (!urlPath.startsWith('/')) {
        urlPath = '/' + urlPath;
      }
      
      // Handle root index.html
      if (urlPath === '/') {
        urlPath = '';
      }
      
      const fullUrl = config.baseUrl + urlPath;
      const priority = getPriority(urlPath);
      const changefreq = getChangeFreq(urlPath);
      
      // Get file modification time
      const lastmod = stat.mtime.toISOString().split('T')[0];
      
      urls.push({
        url: fullUrl,
        lastmod,
        changefreq,
        priority
      });
    }
  }
  
  return urls;
}

function generateSitemap(urls) {
  let xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
`;

  // Sort URLs by priority (highest first), then alphabetically
  urls.sort((a, b) => {
    if (a.priority !== b.priority) {
      return b.priority - a.priority;
    }
    return a.url.localeCompare(b.url);
  });

  for (const urlData of urls) {
    xml += `  <url>
    <loc>${urlData.url}</loc>
    <lastmod>${urlData.lastmod}</lastmod>
    <changefreq>${urlData.changefreq}</changefreq>
    <priority>${urlData.priority}</priority>
  </url>
`;
  }

  xml += '</urlset>';
  return xml;
}

function generateLanguageStats(urls) {
  const stats = {};
  
  for (const lang of config.languages) {
    stats[lang] = urls.filter(u => u.url.includes(`/${lang}/`)).length;
  }
  
  // Count homepage and language-neutral pages
  stats['homepage'] = urls.filter(u => u.url === config.baseUrl).length;
  stats['total'] = urls.length;
  
  return stats;
}

// Main execution
console.log('🗺️  Chang Diving Center Sitemap Generator');
console.log('==========================================');

try {
  console.log('📁 Scanning directories for HTML files...');
  const urls = scanDirectory('.');
  
  console.log('📊 Statistics:');
  const stats = generateLanguageStats(urls);
  
  for (const [lang, count] of Object.entries(stats)) {
    console.log(`   ${lang.toUpperCase()}: ${count} pages`);
  }
  
  console.log('\n🏆 Top priority pages:');
  const topPages = urls
    .filter(u => u.priority >= 0.8)
    .sort((a, b) => b.priority - a.priority)
    .slice(0, 10);
    
  topPages.forEach(page => {
    console.log(`   ${page.priority} - ${page.url}`);
  });
  
  console.log('\n📝 Generating XML sitemap...');
  const sitemapXml = generateSitemap(urls);
  
  fs.writeFileSync(config.outputFile, sitemapXml);
  console.log(`✅ Sitemap generated: ${config.outputFile}`);
  console.log(`🌐 Total URLs: ${urls.length}`);
  console.log(`📍 Base URL: ${config.baseUrl}`);
  
  // Show file size
  const stats_file = fs.statSync(config.outputFile);
  const fileSize = (stats_file.size / 1024).toFixed(2);
  console.log(`📊 File size: ${fileSize} KB`);
  
} catch (error) {
  console.error('❌ Error generating sitemap:', error);
  process.exit(1);
} 