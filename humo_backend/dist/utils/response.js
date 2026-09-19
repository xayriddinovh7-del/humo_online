"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendError = exports.sendSuccess = void 0;
const sendSuccess = (res, data, message = 'OK', status = 200) => {
    return res.status(status).json({ success: true, data, message });
};
exports.sendSuccess = sendSuccess;
const sendError = (res, code, message, status = 400) => {
    return res.status(status).json({
        success: false,
        error: {
            code,
            message,
        }
    });
};
exports.sendError = sendError;
