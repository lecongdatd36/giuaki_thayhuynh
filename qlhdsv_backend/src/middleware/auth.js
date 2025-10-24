const jwt = require("jsonwebtoken");
require("dotenv").config();

module.exports = (req, res, next) => {
  const token = req.header("Authorization")?.replace("Bearer ", "");
  if (!token) return res.status(401).json({ message: "Không có token" });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log("🔑 Token decode:", decoded); // 👈 Thêm dòng này
    req.user = decoded;
    next();
  } catch (err) {
    console.error("❌ Token lỗi:", err.message);
    res.status(401).json({ message: "Token không hợp lệ" });
  }
};
