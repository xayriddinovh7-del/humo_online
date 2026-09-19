"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.submitAssignment = void 0;
const response_1 = require("../utils/response");
const submitAssignment = async (req, res) => {
    return (0, response_1.sendSuccess)(res, {}, 'Submitted', 201);
};
exports.submitAssignment = submitAssignment;
