"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createAssignment = exports.getAssignmentsByLesson = exports.getAssignment = void 0;
const prisma_1 = require("../utils/prisma");
const response_1 = require("../utils/response");
const getAssignment = async (req, res) => {
    try {
        const id = req.params.id;
        const assignment = await prisma_1.prisma.assignment.findUnique({
            where: { id },
            include: {
                lesson: { select: { title: true, course: { select: { instructorId: true } } } },
            }
        });
        if (!assignment)
            return (0, response_1.sendError)(res, 'NOT_FOUND', 'Vazifa topilmadi', 404);
        return (0, response_1.sendSuccess)(res, assignment);
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Vazifani yuklashda xatolik', 500);
    }
};
exports.getAssignment = getAssignment;
const getAssignmentsByLesson = async (req, res) => {
    try {
        const lessonId = req.params.lessonId;
        const assignments = await prisma_1.prisma.assignment.findMany({
            where: { lessonId },
            orderBy: { createdAt: 'asc' },
        });
        return (0, response_1.sendSuccess)(res, assignments);
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Vazifalarni yuklashda xatolik', 500);
    }
};
exports.getAssignmentsByLesson = getAssignmentsByLesson;
const createAssignment = async (req, res) => {
    try {
        const role = req.user?.role;
        if (role !== 'TEACHER' && role !== 'ADMIN') {
            return (0, response_1.sendError)(res, 'FORBIDDEN', 'Faqat o\'qituvchilar vazifa yarata oladi', 403);
        }
        const { lessonId, title, desc, maxScore, deadline } = req.body;
        if (!lessonId || !title || maxScore === undefined) {
            return (0, response_1.sendError)(res, 'VALIDATION_ERROR', 'Barcha kerakli maydonlarni to\'ldiring');
        }
        const assignment = await prisma_1.prisma.assignment.create({
            data: {
                lessonId,
                title,
                desc,
                maxScore: Number(maxScore),
                deadline: deadline ? new Date(deadline) : null,
            },
        });
        return (0, response_1.sendSuccess)(res, assignment, 'Vazifa yaratildi', 201);
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Vazifa yaratishda xatolik', 500);
    }
};
exports.createAssignment = createAssignment;
