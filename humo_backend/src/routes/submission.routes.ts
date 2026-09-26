import { Router } from 'express';
import { getSubmissionById, getMySubmission, getPresignedUrl } from '../controllers/submission.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();

router.get('/:id', requireAuth, getSubmissionById);
router.get('/my/:assignmentId', requireAuth, getMySubmission);
router.post('/upload/presigned-url', requireAuth, getPresignedUrl);

export default router;
