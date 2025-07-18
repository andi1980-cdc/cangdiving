#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// WordPress URLs und ihre Ersetzungen
const urlReplacements = {
  'https://changdiving.com/wp-content/uploads/2024/12/logo-500px.png': 'https://changdiving.com/img/logos/logo_cdc.webp',
  'https://changdiving.com/wp-content/uploads/2025/05/snorkeling2.webp': 'https://changdiving.com/img/products/snorkeling/snorkeling_2_small.webp'
};

let totalReplacements = 0;
let processedFiles = 0;

function processFile(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    let fileChanged = false;
    
    Object.keys(urlReplacements).forEach(oldUrl => {
      const newUrl = urlReplacements[oldUrl];
      if (content.includes(oldUrl)) {
        const count = (content.match(new RegExp(oldUrl.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g')) || []).length;
        content = content.replace(new RegExp(oldUrl.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'), newUrl);
        console.log(`✅ ${path.relative('.', filePath)}: ${count} WordPress-URL(s) ersetzt`);
        totalReplacements += count;
        fileChanged = true;
      }
    });
    
    if (fileChanged) {
      fs.writeFileSync(filePath, content, 'utf8');
      processedFiles++;
    }
  } catch (error) {
    console.error(`❌ Fehler bei ${filePath}:`, error.message);
  }
}

function scanDirectory(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  
  entries.forEach(entry => {
    const fullPath = path.join(dir, entry.name);
    
    if (entry.isDirectory()) {
      // Überspringe bestimmte Verzeichnisse
      if (!['node_modules', '.git', 'bin', 'tmp'].includes(entry.name)) {
        scanDirectory(fullPath);
      }
    } else if (entry.isFile() && entry.name.endsWith('.html')) {
      processFile(fullPath);
    }
  });
}

console.log('🧹 Bereinige WordPress-URLs...\n');

// Scan alle HTML-Dateien
['en', 'de', 'th'].forEach(lang => {
  if (fs.existsSync(lang)) {
    console.log(`📁 Verarbeite ${lang}/...`);
    scanDirectory(lang);
  }
});

console.log('\n📊 **Zusammenfassung:**');
console.log(`- Dateien bearbeitet: ${processedFiles}`);
console.log(`- URLs ersetzt: ${totalReplacements}`);
console.log(`- WordPress-Überbleibsel bereinigt! ✨`); 