"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSubmissionById = exports.getMySubmission = exports.submitAssignment = exports.getPresignedUrl = void 0;
const prisma_1 = require("../utils/prisma");
const response_1 = require("../utils/response");
const client_s3_1 = require("@aws-sdk/client-s3");
const s3_request_presigner_1 = require("@aws-sdk/s3-request-presigner");
const s3Client = new client_s3_1.S3Client({
    region: process.env.AWS_REGION || 'us-east-1',
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
    }
});
const getPresignedUrl = async (req, res) => {
    try {
        const { filename, contentType } = req.body;
        if (!filename || !contentType) {
            return (0, response_1.sendError)(res, 'VALIDATION_ERROR', 'Fayl nomi va turi kiritilishi shart');
        }
        const key = `submissions/${req.user.userId}/${Date.now()}-${filename}`;
        const command = new client_s3_1.PutObjectCommand({
            Bucket: process.env.AWS_S3_BUCKET || 'humo-online',
            Key: key,
            ContentType: contentType,
        });
        const url = await (0, s3_request_presigner_1.getSignedUrl)(s3Client, command, { expiresIn: 3600 });
        const fileUrl = `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
        return (0, response_1.sendSuccess)(res, { uploadUrl: url, fileUrl });
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Presigned URL olishda xatolik', 500);
    }
};
exports.getPresignedUrl = getPresignedUrl;
const submitAssignment = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const { assignmentId } = req.params;
        const { fileUrls } = req.body;
        if (!fileUrls || !Array.isArray(fileUrls) || fileUrls.length === 0) {
            return (0, response_1.sendError)(res, 'VALIDATION_ERROR', 'Kamida bitta fayl yuklanishi kerak');
        }
        const existing = await prisma_1.prisma.submission.findFirst({
            where: { userId, assignmentId },
        });
        let submission;
        if (existing) {
            submission = await prisma_1.prisma.submission.update({
                where: { id: existing.id },
                data: {
                    fileUrls,
                    status: 'submitted',
                },
            });
        }
        else {
            submission = await prisma_1.prisma.submission.create({
                data: {
                    userId,
                    assignmentId,
                    fileUrls,
                    status: 'submitted',
                },
            });
        }
        return (0, response_1.sendSuccess)(res, submission, 'Vazifa muvaffaqiyatli topshirildi', 201);
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Vazifa topshirishda xatolik', 500);
    }
};
exports.submitAssignment = submitAssignment;
const getMySubmission = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const { assignmentId } = req.params;
        const submission = await prisma_1.prisma.submission.findFirst({
            where: { userId, assignmentId },
        });
        return (0, response_1.sendSuccess)(res, submission || null);
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Topshiriqni yuklashda xatolik', 500);
    }
};
exports.getMySubmission = getMySubmission;
const getSubmissionById = async (req, res) => {
    try {
        const id = req.params.id;
        const submission = await prisma_1.prisma.submission.findUnique({
            where: { id },
            include: {
                user: { select: { id: true, fullName: true, avatar: true } },
            }
        });
        if (!submission)
            return (0, response_1.sendError)(res, 'NOT_FOUND', 'Topshiriq topilmadi', 404);
        return (0, response_1.sendSuccess)(res, submission);
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Topshiriqni yuklashda xatolik', 500);
    }
};
exports.getSubmissionById = getSubmissionById;
