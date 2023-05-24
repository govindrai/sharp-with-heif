import sharp from "sharp"
import fs from 'fs';
import path from "path"

import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function mini_test() {
    const filename = "img.heic"
    const imageBuffer = fs.readFileSync(path.join(__dirname, "fixtures", filename))

    const resizedImageBuffer = await sharp(imageBuffer)
        .resize({ width: 960, height: 960, fit: 'inside' })
        .heif({ compression: 'hevc' })
        .toBuffer();

    fs.writeFileSync(path.join(__dirname, filename), resizedImageBuffer)
}

mini_test()
