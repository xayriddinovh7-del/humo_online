import { Router } from 'express';
import { getAssignment, getAssignmentsByLesson, createAssignment } from '../controllers/assignment.controller';
import { submitAssignment } from '../controllers/submission.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();

router.get('/:id', getAssignment);
router.get('/lesson/:lessonId', getAssignmentsByLesson);
router.post('/', requireAuth, createAssignment);
router.post('/:assignmentId/submit', requireAuth, submitAssignment);

export default router;
