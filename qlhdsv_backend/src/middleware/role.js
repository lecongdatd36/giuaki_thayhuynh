exports.requireRole = (...allowedRoles) => {
  return (req, res, next) => {
    try {
      if (!req.user || !req.user.role) {
        return res.status(401).json({ message: "Chưa đăng nhập" });
      }

      if (!allowedRoles.includes(req.user.role)) {
        return res.status(403).json({
          message: `Vai trò hợp lệ: ${allowedRoles.join(", ")}`,
        });
      }

      // ✅ Nếu hợp lệ thì tiếp tục
      next();
    } catch (err) {
      console.error("❌ Lỗi middleware requireRole:", err);
      res.status(500).json({ message: "Lỗi kiểm tra vai trò" });
    }
  };
};