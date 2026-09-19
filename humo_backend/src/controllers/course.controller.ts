import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { sendSuccess } from '../utils/response';

export const getCourses = async (req: Request, res: Response) => {
  const courses = await prisma.course.findMany({ include: { instructor: true } });
  return sendSuccess(res, courses);
};

export const createCourse = async (req: Request, res: Response) => {
  // Add creation logic
  return sendSuccess(res, {}, 'Course created', 201);
};
