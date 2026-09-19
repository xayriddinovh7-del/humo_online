"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendOtpEmail = void 0;
const sendOtpEmail = async (email, code) => {
    // Hozircha konsolga chiqaramiz, haqiqiy SMTP ma'lumotlari kiritilganda nodemailer ishlatiladi
    console.log(`\n============================`);
    console.log(`EMAIL: ${email}`);
    console.log(`OTP CODE: ${code}`);
    console.log(`============================\n`);
    return true;
};
exports.sendOtpEmail = sendOtpEmail;
