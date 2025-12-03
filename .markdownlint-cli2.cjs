const fs = require("node:fs");
const path = require("node:path");

const configPath = path.join(__dirname, ".markdownlintrc");
const config = JSON.parse(fs.readFileSync(configPath, "utf8"));

module.exports = {
	config,
	globs: ["**/*.md", "!node_modules/**", "!**/node_modules/**"],
};
