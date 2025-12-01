#!/bin/bash

# Clean Node.js Project Script
# This script removes node_modules, package-lock.json, and other generated files

echo "🧹 Cleaning Node.js project..."

# Remove node_modules directories
echo "Removing node_modules..."
find . -name "node_modules" -type d -prune -exec rm -rf {} + 2>/dev/null

# Remove package-lock.json files
echo "Removing package-lock.json files..."
find . -name "package-lock.json" -type f -delete

# Remove npm debug logs
echo "Removing npm debug logs..."
find . -name "npm-debug.log" -type f -delete

# Remove .DS_Store files (macOS)
echo "Removing .DS_Store files..."
find . -name ".DS_Store" -type f -delete

# Remove log files
echo "Removing log files..."
find . -name "*.log" -type f -delete

# Remove coverage directories
echo "Removing coverage directories..."
find . -name "coverage" -type d -prune -exec rm -rf {} + 2>/dev/null

# Remove .nyc_output directories
echo "Removing .nyc_output directories..."
find . -name ".nyc_output" -type d -prune -exec rm -rf {} + 2>/dev/null

echo "✅ Project cleaned successfully!"
echo ""
echo "To reinstall dependencies, run:"
echo "  cd server && npm install"
echo "  cd client && npm install"

