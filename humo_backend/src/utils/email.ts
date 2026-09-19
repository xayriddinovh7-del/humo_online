export const sendOtpEmail = async (email: string, code: string) => {
  // Hozircha konsolga chiqaramiz, haqiqiy SMTP ma'lumotlari kiritilganda nodemailer ishlatiladi
  console.log(`\n============================`);
  console.log(`EMAIL: ${email}`);
  console.log(`OTP CODE: ${code}`);
  console.log(`============================\n`);
  return true;
};
