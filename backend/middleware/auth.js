const jwt = require("jsonwebtoken");
const dotenv = require("dotenv");
const path = require("path");

dotenv.config({ path: path.join(__dirname, "..", ".env") });

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      data: null,
      error: "Missing or invalid authorization header",
    });
  }

  const token = authHeader.split(" ")[1];

  try {
    console.log("ENV KEY:", process.env.NAKAMA_SESSION_ENCRYPTION_KEY);
    console.log("Token received:", token);
    console.log("JWT decoded:", jwt.decode(token));

    const payload = jwt.verify(
      token,
      process.env.NAKAMA_SESSION_ENCRYPTION_KEY,
      { algorithms: ["HS256"] }
    );

    if (!payload.uid) {
      return res.status(401).json({
        success: false,
        data: null,
        error: "Invalid token payload",
      });
    }

    req.user_id = payload.uid;
    req.username = payload.usn || null;
    req.token_claims = payload;

    next();
  } catch (err) {
    console.error("JWT verify failed:", err.name, err.message);

    return res.status(401).json({
      success: false,
      data: null,
      error: "Invalid or expired token",
    });
  }
}

module.exports = authMiddleware;