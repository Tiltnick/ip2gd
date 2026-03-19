const express = require("express");
const app = express();

app.use(express.json());

app.post("/posts", async (req, res) => {
  const { user_id, caption, image_path } = req.body;

  console.log("Post received:", user_id, caption);

  res.json({
    success: true,
    user_id,
    caption,
    image_path
  });
});

app.listen(3000, () => {
  console.log("Server läuft auf http://localhost:3000");
});