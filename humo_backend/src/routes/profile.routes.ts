import { Router } from 'express';
import { getProfile, updateProfile, getStats, getNotifications } from '../controllers/profile.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();

router.use(requireAuth);

router.get('/', getProfile);
router.put('/', updateProfile);
router.get('/stats', getStats);
router.get('/notifications', getNotifications);

export default router;
