const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize with project ID (uses default credentials from environment)
admin.initializeApp({
  projectId: 'hybrid-order-system',
  storageBucket: 'hybrid-order-system.firebasestorage.app'
});

const bucket = admin.storage().bucket();

async function uploadFile(localPath, remotePath) {
  console.log(`Uploading ${localPath} to ${remotePath}...`);
  try {
    await bucket.upload(localPath, {
      destination: remotePath,
      public: true,
      metadata: {
        contentType: 'image/png',
        cacheControl: 'public, max-age=31536000',
      },
    });
    console.log(`Success: ${remotePath}`);
  } catch (error) {
    console.error(`Error uploading ${remotePath}:`, error);
  }
}

async function main() {
  const ramenPath = path.join(__dirname, 'assets/images/ramen.png');
  const gyozaPath = path.join(__dirname, 'assets/images/gyoza.png');

  await uploadFile(ramenPath, 'images/ramen.png');
  await uploadFile(gyozaPath, 'images/gyoza.png');
  
  console.log('Done!');
}

main();
