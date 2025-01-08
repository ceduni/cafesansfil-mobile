import Message from '../models/DatabaseModels/messageModel';
import { encryptMessage, decryptMessage } from '../middleware/encryptionService';

export class MessageService {
  /**
   * This function allow us to save the messages in the db
   * @param senderId 
   * @param receiverId 
   * @param content 
   * @returns 
   */
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

/**
 * this function allow us to retrieve the messages
 * @param senderId 
 * @param receiverId 
 * @returns 
 */
  async getMessages(senderId: string, receiverId: string) {
    const messages = await Message.find({
      $or: [
        { senderId, receiverId },
        { senderId: receiverId, receiverId: senderId },
      ],
    }).sort({ timestamp: 1 });

    // Decrypt the content of each message before returning
    return messages.map(message => ({
      ...message.toObject(), 
      content: decryptMessage(message.content), // Decrypt content
    }));
  }
}
export default MessageService;
