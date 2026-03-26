import express, { Application } from "express";
import dotenv from "dotenv";
import path from "path";

import { router as postsRoutes } from "./routes/posts";
import profileRoutes from "./routes/profile";

dotenv.config({ path: path.join(__dirname, ".env") });

const app: Application = express();

app.use(express.json());

app.use("/posts", postsRoutes);
app.use("/profile", profileRoutes);

const PORT: number = Number(process.env.PORT) || 3000;

app.listen(PORT, () => {
  console.log(`Server läuft auf http://localhost:${PORT}`);
});