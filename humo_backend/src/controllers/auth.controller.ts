import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { generateTokens, verifyRefreshToken } from '../utils/jwt';
import { sendSuccess, sendError } from '../utils/response';
import { sendOtpEmail } from '../utils/email';

const registerSchema = z.object({
  fullName: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(6),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string(),
});

export const register = async (req: Request, res: Response) => {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) {
    return sendError(res, 'VALIDATION_ERROR', (parsed.error as any).errors[0].message);
  }

  const { fullName, email, password } = parsed.data;

  const exists = await prisma.user.findUnique({ where: { email } });
  if (exists) return sendError(res, 'EMAIL_EXISTS', 'Bu email allaqachon ro\'yxatdan o\'tgan');

  const passwordHash = await bcrypt.hash(password, 12);
  const user = await prisma.user.create({
    data: { fullName, email, passwordHash },
    select: { id: true, fullName: true, email: true, role: true },
  });

  const code = Math.floor(100000 + Math.random() * 900000).toString();
  await prisma.otpCode.create({
    data: {
      userId: user.id,
      code,
      type: 'EMAIL_VERIFY',
      expiresAt: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
    },
  });
  await sendOtpEmail(email, code);

  const tokens = generateTokens(user.id, user.role);
  return sendSuccess(res, { user, ...tokens }, 'Ro\'yxatdan o\'tildi', 201);
};

export const login = async (req: Request, res: Response) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) {
    return sendError(res, 'VALIDATION_ERROR', (parsed.error as any).errors[0].message);
  }

  const { email, password } = parsed.data;

  const user = await prisma.user.findUnique({ where: { email } });
  if (!user || !user.passwordHash) {
    return sendError(res, 'INVALID_CREDENTIALS', 'Email yoki parol noto\'g\'ri', 401);
  }

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) return sendError(res, 'INVALID_CREDENTIALS', 'Email yoki parol noto\'g\'ri', 401);

  const tokens = generateTokens(user.id, user.role);
  return sendSuccess(res, {
    user: { id: user.id, fullName: user.fullName, email: user.email, role: user.role },
    ...tokens,
  });
};

export const refreshToken = async (req: Request, res: Response) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return sendError(res, 'NO_TOKEN', 'Refresh token yo\'q', 401);

  try {
    const { userId } = verifyRefreshToken(refreshToken);
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) return sendError(res, 'USER_NOT_FOUND', 'Foydalanuvchi topilmadi', 404);

    const tokens = generateTokens(user.id, user.role);
    return sendSuccess(res, tokens);
  } catch {
    return sendError(res, 'TOKEN_INVALID', 'Token yaroqsiz', 401);
  }
};
