import CryptoJS from 'crypto-js';
import { config } from 'dotenv';

config(); // Load environment variables

const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || 'default_key';

export const encryptMessage = (message: string): string => {
    return CryptoJS.AES.encrypt(message, ENCRYPTION_KEY).toString();
};

export const decryptMessage = (encryptedMessage: string): string => {
    const bytes = CryptoJS.AES.decrypt(encryptedMessage, ENCRYPTION_KEY);
    return bytes.toString(CryptoJS.enc.Utf8);
};
