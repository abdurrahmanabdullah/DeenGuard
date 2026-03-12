const fs = require('fs');
const path = require('path');

const blocklistFile = process.argv[2] || './blocklist.txt';
const category = process.argv[3] || 'custom';

if (!fs.existsSync(blocklistFile)) {
  console.error('Blocklist file not found:', blocklistFile);
  process.exit(1);
}

const domains = fs.readFileSync(blocklistFile, 'utf-8')
  .split('\n')
  .map(line => line.trim())
  .filter(line => line && !line.startsWith('#'));

console.log(`Loaded ${domains.length} domains from ${blocklistFile}`);
console.log(`Category: ${category}`);

const output = domains.map(domain => ({
  domain: domain.replace(/^(https?:\/\/)?(www\.)?/, '').split('/')[0],
  category,
  isDefault: true,
  isActive: true,
}));

console.log('Domains ready for import:', output.slice(0, 5));
console.log('Use the DeenGuard API to import these domains.');
