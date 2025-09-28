# Copy pack files (changes most frequently - should be last)
if [ -d "/tmp/modpacks/${PACK_NAME}/overrides" ]; then
  echo "Found pack overrides folder, copying all files to server..."
  cp -r /tmp/modpacks/${PACK_NAME}/overrides/* /app/ || echo "No modpack files to copy"
else
  echo "No pack overrides folder found, copying all files from pack folder..."
  cp -r /tmp/modpacks/${PACK_NAME}/ /app/ || echo "No modpack files to copy"
fi