import MessageService from '../../src/services/messageServices';
import Message from '../../src/models/DatabaseModels/messageModel';
import { encryptMessage, decryptMessage } from '../../src/middleware/encryptionService';

jest.mock('../../src/models/DatabaseModels/messageModel'); // Mock the Message model
jest.mock('../../src/middleware/encryptionService'); // Mock the encryption and decryption services

let messageService: MessageService;

beforeEach(() => {
    messageService = new MessageService();
});

describe("MessageService Tests", () => {
    describe("saveMessage", () => {
        it("should save a message and return it", async () => {
            const mockMessage = {
                senderId: "user1",
                receiverId: "user2",
                content: "Hello!",
                timestamp: new Date(),
            };

            (encryptMessage as jest.Mock).mockReturnValue("encryptedHello!");
            (Message.prototype.save as jest.Mock).mockResolvedValue(mockMessage);

            const result = await messageService.saveMessage(mockMessage.senderId, mockMessage.receiverId, mockMessage.content);
            expect(result).toEqual(mockMessage);
            expect(Message.prototype.save).toHaveBeenCalled();
        });
    });

    describe("getMessages", () => {
        it("should return decrypted messages", async () => {
            const mockMessages = [
                { toObject: () => ({ senderId: "user1", receiverId: "user2", content: "encryptedHello!", timestamp: new Date() }) },
                { toObject: () => ({ senderId: "user2", receiverId: "user1", content: "encryptedHi!", timestamp: new Date() }) },
            ];

            (Message.find as jest.Mock).mockResolvedValue(mockMessages);
            (decryptMessage as jest.Mock).mockReturnValueOnce("Hello!").mockReturnValueOnce("Hi!");

            const result = await messageService.getMessages("user1", "user2");
            expect(result).toHaveLength(2);
            expect(result[0].content).toBe("Hello!");
            expect(result[1].content).toBe("Hi!");
        });
    });
});
