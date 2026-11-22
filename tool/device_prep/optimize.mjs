import sharp from 'sharp';
import { dedup, prune, weld, textureCompress } from '@gltf-transform/functions';

/** Cuts download size: shared data merged, unused data dropped, WebP textures ≤2k. */
export async function optimize(doc) {
  await doc.transform(
    dedup(),
    // keepAttributes: the blank screen has no texture yet, but its UVs are
    // needed at runtime when the user's media is applied.
    prune({ keepAttributes: true }),
    weld(),
    textureCompress({ encoder: sharp, targetFormat: 'webp', resize: [2048, 2048], quality: 88 }),
  );
}
