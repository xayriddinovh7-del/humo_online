"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuth = void 0;
const express_1 = require("express");
const jwt_1 = require("../utils/jwt");
const response_1 = require("../utils/response");
const requireAuth = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return (0, response_1.sendError)(res, 'UNAUTHORIZED', 'Token berilmagan', 401);
    }
    const token = authHeader.split(' ')[1];
    try {
        const decoded = (0, jwt_1.verifyAccessToken)(token);
        req.user = decoded;
        next();
    }
    catch (err) {
        return (0, response_1.sendError)(res, 'UNAUTHORIZED', 'Yaroqsiz token', 401);
    }
};
exports.requireAuth = requireAuth;
//# sourceMappingURL=auth.middleware.js.map