"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createCourse = exports.getCourses = void 0;
const express_1 = require("express");
const prisma_1 = require("../utils/prisma");
const response_1 = require("../utils/response");
const getCourses = async (req, res) => {
    const courses = await prisma_1.prisma.course.findMany({ include: { instructor: true } });
    return (0, response_1.sendSuccess)(res, courses);
};
exports.getCourses = getCourses;
const createCourse = async (req, res) => {
    // Add creation logic
    return (0, response_1.sendSuccess)(res, {}, 'Course created', 201);
};
exports.createCourse = createCourse;
//# sourceMappingURL=course.controller.js.map