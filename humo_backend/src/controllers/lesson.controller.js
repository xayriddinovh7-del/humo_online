"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getProgress = exports.getLesson = void 0;
const express_1 = require("express");
const prisma_1 = require("../utils/prisma");
const response_1 = require("../utils/response");
const getLesson = async (req, res) => {
    const lesson = await prisma_1.prisma.lesson.findUnique({ where: { id: req.params.id } });
    if (!lesson)
        return (0, response_1.sendError)(res, 'NOT_FOUND', 'Lesson not found', 404);
    return (0, response_1.sendSuccess)(res, lesson);
};
exports.getLesson = getLesson;
const getProgress = async (req, res) => {
    return (0, response_1.sendSuccess)(res, { watchedPct: 0 });
};
exports.getProgress = getProgress;
//# sourceMappingURL=lesson.controller.js.map