"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAssignment = void 0;
const express_1 = require("express");
const prisma_1 = require("../utils/prisma");
const response_1 = require("../utils/response");
const getAssignment = async (req, res) => {
    const assignment = await prisma_1.prisma.assignment.findUnique({ where: { id: req.params.id } });
    if (!assignment)
        return (0, response_1.sendError)(res, 'NOT_FOUND', 'Assignment not found', 404);
    return (0, response_1.sendSuccess)(res, assignment);
};
exports.getAssignment = getAssignment;
//# sourceMappingURL=assignment.controller.js.map