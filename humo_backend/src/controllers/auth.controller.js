"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.refreshToken = exports.login = exports.register = void 0;
const express_1 = require("express");
const bcrypt_1 = __importDefault(require("bcrypt"));
const zod_1 = require("zod");
const prisma_1 = require("../utils/prisma");
const jwt_1 = require("../utils/jwt");
const response_1 = require("../utils/response");
const email_1 = require("../utils/email");
const registerSchema = zod_1.z.object({
    fullName: zod_1.z.string().min(2),
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(6),
});
const loginSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    password: zod_1.z.string(),
});
const register = async (req, res) => {
    const parsed = registerSchema.safeParse(req.body);
    if (!parsed.success) {
        return (0, response_1.sendError)(res, 'VALIDATION_ERROR', parsed.error.errors[0].message);
    }
    const { fullName, email, password } = parsed.data;
    const exists = await prisma_1.prisma.user.findUnique({ where: { email } });
    if (exists)
        return (0, response_1.sendError)(res, 'EMAIL_EXISTS', 'Bu email allaqachon ro\'yxatdan o\'tgan');
    const passwordHash = await bcrypt_1.default.hash(password, 12);
    const user = await prisma_1.prisma.user.create({
        data: { fullName, email, passwordHash },
        select: { id: true, fullName: true, email: true, role: true },
    });
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    await prisma_1.prisma.otpCode.create({
        data: {
            userId: user.id,
            code,
            type: 'EMAIL_VERIFY',
            expiresAt: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
        },
    });
    await (0, email_1.sendOtpEmail)(email, code);
    const tokens = (0, jwt_1.generateTokens)(user.id, user.role);
    return (0, response_1.sendSuccess)(res, { user, ...tokens }, 'Ro\'yxatdan o\'tildi', 201);
};
exports.register = register;
const login = async (req, res) => {
    const parsed = loginSchema.safeParse(req.body);
    if (!parsed.success) {
        return (0, response_1.sendError)(res, 'VALIDATION_ERROR', parsed.error.errors[0].message);
    }
    const { email, password } = parsed.data;
    const user = await prisma_1.prisma.user.findUnique({ where: { email } });
    if (!user || !user.passwordHash) {
        return (0, response_1.sendError)(res, 'INVALID_CREDENTIALS', 'Email yoki parol noto\'g\'ri', 401);
    }
    const valid = await bcrypt_1.default.compare(password, user.passwordHash);
    if (!valid)
        return (0, response_1.sendError)(res, 'INVALID_CREDENTIALS', 'Email yoki parol noto\'g\'ri', 401);
    const tokens = (0, jwt_1.generateTokens)(user.id, user.role);
    return (0, response_1.sendSuccess)(res, {
        user: { id: user.id, fullName: user.fullName, email: user.email, role: user.role },
        ...tokens,
    });
};
exports.login = login;
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
//# sourceMappingURL=auth.controller.js.map