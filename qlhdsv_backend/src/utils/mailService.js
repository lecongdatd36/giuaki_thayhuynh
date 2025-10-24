// src/utils/mailService.js
const nodemailer = require("nodemailer");
require("dotenv").config();

const transporter = nodemailer.createTransport({
  host: process.env.MAIL_HOST,
  port: process.env.MAIL_PORT,
  secure: false, // Brevo dùng STARTTLS (port 587)
  auth: {
    user: process.env.MAIL_USER,
    pass: process.env.MAIL_PASS,
  },
});

// 📨 Gửi mail
exports.sendMail = async (to, subject, html) => {
  try {
    const info = await transporter.sendMail({
      from: `"Hệ thống QLHDSV Khoa CNTT" <${process.env.MAIL_USER}>`,
      to,
      subject,
      html,
    });
    console.log(` Đã gửi mail tới ${to} (${info.messageId})`);
  } catch (err) {
    console.error("Lỗi gửi mail:", err.message);
  }
};
