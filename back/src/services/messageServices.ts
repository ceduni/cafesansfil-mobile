import Message from '../models/DatabaseModels/messageModel';

export class MessageService {
  async saveMessage(senderId: string, receiverId: string, content: string) {
    const message = new Message({
        senderId,
        receiverId,
        content,
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

    return messages;
  }
}

export default MessageService;

