const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const target = process.argv[2];
if (!target) process.exit(1);

const bundledNode = process.env.CODEX_MCP_NODE_PATH;
const nodeBinary =
  bundledNode && fs.existsSync(bundledNode) ? bundledNode : process.execPath;
const result = spawnSync(
  nodeBinary,
  [path.resolve(process.cwd(), target), ...process.argv.slice(3)],
  { stdio: "inherit", env: process.env },
);
process.exit(result.status ?? 1);
