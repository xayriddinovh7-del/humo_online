import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { sendSuccess, sendError } from '../utils/response';

export const getAssignment = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;
    const assignment = await prisma.assignment.findUnique({
      where: { id },
      include: {
        lesson: { select: { title: true, course: { select: { instructorId: true } } } as any },
      }
    });
    
    if (!assignment) return sendError(res, 'NOT_FOUND', 'Vazifa topilmadi', 404);
    
    return sendSuccess(res, assignment);
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Vazifani yuklashda xatolik', 500);
  }
};

export const getAssignmentsByLesson = async (req: Request, res: Response) => {
  try {
    const lessonId = req.params.lessonId as string;
    const assignments = await prisma.assignment.findMany({
      where: { lessonId },
      orderBy: { createdAt: 'asc' },
    });
    return sendSuccess(res, assignments);
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Vazifalarni yuklashda xatolik', 500);
  }
};

export const createAssignment = async (req: any, res: Response) => {
  try {
    const role = req.user?.role;
    if (role !== 'TEACHER' && role !== 'ADMIN') {
      return sendError(res, 'FORBIDDEN', 'Faqat o\'qituvchilar vazifa yarata oladi', 403);
    }
    
    const { lessonId, title, desc, maxScore, deadline } = req.body;
    
    if (!lessonId || !title || maxScore === undefined) {
      return sendError(res, 'VALIDATION_ERROR', 'Barcha kerakli maydonlarni to\'ldiring');
    }
    
    const assignment = await prisma.assignment.create({
      data: {
        lessonId,
        title,
        desc,
        maxScore: Number(maxScore),
        deadline: deadline ? new Date(deadline) : null,
      },
    });
    
    return sendSuccess(res, assignment, 'Vazifa yaratildi', 201);
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Vazifa yaratishda xatolik', 500);
  }
};
