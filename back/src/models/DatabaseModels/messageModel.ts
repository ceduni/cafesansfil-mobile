import mongoose, { Document, Schema } from 'mongoose';

export interface IMessage extends Document {
    senderId: string;
    receiverId: string;
    content: string;
    timestamp: Date;
}

const messageSchema: Schema = new Schema({
    senderId: { type: String, required: true },
    receiverId: { type: String, required: true },
    content: { type: String, required: true },
    timestamp: { type: Date, default: Date.now }
});

const Message = mongoose.model<IMessage>('Message', messageSchema);
export default Message;
