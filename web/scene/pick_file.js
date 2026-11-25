// Opens the browser's file picker (must be called from a click). Resolves
// with {name, type, bytes: Uint8Array} for the chosen file, or null.
export function pickFile(accept) {
  return new Promise((resolve) => {
    const input = Object.assign(document.createElement('input'), { type: 'file', accept });
    input.style.display = 'none';
    document.body.appendChild(input);
    let settled = false;
    const finish = (value) => {
      if (settled) return;
      settled = true;
      input.remove();
      resolve(value);
    };
    input.addEventListener('change', async () => {
      const file = input.files?.[0];
      if (!file) return finish(null);
      finish({ name: file.name, type: file.type, bytes: new Uint8Array(await file.arrayBuffer()) });
    });
    input.addEventListener('cancel', () => finish(null));
    input.click();
  });
}
