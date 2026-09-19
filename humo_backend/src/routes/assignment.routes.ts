import { Router } from 'express';
import { getAssignment } from '../controllers/assignment.controller';

const router = Router();
router.get('/:id', getAssignment);
export default router;
