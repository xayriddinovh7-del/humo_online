import { Response } from 'express';
export declare const sendSuccess: (res: Response, data: any, message?: string, status?: number) => Response<any, Record<string, any>>;
export declare const sendError: (res: Response, code: string, message: string, status?: number) => Response<any, Record<string, any>>;
//# sourceMappingURL=response.d.ts.map