import { Router } from 'express';
import { getCourses, createCourse } from '../controllers/course.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();
router.get('/', getCourses);
router.post('/', requireAuth, createCourse);
export default router;
