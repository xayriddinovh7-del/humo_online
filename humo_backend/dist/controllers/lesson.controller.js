"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateProgress = exports.getProgress = exports.getLesson = void 0;
const prisma_1 = require("../utils/prisma");
const response_1 = require("../utils/response");
const getLesson = async (req, res) => {
    try {
        const id = req.params.id;
        const lesson = await prisma_1.prisma.lesson.findUnique({
            where: { id },
            include: {
                module: { select: { courseId: true, title: true } },
                assignments: true,
            }
        });
        if (!lesson)
            return (0, response_1.sendError)(res, 'NOT_FOUND', 'Dars topilmadi', 404);
        return (0, response_1.sendSuccess)(res, lesson);
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Darsni yuklashda xatolik', 500);
    }
};
exports.getLesson = getLesson;
const getProgress = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const { id: lessonId } = req.params;
        const progress = await prisma_1.prisma.progress.findUnique({
            where: { userId_lessonId: { userId, lessonId } },
        });
        return (0, response_1.sendSuccess)(res, progress || { watchedPct: 0, lastPos: 0 });
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Progressni yuklashda xatolik', 500);
    }
};
exports.getProgress = getProgress;
const updateProgress = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const { id: lessonId } = req.params;
        const { watchedPct, lastPos } = req.body;
        const progress = await prisma_1.prisma.progress.upsert({
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
        return (0, response_1.sendSuccess)(res, progress);
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Progressni yangilashda xatolik', 500);
    }
};
exports.updateProgress = updateProgress;
