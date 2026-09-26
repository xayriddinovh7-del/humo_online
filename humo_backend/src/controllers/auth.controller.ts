import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { generateTokens, verifyRefreshToken } from '../utils/jwt';
import { sendSuccess, sendError } from '../utils/response';

const registerSchema = z.object({
  fullName: z.string().min(2, 'Ism kamida 2 ta belgi'),
  email: z.string().min(3, 'Login kiritilishi shart'),
  password: z.string().min(6, 'Parol kamida 6 ta belgi'),
  role: z.enum(['STUDENT', 'TEACHER']).default('STUDENT'),
});

const loginSchema = z.object({
  email: z.string().min(3),
  password: z.string(),
});

// ─── Register ──────────────────────────────────────────────────────────────
export const register = async (req: Request, res: Response) => {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) {
    return sendError(res, 'VALIDATION_ERROR', (parsed.error as any).errors[0].message);
  }

  const { fullName, email, password, role } = parsed.data;

  const exists = await prisma.user.findUnique({ where: { email } });
  if (exists) return sendError(res, 'EMAIL_EXISTS', 'Bu login allaqachon ro\'yxatdan o\'tgan');

  const passwordHash = await bcrypt.hash(password, 12);
  const user = await prisma.user.create({
    data: { fullName, email, passwordHash, role },
    select: { id: true, fullName: true, email: true, role: true, avatar: true, createdAt: true },
  });

  const tokens = generateTokens(user.id, user.role);
  return sendSuccess(res, { user, ...tokens }, 'Ro\'yxatdan o\'tildi', 201);
};

// ─── Login ─────────────────────────────────────────────────────────────────
export const login = async (req: Request, res: Response) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) {
    return sendError(res, 'VALIDATION_ERROR', (parsed.error as any).errors[0].message);
  }

  const { email, password } = parsed.data;

  const user = await prisma.user.findUnique({ where: { email } });
  if (!user || !user.passwordHash) {
    return sendError(res, 'INVALID_CREDENTIALS', 'Login yoki parol noto\'g\'ri', 401);
  }

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) return sendError(res, 'INVALID_CREDENTIALS', 'Login yoki parol noto\'g\'ri', 401);

  const tokens = generateTokens(user.id, user.role);
  return sendSuccess(res, {
    user: {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
      avatar: user.avatar,
      createdAt: user.createdAt,
    },
    ...tokens,
  });
};

// ─── Refresh Token ──────────────────────────────────────────────────────────
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

// ─── Get Me ─────────────────────────────────────────────────────────────────
export const getMe = async (req: any, res: Response) => {
  try {
    const userId = req.user?.userId;
    if (!userId) return sendError(res, 'UNAUTHORIZED', 'Token berilmagan', 401);

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fullName: true,
        email: true,
        role: true,
        avatar: true,
        createdAt: true,
      },
    });
    if (!user) return sendError(res, 'USER_NOT_FOUND', 'Foydalanuvchi topilmadi', 404);

    return sendSuccess(res, { user });
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Server xatoligi', 500);
  }
};

// ─── Update Profile ─────────────────────────────────────────────────────────
export const updateProfile = async (req: any, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { fullName, avatar } = req.body;

    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        ...(fullName && { fullName }),
        ...(avatar && { avatar }),
      },
      select: { id: true, fullName: true, email: true, role: true, avatar: true, createdAt: true },
    });

    return sendSuccess(res, { user }, 'Profil yangilandi');
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Profilni yangilashda xatolik', 500);
  }
};

// ─── Change Password ─────────────────────────────────────────────────────────
export const changePassword = async (req: any, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return sendError(res, 'VALIDATION_ERROR', 'Barcha maydonlar to\'ldirilishi shart');
    }
    if (newPassword.length < 6) {
      return sendError(res, 'VALIDATION_ERROR', 'Yangi parol kamida 6 ta belgi bo\'lsin');
    }

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) return sendError(res, 'NOT_FOUND', 'Foydalanuvchi topilmadi', 404);

    const valid = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!valid) return sendError(res, 'WRONG_PASSWORD', 'Joriy parol noto\'g\'ri', 401);

    const passwordHash = await bcrypt.hash(newPassword, 12);
    await prisma.user.update({ where: { id: userId }, data: { passwordHash } });

    return sendSuccess(res, {}, 'Parol muvaffaqiyatli o\'zgartirildi');
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Parolni o\'zgartirishda xatolik', 500);
  }
};
