import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { sendSuccess, sendError } from '../utils/response';

export const getLesson = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;
    const lesson = await prisma.lesson.findUnique({
      where: { id },
      include: {
        module: { select: { courseId: true, title: true } },
        assignments: true,
      }
    });
    
    if (!lesson) return sendError(res, 'NOT_FOUND', 'Dars topilmadi', 404);
    
    return sendSuccess(res, lesson);
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Darsni yuklashda xatolik', 500);
  }
};

export const getProgress = async (req: any, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { id: lessonId } = req.params;
    
    const progress = await prisma.progress.findUnique({
      where: { userId_lessonId: { userId, lessonId } },
    });
    
    return sendSuccess(res, progress || { watchedPct: 0, lastPos: 0 });
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Progressni yuklashda xatolik', 500);
  }
};

export const updateProgress = async (req: any, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { id: lessonId } = req.params;
    const { watchedPct, lastPos } = req.body;
    
    const progress = await prisma.progress.upsert({
      where: { userId_lessonId: { userId, lessonId } },
      update: {
        ...(watchedPct !== undefined && { watchedPct }),
        ...(lastPos !== undefined && { lastPos }),
      },
      create: {
        userId,
        lessonId,
        watchedPct: watchedPct || 0,
        lastPos: lastPos || 0,
      },
    });
    
    return sendSuccess(res, progress);
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Progressni yangilashda xatolik', 500);
  }
};
