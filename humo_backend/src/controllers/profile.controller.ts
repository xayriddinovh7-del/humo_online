import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { sendSuccess, sendError } from '../utils/response';

export const getProfile = async (req: any, res: Response) => {
  try {
    const userId = req.user?.userId;
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, fullName: true, email: true, role: true, avatar: true, createdAt: true },
    });
    
    if (!user) return sendError(res, 'NOT_FOUND', 'Profil topilmadi', 404);
    
    return sendSuccess(res, user);
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Profilni yuklashda xatolik', 500);
  }
};

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
    
    return sendSuccess(res, user, 'Profil yangilandi');
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Profilni yangilashda xatolik', 500);
  }
};

export const getStats = async (req: any, res: Response) => {
  try {
    const userId = req.user?.userId;
    
    const enrollments = await prisma.enrollment.count({ where: { userId } });
    const completedLessons = await prisma.progress.count({
      where: { userId, watchedPct: { gte: 90 } },
    });
    
    return sendSuccess(res, { enrollments, completedLessons });
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Statistikani yuklashda xatolik', 500);
  }
};

export const getNotifications = async (req: any, res: Response) => {
  // Buni hozircha mock qaytaraman, model hali tayyor bo'lmasa
  return sendSuccess(res, []);
};
