"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const lesson_controller_1 = require("../controllers/lesson.controller");
const router = (0, express_1.Router)();
router.get('/:id', lesson_controller_1.getLesson);
router.get('/:id/progress', lesson_controller_1.getProgress);
exports.default = router;
