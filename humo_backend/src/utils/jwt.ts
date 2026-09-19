import jwt from 'jsonwebtoken';

const ACCESS_SECRET = process.env.JWT_ACCESS_SECRET || 'access_secret';
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'refresh_secret';

export const generateTokens = (userId: string, role: string) => {
  const accessToken = jwt.sign({ userId, role }, ACCESS_SECRET, { expiresIn: (process.env.JWT_ACCESS_EXPIRES || '15m') as any });
  const refreshToken = jwt.sign({ userId, role }, REFRESH_SECRET, { expiresIn: (process.env.JWT_REFRESH_EXPIRES || '7d') as any });
  
  return { accessToken, refreshToken };
};

export const verifyAccessToken = (token: string): any => {
  return jwt.verify(token, ACCESS_SECRET);
};

export const verifyRefreshToken = (token: string): any => {
  return jwt.verify(token, REFRESH_SECRET);
};
