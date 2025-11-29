const axios = require('axios');

// Server URL - can be overridden via environment variable
const SERVER_URL = process.env.SERVER_URL || 'http://localhost:3000';

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

async function testServer() {
  log('\n=== Testing Node.js DevOps Server ===\n', 'blue');

  try {
    // Test health endpoint
    log('1. Testing /health endpoint...', 'yellow');
    const healthResponse = await axios.get(`${SERVER_URL}/health`);
    log(`   ✓ Health check passed: ${JSON.stringify(healthResponse.data)}`, 'green');

    // Test root endpoint
    log('\n2. Testing / endpoint...', 'yellow');
    const rootResponse = await axios.get(`${SERVER_URL}/`);
    log(`   ✓ Root endpoint: ${JSON.stringify(rootResponse.data, null, 2)}`, 'green');

    // Test API info endpoint
    log('\n3. Testing /api/info endpoint...', 'yellow');
    const infoResponse = await axios.get(`${SERVER_URL}/api/info`);
    log(`   ✓ API Info: ${JSON.stringify(infoResponse.data, null, 2)}`, 'green');

    // Test echo endpoint
    log('\n4. Testing /api/echo endpoint...', 'yellow');
    const echoResponse = await axios.post(`${SERVER_URL}/api/echo`, {
      test: 'Hello from client',
      timestamp: new Date().toISOString()
    });
    log(`   ✓ Echo response: ${JSON.stringify(echoResponse.data, null, 2)}`, 'green');

    log('\n=== All tests passed! ===\n', 'green');
  } catch (error) {
    log(`\n✗ Error: ${error.message}`, 'red');
    if (error.response) {
      log(`   Status: ${error.response.status}`, 'red');
      log(`   Data: ${JSON.stringify(error.response.data)}`, 'red');
    }
    process.exit(1);
  }
}

// Run tests
testServer();

