require('dotenv').config();
const jwt = require('jsonwebtoken');
const secretKey = process.env.JWT_SECRET_KEY;

const generateToken = (payload) => {
  return jwt.sign(payload, secretKey, { expiresIn: '15m' }); // Access Token
};

const generateRefreshToken = (payload) => {
  return jwt.sign(payload, secretKey, { expiresIn: '7d' }); // Refresh Token
};

const refreshToken = (refreshToken) => {
  try {
    const decoded = jwt.verify(refreshToken, secretKey);
    return generateToken({ userId: decoded.userId });
  } catch (err) {
    console.error('Token refresh error:', err);
    return null;
  }
};

module.exports = { generateToken, generateRefreshToken, refreshToken };
