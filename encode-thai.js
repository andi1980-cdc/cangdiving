const fs = require('fs');

// Read the _redirects file
const redirectsFile = fs.readFileSync('_redirects', 'utf8');

// Convert content to lines
const lines = redirectsFile.split('\n');

// Process each line
const encodedLines = lines.map(line => {
  // Skip comment lines and empty lines
  if (line.startsWith('#') || !line.trim()) {
    return line;
  }

  // Split the line into old URL, new URL and status code
  const [oldUrl, newUrl, statusCode] = line.split(' ').filter(Boolean);

  // Check if URL contains Thai characters (Unicode range for Thai: \u0E00-\u0E7F)
  const hasThai = /[\u0E00-\u0E7F]/.test(oldUrl + newUrl);
  
  if (hasThai) {
    // Split URL into segments
    const encodeUrl = (url) => {
      return url.split('/')
        .map(segment => {
          // Encode only segments with Thai characters
          return /[\u0E00-\u0E7F]/.test(segment) ? 
            encodeURIComponent(segment) : segment;
        })
        .join('/');
    };

    // Encode both URLs if they contain Thai characters
    const encodedOldUrl = encodeUrl(oldUrl);
    const encodedNewUrl = encodeUrl(newUrl);

    return `${encodedOldUrl} ${encodedNewUrl} ${statusCode}`;
  }

  return line;
});

// Write the encoded version back to the file
fs.writeFileSync('_redirects', encodedLines.join('\n'));

console.log('Thai URLs have been successfully encoded!'); 