import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { sendSuccess } from '../utils/response';

export const submitAssignment = async (req: Request, res: Response) => {
  return sendSuccess(res, {}, 'Submitted', 201);
};
