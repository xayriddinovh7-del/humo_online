import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { sendSuccess, sendError } from '../utils/response';

export const getLesson = async (req: Request, res: Response) => {
  const lesson = await prisma.lesson.findUnique({ where: { id: req.params.id as string } });
  if (!lesson) return sendError(res, 'NOT_FOUND', 'Lesson not found', 404);
  return sendSuccess(res, lesson);
};

export const getProgress = async (req: Request, res: Response) => {
  return sendSuccess(res, { watchedPct: 0 });
};
