// 메인페이지
require('dotenv').config();
const express = require('express');
const authRoutes = require('./routes/auth');
const app = express();

app.use(express.json());
app.use('/auth', authRoutes);

const verifyToken = require('./middleware/auth');

app.get('/protected', verifyToken, (req, res) => {
  res.json({ message: `Hello ${req.user.userId}! This is protected.` });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
