const express = require("express");
const dotenv = require("dotenv");
const path = require("path");

dotenv.config({ path: path.join(__dirname, ".env") });

const postsRoutes = require("./routes/posts");
const profileRoutes = require("./routes/profile");

const app = express();

app.use(express.json());

app.use("/posts", postsRoutes);
app.use("/profile", profileRoutes);

app.listen(process.env.PORT || 3000, () => {
  console.log(`Server läuft auf http://localhost:${process.env.PORT || 3000}`);
});