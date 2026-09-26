import { Router } from 'express';
import { getCourses, getCourseById, createCourse, enrollCourse } from '../controllers/course.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();

router.get('/', getCourses);
router.get('/:id', getCourseById);
router.post('/', requireAuth, createCourse);
router.post('/:id/enroll', requireAuth, enrollCourse);

export default router;
