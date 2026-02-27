Here's the complete step-by-step command list to build the Shopware 6.7.6.2 administration from scratch:
bash# ============================================
# Shopware 6.7.6.2 Administration Build Guide
# ============================================

# Step 1: Reinstall Shopware administration via Composer
cd /home/shopware/public_html
composer reinstall shopware/administration

# Step 2: Install admin npm dependencies
cd /home/shopware/public_html/vendor/shopware/administration/Resources/app/administration
npm install

# Step 3: Fix punycode polyfill (required workaround)
npm install punycode@2.3.0
npm install rollup-plugin-node-polyfills
mkdir -p node_modules/rollup-plugin-node-polyfills/polyfills/punycode
cp node_modules/punycode/punycode.js node_modules/rollup-plugin-node-polyfills/polyfills/punycode/index.js

# Step 4: Install SwagCommercial dependencies (fixes B2B plugin "Cannot find module 'vite'" errors)
cd /home/shopware/public_html/vendor/store.shopware.com/swagcommercial
npm install vite

# Step 5: Build the administration
cd /home/shopware/public_html
bin/build-administration.sh
Important notes:

Use Node.js 20 LTS (recommended) or 22. Do NOT use Node 24.
Never run npm audit fix --force on the admin node_modules — it breaks package versions.
After any composer update or composer reinstall shopware/administration, you'll need to repeat Steps 2–5.
The npm warn ERESOLVE peer dependency warnings during install are safe to ignore.
The B2B plugin build failures (EmployeeManagement, QuickOrder, etc.) should resolve after Step 4. If not, run npm install (full install) instead of just npm install vite in the swagcommercial directory.
