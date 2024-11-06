import Message from '../models/DatabaseModels/messageModel';
import { encryptMessage, decryptMessage } from '../middleware/encryptionService';

export class MessageService {
  async saveMessage(senderId: string, receiverId: string, content: string) {
    const encryptedContent = encryptMessage(content); // Encrypt the message content
    const message = new Message({
      senderId,
      receiverId,
      content: encryptedContent, // Store encrypted content
      timestamp: new Date(),
    });
    return await message.save();
  }

  async getMessages(senderId: string, receiverId: string) {
    const messages = await Message.find({
      $or: [
        { senderId, receiverId },
        { senderId: receiverId, receiverId: senderId },
      ],
    }).sort({ timestamp: 1 });

    // Decrypt the content of each message before returning
    return messages.map(message => ({
      ...message.toObject(), // Convert mongoose document to plain object
      content: decryptMessage(message.content), // Decrypt content
    }));
  }
}
export default MessageService;
