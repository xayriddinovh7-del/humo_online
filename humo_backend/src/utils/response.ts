import { Response } from 'express';

export const sendSuccess = (res: Response, data: any, message = 'OK', status = 200) => {
  return res.status(status).json({ success: true, data, message });
};

export const sendError = (res: Response, code: string, message: string, status = 400) => {
  return res.status(status).json({
    success: false,
    error: {
      code,
      message,
    }
  });
};
