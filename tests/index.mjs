import sharp from "sharp"
import fs from 'fs';
import path from "path"

import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function mini_test() {
    const imageBuffer = fs.readFileSync(path.join(__dirname, "/fixtures/sample1_orig_.heic"))

    // Resize the image using Sharp and convert to WebP
    const resizedImageBuffer = await sharp(imageBuffer)
        .resize({ width: 960, height: 960, fit: 'inside' })
        .toBuffer();

    fs.writeFileSync(path.join(__dirname, "sample1_web_.webp"), resizedImageBuffer)
    console.log("It might have worked!! check tests directory for sample1_web_.webp")
}

mini_test()
