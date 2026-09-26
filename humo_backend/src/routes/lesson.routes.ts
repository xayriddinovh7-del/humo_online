import { Router } from 'express';
import { getLesson, getProgress, updateProgress } from '../controllers/lesson.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();

router.get('/:id', getLesson);
router.get('/:id/progress', requireAuth, getProgress);
router.post('/:id/progress', requireAuth, updateProgress);

export default router;
