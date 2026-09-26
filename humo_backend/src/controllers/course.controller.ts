import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { sendSuccess, sendError } from '../utils/response';

export const getCourses = async (req: Request, res: Response) => {
  try {
    const courses = await prisma.course.findMany({
      include: {
        instructor: { select: { id: true, fullName: true, avatar: true } },
        _count: { select: { modules: true, enrollments: true } },
      },
    });
    return sendSuccess(res, courses);
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Kurslarni yuklashda xatolik', 500);
  }
};

export const getCourseById = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;
    const course = await prisma.course.findUnique({
      where: { id },
      include: {
        instructor: { select: { id: true, fullName: true, avatar: true } },
        modules: {
          include: {
            lessons: {
              orderBy: { order: 'asc' },
              select: { id: true, title: true, duration: true, order: true },
            },
          },
          orderBy: { order: 'asc' },
        },
        _count: { select: { enrollments: true } },
      },
    });
    
    if (!course) return sendError(res, 'NOT_FOUND', 'Kurs topilmadi', 404);
    
    return sendSuccess(res, course);
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Kursni yuklashda xatolik', 500);
  }
};

export const createCourse = async (req: any, res: Response) => {
  try {
    const userId = req.user?.userId;
    const role = req.user?.role;
    
    if (role !== 'TEACHER' && role !== 'ADMIN') {
      return sendError(res, 'FORBIDDEN', 'Faqat o\'qituvchilar kurs yarata oladi', 403);
    }
    
    const { title, description, category, thumbnail } = req.body;
    if (!title) return sendError(res, 'VALIDATION_ERROR', 'Kurs nomi kiritilishi shart');
    
    const course = await prisma.course.create({
      data: {
        title,
        description,
        category,
        thumbnail,
        instructorId: userId,
      },
    });
    
    return sendSuccess(res, course, 'Kurs muvaffaqiyatli yaratildi', 201);
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Kurs yaratishda xatolik', 500);
  }
};

export const enrollCourse = async (req: any, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { id: courseId } = req.params;
    
    const course = await prisma.course.findUnique({ where: { id: courseId } });
    if (!course) return sendError(res, 'NOT_FOUND', 'Kurs topilmadi', 404);
    
    const existing = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId, courseId } },
    });
    
    if (existing) {
      return sendError(res, 'ALREADY_ENROLLED', 'Siz bu kursga allaqachon a\'zo bo\'lgansiz', 400);
    }
    
    await prisma.enrollment.create({
      data: { userId, courseId },
    });
    
    return sendSuccess(res, {}, 'Kursga muvaffaqiyatli a\'zo bo\'ldingiz');
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'A\'zo bo\'lishda xatolik', 500);
  }
};
