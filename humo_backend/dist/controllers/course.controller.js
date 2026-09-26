"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.enrollCourse = exports.createCourse = exports.getCourseById = exports.getCourses = void 0;
const prisma_1 = require("../utils/prisma");
const response_1 = require("../utils/response");
const getCourses = async (req, res) => {
    try {
        const courses = await prisma_1.prisma.course.findMany({
            include: {
                instructor: { select: { id: true, fullName: true, avatar: true } },
                _count: { select: { modules: true, enrollments: true } },
            },
        });
        return (0, response_1.sendSuccess)(res, courses);
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Kurslarni yuklashda xatolik', 500);
    }
};
exports.getCourses = getCourses;
const getCourseById = async (req, res) => {
    try {
        const id = req.params.id;
        const course = await prisma_1.prisma.course.findUnique({
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
        if (!course)
            return (0, response_1.sendError)(res, 'NOT_FOUND', 'Kurs topilmadi', 404);
        return (0, response_1.sendSuccess)(res, course);
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Kursni yuklashda xatolik', 500);
    }
};
exports.getCourseById = getCourseById;
const createCourse = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const role = req.user?.role;
        if (role !== 'TEACHER' && role !== 'ADMIN') {
            return (0, response_1.sendError)(res, 'FORBIDDEN', 'Faqat o\'qituvchilar kurs yarata oladi', 403);
        }
        const { title, description, category, thumbnail } = req.body;
        if (!title)
            return (0, response_1.sendError)(res, 'VALIDATION_ERROR', 'Kurs nomi kiritilishi shart');
        const course = await prisma_1.prisma.course.create({
            data: {
                title,
                description,
                category,
                thumbnail,
                instructorId: userId,
            },
        });
        return (0, response_1.sendSuccess)(res, course, 'Kurs muvaffaqiyatli yaratildi', 201);
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Kurs yaratishda xatolik', 500);
    }
};
exports.createCourse = createCourse;
const enrollCourse = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const { id: courseId } = req.params;
        const course = await prisma_1.prisma.course.findUnique({ where: { id: courseId } });
        if (!course)
            return (0, response_1.sendError)(res, 'NOT_FOUND', 'Kurs topilmadi', 404);
        const existing = await prisma_1.prisma.enrollment.findUnique({
            where: { userId_courseId: { userId, courseId } },
        });
        if (existing) {
            return (0, response_1.sendError)(res, 'ALREADY_ENROLLED', 'Siz bu kursga allaqachon a\'zo bo\'lgansiz', 400);
        }
        await prisma_1.prisma.enrollment.create({
            data: { userId, courseId },
        });
        return (0, response_1.sendSuccess)(res, {}, 'Kursga muvaffaqiyatli a\'zo bo\'ldingiz');
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'A\'zo bo\'lishda xatolik', 500);
    }
};
exports.enrollCourse = enrollCourse;
