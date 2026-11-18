// Merges product.overrides.json into the upstream product.json (shallow, key by key).
// Usage: node scripts/merge-product.mjs <path-to-upstream-product.json> <path-to-overrides.json>
import fs from 'node:fs';

const [productPath, overridesPath] = process.argv.slice(2);
if (!productPath || !overridesPath) {
	console.error('usage: merge-product.mjs <product.json> <overrides.json>');
	process.exit(1);
}

const product = JSON.parse(fs.readFileSync(productPath, 'utf8'));
const overrides = JSON.parse(fs.readFileSync(overridesPath, 'utf8'));

for (const [key, value] of Object.entries(overrides)) {
	if (!(key in product) && !['extensionsGallery', 'linkProtectionTrustedDomains'].includes(key)) {
		console.warn(`warning: upstream product.json has no "${key}" — upstream may have renamed it`);
	}
	product[key] = value;
}

fs.writeFileSync(productPath, JSON.stringify(product, null, '\t') + '\n');
console.log(`product.json: applied ${Object.keys(overrides).length} overrides (${product.nameLong})`);
