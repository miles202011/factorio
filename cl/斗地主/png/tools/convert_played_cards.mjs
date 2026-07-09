import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";
import sharp from "sharp";

const TOOL_DIR = path.dirname(fileURLToPath(import.meta.url));
const DEFAULT_INPUT_DIR = "../png_converted";
const DEFAULT_OUTPUT_DIR = "../png_converted_played";
const DEFAULT_FADE = 0.58;
const DEFAULT_WHITE_THRESHOLD = 242;
const SKIP_NAMES = new Set(["1B.png", "2B.png", "1B_Goodall.png", "2B_Goodall.png"]);

function parseArgs(argv) {
  const options = {
    input: DEFAULT_INPUT_DIR,
    output: DEFAULT_OUTPUT_DIR,
    fade: DEFAULT_FADE,
    whiteThreshold: DEFAULT_WHITE_THRESHOLD,
    includeBacks: false,
    clean: false,
    help: false,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    const next = () => {
      const value = argv[i + 1];
      if (!value || value.startsWith("--")) {
        throw new Error(`Missing value for ${arg}`);
      }
      i += 1;
      return value;
    };

    if (arg === "--input" || arg === "-i") options.input = next();
    else if (arg === "--output" || arg === "-o") options.output = next();
    else if (arg === "--fade") options.fade = Number(next());
    else if (arg === "--white-threshold") options.whiteThreshold = Number(next());
    else if (arg === "--include-backs") options.includeBacks = true;
    else if (arg === "--clean") options.clean = true;
    else if (arg === "--help") options.help = true;
    else throw new Error(`Unknown option: ${arg}`);
  }

  if (!Number.isFinite(options.fade) || options.fade <= 0 || options.fade >= 1) {
    throw new Error("--fade must be a number between 0 and 1");
  }
  if (
    !Number.isFinite(options.whiteThreshold) ||
    options.whiteThreshold < 0 ||
    options.whiteThreshold > 255
  ) {
    throw new Error("--white-threshold must be between 0 and 255");
  }

  return options;
}

function printHelp() {
  console.log(`Usage:
  node convert_played_cards.mjs [options]
  npm run convert:played

Options:
  -i, --input <dir>        Source PNG folder. Default: ${DEFAULT_INPUT_DIR}
  -o, --output <dir>       Output PNG folder. Default: ${DEFAULT_OUTPUT_DIR}
      --fade <0-1>         How strongly to blend the art toward white. Default: ${DEFAULT_FADE}
      --white-threshold <n> Leave near-white pixels unchanged. Default: ${DEFAULT_WHITE_THRESHOLD}
      --include-backs      Also convert 1B.png, 2B.png, 1B_Goodall.png, and 2B_Goodall.png.
      --clean              Delete existing PNG files in the output folder first.
      --help               Show this help.
`);
}

function resolveToolPath(value) {
  return path.isAbsolute(value) ? value : path.resolve(TOOL_DIR, value);
}

async function listPngFiles(inputDir, includeBacks) {
  const entries = await fs.readdir(inputDir, { withFileTypes: true });
  return entries
    .filter((entry) => entry.isFile() && entry.name.toLowerCase().endsWith(".png"))
    .map((entry) => entry.name)
    .filter((name) => includeBacks || !SKIP_NAMES.has(name))
    .sort((a, b) => a.localeCompare(b, "en"));
}

async function cleanOutput(outputDir) {
  const entries = await fs.readdir(outputDir, { withFileTypes: true }).catch((error) => {
    if (error.code === "ENOENT") return [];
    throw error;
  });

  await Promise.all(
    entries
      .filter((entry) => entry.isFile() && entry.name.toLowerCase().endsWith(".png"))
      .map((entry) => fs.unlink(path.join(outputDir, entry.name))),
  );
}

async function convertOne(inputPath, outputPath, options) {
  const image = sharp(inputPath).ensureAlpha();
  const { data, info } = await image.raw().toBuffer({ resolveWithObject: true });
  const output = Buffer.from(data);
  const fade = options.fade;
  const threshold = options.whiteThreshold;

  for (let i = 0; i < output.length; i += info.channels) {
    const r = output[i];
    const g = output[i + 1];
    const b = output[i + 2];
    const a = output[i + 3];

    if (a === 0) continue;
    if (r >= threshold && g >= threshold && b >= threshold) continue;

    output[i] = Math.round(r * (1 - fade) + 255 * fade);
    output[i + 1] = Math.round(g * (1 - fade) + 255 * fade);
    output[i + 2] = Math.round(b * (1 - fade) + 255 * fade);
  }

  await sharp(output, { raw: info }).png().toFile(outputPath);
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) {
    printHelp();
    return;
  }

  const inputDir = resolveToolPath(options.input);
  const outputDir = resolveToolPath(options.output);

  await fs.mkdir(outputDir, { recursive: true });
  if (options.clean) await cleanOutput(outputDir);

  const pngFiles = await listPngFiles(inputDir, options.includeBacks);
  if (pngFiles.length === 0) {
    throw new Error(`No PNG files found in ${inputDir}`);
  }

  for (const pngFile of pngFiles) {
    const inputPath = path.join(inputDir, pngFile);
    const outputPath = path.join(outputDir, pngFile);
    await convertOne(inputPath, outputPath, options);
    console.log(`${pngFile} -> ${path.relative(process.cwd(), outputPath)}`);
  }

  console.log("");
  console.log(`Converted: ${pngFiles.length}`);
  console.log(`Input: ${inputDir}`);
  console.log(`Output: ${outputDir}`);
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
