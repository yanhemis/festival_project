// userrouter.js
const express = require('express');
const bcrypt = require('bcrypt');
const router = express.Router();
const users = require('../users');
const { generateToken, generateRefreshToken, refreshToken } = require('../jwt');

// 회원가입
router.post('/signup', async (req, res) => {
  const { username, password } = req.body;
  if (users.find(u => u.username === username)) {
    return res.status(400).json({ message: 'User already exists' });
  }
  const hashedPassword = await bcrypt.hash(password, 10);
  users.push({ username, password: hashedPassword });
  res.json({ message: 'Signup success' });
});rou

// 로그인 → access + refresh 토큰 발급
router.post('/login', async (req, res) => {
  const { username, password } = req.body;
  const user = users.find(u => u.username === username);
  if (!user || !(await bcrypt.compare(password, user.password))) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  const payload = { userId: username };
  const accessToken = generateToken(payload);
  const refresh = generateRefreshToken(payload);

  // refresh 토큰 저장
  user.refreshToken = refresh;

  res.json({ accessToken, refreshToken: refresh });
});

// access 토큰 재발급
router.post('/refresh', (req, res) => {
  const { username, refreshToken: clientToken } = req.body;
  const user = users.find(u => u.username === username);
  if (!user || user.refreshToken !== clientToken) {
    return res.status(403).json({ message: 'Invalid refresh token' });
  }

  const newAccessToken = refreshToken(clientToken);
  if (!newAccessToken) {
    return res.status(403).json({ message: 'Token expired or invalid' });
  }

  res.json({ accessToken: newAccessToken });
});

module.exports = router;
