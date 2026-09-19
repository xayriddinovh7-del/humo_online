"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const course_controller_1 = require("../controllers/course.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const router = (0, express_1.Router)();
router.get('/', course_controller_1.getCourses);
router.post('/', auth_middleware_1.requireAuth, course_controller_1.createCourse);
exports.default = router;
//# sourceMappingURL=course.routes.js.map