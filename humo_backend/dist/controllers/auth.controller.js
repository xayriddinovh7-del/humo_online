"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.changePassword = exports.updateProfile = exports.getMe = exports.refreshToken = exports.login = exports.register = void 0;
const bcrypt_1 = __importDefault(require("bcrypt"));
const zod_1 = require("zod");
const prisma_1 = require("../utils/prisma");
const jwt_1 = require("../utils/jwt");
const response_1 = require("../utils/response");
const registerSchema = zod_1.z.object({
    fullName: zod_1.z.string().min(2, 'Ism kamida 2 ta belgi'),
    email: zod_1.z.string().min(3, 'Login kiritilishi shart'),
    password: zod_1.z.string().min(6, 'Parol kamida 6 ta belgi'),
    role: zod_1.z.enum(['STUDENT', 'TEACHER']).default('STUDENT'),
});
const loginSchema = zod_1.z.object({
    email: zod_1.z.string().min(3),
    password: zod_1.z.string(),
});
// ─── Register ──────────────────────────────────────────────────────────────
const register = async (req, res) => {
    const parsed = registerSchema.safeParse(req.body);
    if (!parsed.success) {
        return (0, response_1.sendError)(res, 'VALIDATION_ERROR', parsed.error.errors[0].message);
    }
    const { fullName, email, password, role } = parsed.data;
    const exists = await prisma_1.prisma.user.findUnique({ where: { email } });
    if (exists)
        return (0, response_1.sendError)(res, 'EMAIL_EXISTS', 'Bu login allaqachon ro\'yxatdan o\'tgan');
    const passwordHash = await bcrypt_1.default.hash(password, 12);
    const user = await prisma_1.prisma.user.create({
        data: { fullName, email, passwordHash, role },
        select: { id: true, fullName: true, email: true, role: true, avatar: true, createdAt: true },
    });
    const tokens = (0, jwt_1.generateTokens)(user.id, user.role);
    return (0, response_1.sendSuccess)(res, { user, ...tokens }, 'Ro\'yxatdan o\'tildi', 201);
};
exports.register = register;
// ─── Login ─────────────────────────────────────────────────────────────────
const login = async (req, res) => {
    const parsed = loginSchema.safeParse(req.body);
    if (!parsed.success) {
        return (0, response_1.sendError)(res, 'VALIDATION_ERROR', parsed.error.errors[0].message);
    }
    const { email, password } = parsed.data;
    const user = await prisma_1.prisma.user.findUnique({ where: { email } });
    if (!user || !user.passwordHash) {
        return (0, response_1.sendError)(res, 'INVALID_CREDENTIALS', 'Login yoki parol noto\'g\'ri', 401);
    }
    const valid = await bcrypt_1.default.compare(password, user.passwordHash);
    if (!valid)
        return (0, response_1.sendError)(res, 'INVALID_CREDENTIALS', 'Login yoki parol noto\'g\'ri', 401);
    const tokens = (0, jwt_1.generateTokens)(user.id, user.role);
    return (0, response_1.sendSuccess)(res, {
        user: {
            id: user.id,
            fullName: user.fullName,
            email: user.email,
            role: user.role,
            avatar: user.avatar,
            createdAt: user.createdAt,
        },
        ...tokens,
    });
};
exports.login = login;
// ─── Refresh Token ──────────────────────────────────────────────────────────
const refreshToken = async (req, res) => {
    const { refreshToken } = req.body;
    if (!refreshToken)
        return (0, response_1.sendError)(res, 'NO_TOKEN', 'Refresh token yo\'q', 401);
    try {
        const { userId } = (0, jwt_1.verifyRefreshToken)(refreshToken);
        const user = await prisma_1.prisma.user.findUnique({ where: { id: userId } });
        if (!user)
            return (0, response_1.sendError)(res, 'USER_NOT_FOUND', 'Foydalanuvchi topilmadi', 404);
        const tokens = (0, jwt_1.generateTokens)(user.id, user.role);
        return (0, response_1.sendSuccess)(res, tokens);
    }
    catch {
        return (0, response_1.sendError)(res, 'TOKEN_INVALID', 'Token yaroqsiz', 401);
    }
};
exports.refreshToken = refreshToken;
// ─── Get Me ─────────────────────────────────────────────────────────────────
const getMe = async (req, res) => {
    try {
        const userId = req.user?.userId;
        if (!userId)
            return (0, response_1.sendError)(res, 'UNAUTHORIZED', 'Token berilmagan', 401);
        const user = await prisma_1.prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                fullName: true,
                email: true,
                role: true,
                avatar: true,
                createdAt: true,
            },
        });
        if (!user)
            return (0, response_1.sendError)(res, 'USER_NOT_FOUND', 'Foydalanuvchi topilmadi', 404);
        return (0, response_1.sendSuccess)(res, { user });
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Server xatoligi', 500);
    }
};
exports.getMe = getMe;
// ─── Update Profile ─────────────────────────────────────────────────────────
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
        return (0, response_1.sendSuccess)(res, { user }, 'Profil yangilandi');
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Profilni yangilashda xatolik', 500);
    }
};
exports.updateProfile = updateProfile;
// ─── Change Password ─────────────────────────────────────────────────────────
const changePassword = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const { currentPassword, newPassword } = req.body;
        if (!currentPassword || !newPassword) {
            return (0, response_1.sendError)(res, 'VALIDATION_ERROR', 'Barcha maydonlar to\'ldirilishi shart');
        }
        if (newPassword.length < 6) {
            return (0, response_1.sendError)(res, 'VALIDATION_ERROR', 'Yangi parol kamida 6 ta belgi bo\'lsin');
        }
        const user = await prisma_1.prisma.user.findUnique({ where: { id: userId } });
        if (!user)
            return (0, response_1.sendError)(res, 'NOT_FOUND', 'Foydalanuvchi topilmadi', 404);
        const valid = await bcrypt_1.default.compare(currentPassword, user.passwordHash);
        if (!valid)
            return (0, response_1.sendError)(res, 'WRONG_PASSWORD', 'Joriy parol noto\'g\'ri', 401);
        const passwordHash = await bcrypt_1.default.hash(newPassword, 12);
        await prisma_1.prisma.user.update({ where: { id: userId }, data: { passwordHash } });
        return (0, response_1.sendSuccess)(res, {}, 'Parol muvaffaqiyatli o\'zgartirildi');
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'SERVER_ERROR', 'Parolni o\'zgartirishda xatolik', 500);
    }
};
exports.changePassword = changePassword;
