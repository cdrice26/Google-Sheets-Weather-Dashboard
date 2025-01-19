export default function removeLastTwoLines() {
  return {
    name: 'remove-last-two-lines',
    generateBundle(options, bundle) {
      for (const chunkOrAsset of Object.values(bundle)) {
        if (chunkOrAsset.type === 'chunk') {
          const code = chunkOrAsset.code;
          const lines = code.split('\n');
          if (lines.length >= 2) {
            chunkOrAsset.code = lines.slice(0, -2).join('\n');
          }
        }
      }
    }
  };
}
