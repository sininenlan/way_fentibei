import express from "express";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.dirname(fileURLToPath(import.meta.url));
const app = express();
app.use(express.static(path.join(root, "dist")));
app.get("*", (_request, response) => {
  response.sendFile(path.join(root, "dist", "index.html"));
});
app.listen(4174, "0.0.0.0", () => {
  console.log("Kepler map: http://localhost:4174");
});
