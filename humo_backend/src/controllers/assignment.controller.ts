import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { sendSuccess, sendError } from '../utils/response';

export const getAssignment = async (req: Request, res: Response) => {
  const assignment = await prisma.assignment.findUnique({ where: { id: req.params.id as string } });
  if (!assignment) return sendError(res, 'NOT_FOUND', 'Assignment not found', 404);
  return sendSuccess(res, assignment);
};
