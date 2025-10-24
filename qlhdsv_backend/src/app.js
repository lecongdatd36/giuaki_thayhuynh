const express = require("express");
const cors = require("cors");
const app = express();



app.use(cors());
app.use(express.json());

app.use("/api/auth", require("./routes/authRoutes"));
app.use("/api/activities", require("./routes/activityRoutes"));
app.use("/api/registrations", require("./routes/registrationRoutes"));
app.use("/api/stats", require("./routes/statRoutes"));


app.get("/", (_, res) => res.send("✅ QLHDSV Backend đang chạy"));
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`✅ Server chạy tại http://localhost:${PORT}`);
});
module.exports = app;
