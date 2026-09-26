"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getNotifications = exports.getStats = exports.updateProfile = exports.getProfile = void 0;
const prisma_1 = require("../utils/prisma");
const response_1 = require("../utils/response");
const getProfile = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const user = await prisma_1.prisma.user.findUnique({
            where: { id: userId },
            select: { id: true, fullName: true, email: true, role: true, avatar: true, createdAt: true },
        });
        if (!user)
            return (0, response_1.sendError)(res, 'NOT_FOUND', 'Profil topilmadi', 404);
        return (0, response_1.sendSuccess)(res, user);
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Profilni yuklashda xatolik', 500);
    }
};
exports.getProfile = getProfile;
const updateProfile = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const { fullName, avatar } = req.body;
        const user = await prisma_1.prisma.user.update({
            where: { id: userId },
            data: {
                ...(fullName && { fullName }),
                ...(avatar && { avatar }),
            },
            select: { id: true, fullName: true, email: true, role: true, avatar: true, createdAt: true },
        });
        return (0, response_1.sendSuccess)(res, user, 'Profil yangilandi');
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Profilni yangilashda xatolik', 500);
    }
};
exports.updateProfile = updateProfile;
const getStats = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const enrollments = await prisma_1.prisma.enrollment.count({ where: { userId } });
        const completedLessons = await prisma_1.prisma.progress.count({
            where: { userId, watchedPct: { gte: 90 } },
        });
        return (0, response_1.sendSuccess)(res, { enrollments, completedLessons });
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Statistikani yuklashda xatolik', 500);
    }
};
exports.getStats = getStats;
const getNotifications = async (req, res) => {
    // Buni hozircha mock qaytaraman, model hali tayyor bo'lmasa
    return (0, response_1.sendSuccess)(res, []);
};
exports.getNotifications = getNotifications;
