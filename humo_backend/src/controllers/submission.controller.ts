import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { sendSuccess, sendError } from '../utils/response';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'us-east-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
  }
});

export const getPresignedUrl = async (req: any, res: Response) => {
  try {
    const { filename, contentType } = req.body;
    if (!filename || !contentType) {
      return sendError(res, 'VALIDATION_ERROR', 'Fayl nomi va turi kiritilishi shart');
    }
    
    const key = `submissions/${req.user.userId}/${Date.now()}-${filename}`;
    const command = new PutObjectCommand({
      Bucket: process.env.AWS_S3_BUCKET || 'humo-online',
      Key: key,
      ContentType: contentType,
    });
    
    const url = await getSignedUrl(s3Client, command, { expiresIn: 3600 });
    const fileUrl = `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
    
    return sendSuccess(res, { uploadUrl: url, fileUrl });
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Presigned URL olishda xatolik', 500);
  }
};

export const submitAssignment = async (req: any, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { assignmentId } = req.params;
    const { fileUrls } = req.body;
    
    if (!fileUrls || !Array.isArray(fileUrls) || fileUrls.length === 0) {
      return sendError(res, 'VALIDATION_ERROR', 'Kamida bitta fayl yuklanishi kerak');
    }
    
    const existing = await prisma.submission.findFirst({
      where: { userId, assignmentId },
    });
    
    let submission;
    if (existing) {
      submission = await prisma.submission.update({
        where: { id: existing.id },
        data: {
          fileUrls,
          status: 'submitted',
        },
      });
    } else {
      submission = await prisma.submission.create({
        data: {
          userId,
          assignmentId,
          fileUrls,
          status: 'submitted',
        },
      });
    }
    
    return sendSuccess(res, submission, 'Vazifa muvaffaqiyatli topshirildi', 201);
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Vazifa topshirishda xatolik', 500);
  }
};

export const getMySubmission = async (req: any, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { assignmentId } = req.params;
    
    const submission = await prisma.submission.findFirst({
      where: { userId, assignmentId },
    });
    
    return sendSuccess(res, submission || null);
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Topshiriqni yuklashda xatolik', 500);
  }
};

export const getSubmissionById = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;
    const submission = await prisma.submission.findUnique({
      where: { id },
      include: {
        user: { select: { id: true, fullName: true, avatar: true } },
      }
    });
    
    if (!submission) return sendError(res, 'NOT_FOUND', 'Topshiriq topilmadi', 404);
    
    return sendSuccess(res, submission);
  } catch (err) {
    return sendError(res, 'SERVER_ERROR', 'Topshiriqni yuklashda xatolik', 500);
  }
};
