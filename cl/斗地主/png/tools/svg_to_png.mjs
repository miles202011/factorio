import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";
import sharp from "sharp";

const TOOL_DIR = path.dirname(fileURLToPath(import.meta.url));
const DEFAULT_INPUT_DIR = "../svg_original";
const DEFAULT_OUTPUT_DIR = "../png_converted";

function parseArgs(argv) {
  const options = {
    input: DEFAULT_INPUT_DIR,
    output: DEFAULT_OUTPUT_DIR,
    width: null,
    height: null,
    density: null,
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
    else if (arg === "--width" || arg === "-w") options.width = Number(next());
    else if (arg === "--height" || arg === "-h") options.height = Number(next());
    else if (arg === "--density") options.density = Number(next());
    else if (arg === "--clean") options.clean = true;
    else if (arg === "--help") options.help = true;
    else throw new Error(`Unknown option: ${arg}`);
  }

  for (const key of ["width", "height", "density"]) {
    if (options[key] !== null && (!Number.isFinite(options[key]) || options[key] <= 0)) {
      throw new Error(`${key} must be a positive number`);
    }
  }

  if ((options.width && !options.height) || (!options.width && options.height)) {
    throw new Error("Use --width and --height together, or omit both");
  }

  return options;
}

function printHelp() {
  console.log(`Usage:
  npm run convert
  node svg_to_png.mjs [options]

Options:
  -i, --input <dir>     SVG input folder. Default: ${DEFAULT_INPUT_DIR}
  -o, --output <dir>    PNG output folder. Default: ${DEFAULT_OUTPUT_DIR}
  -w, --width <px>      Optional exact output width.
  -h, --height <px>     Optional exact output height.
      --density <dpi>   Optional SVG raster density for inch-based SVGs.
      --clean           Delete existing PNG files in the output folder first.
      --help            Show this help.

Examples:
  node svg_to_png.mjs
  node svg_to_png.mjs --width 225 --height 315
  node svg_to_png.mjs --clean --output ../png_225x315 --width 225 --height 315
`);
}

function resolveToolPath(value) {
  return path.isAbsolute(value) ? value : path.resolve(TOOL_DIR, value);
}

async function listSvgFiles(inputDir) {
  const entries = await fs.readdir(inputDir, { withFileTypes: true });
  return entries
    .filter((entry) => entry.isFile() && entry.name.toLowerCase().endsWith(".svg"))
    .map((entry) => entry.name)
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
  const sharpOptions = {};
  if (options.density) sharpOptions.density = options.density;

  let image = sharp(inputPath, sharpOptions);
  if (options.width && options.height) {
    image = image.resize({
      width: options.width,
      height: options.height,
      fit: "fill",
    });
  }

  await image.png().toFile(outputPath);
  const metadata = await sharp(outputPath).metadata();
  return { width: metadata.width, height: metadata.height };
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

  const svgFiles = await listSvgFiles(inputDir);
  if (svgFiles.length === 0) {
    throw new Error(`No SVG files found in ${inputDir}`);
  }

  const sizes = new Map();
  for (const svgFile of svgFiles) {
    const inputPath = path.join(inputDir, svgFile);
    const outputName = svgFile.replace(/\.svg$/i, ".png");
    const outputPath = path.join(outputDir, outputName);
    const size = await convertOne(inputPath, outputPath, options);
    const sizeKey = `${size.width}x${size.height}`;
    sizes.set(sizeKey, (sizes.get(sizeKey) || 0) + 1);
    console.log(`${svgFile} -> ${outputName} (${sizeKey})`);
  }

  console.log("");
  console.log(`Converted: ${svgFiles.length}`);
  console.log(`Input: ${inputDir}`);
  console.log(`Output: ${outputDir}`);
  console.log(
    `Sizes: ${[...sizes.entries()]
      .map(([size, count]) => `${size}=${count}`)
      .join(", ")}`,
  );
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
