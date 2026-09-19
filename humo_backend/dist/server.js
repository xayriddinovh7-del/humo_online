"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const dotenv_1 = __importDefault(require("dotenv"));
const auth_routes_1 = __importDefault(require("./routes/auth.routes"));
const course_routes_1 = __importDefault(require("./routes/course.routes"));
const lesson_routes_1 = __importDefault(require("./routes/lesson.routes"));
const assignment_routes_1 = __importDefault(require("./routes/assignment.routes"));
const submission_routes_1 = __importDefault(require("./routes/submission.routes"));
dotenv_1.default.config();
const app = (0, express_1.default)();
app.use((0, helmet_1.default)());
app.use((0, cors_1.default)());
app.use(express_1.default.json());
app.use('/api/v1/auth', auth_routes_1.default);
app.use('/api/v1/courses', course_routes_1.default);
app.use('/api/v1/lessons', lesson_routes_1.default);
app.use('/api/v1/assignments', assignment_routes_1.default);
app.use('/api/v1/submissions', submission_routes_1.default);
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
