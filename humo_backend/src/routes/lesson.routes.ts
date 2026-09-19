import { Router } from 'express';
import { getLesson, getProgress } from '../controllers/lesson.controller';

const router = Router();
router.get('/:id', getLesson);
router.get('/:id/progress', getProgress);
export default router;
