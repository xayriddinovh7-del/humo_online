import { Router } from 'express';
import { submitAssignment } from '../controllers/submission.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();
router.post('/submit', requireAuth, submitAssignment);
export default router;
