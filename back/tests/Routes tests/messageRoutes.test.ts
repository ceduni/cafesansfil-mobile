import request from "supertest";
import { MainController } from "../../src/contollers/mainController";
import { MessageService } from "../../src/services/messageServices";

jest.mock("../../src/services/messageServices");

let server: MainController;
const mockMessage = {
  senderId: "user1",
  receiverId: "user2",
  content: "This is a test message.",
  timestamp: new Date(),
};

beforeAll(() => {
  server = new MainController();
});

afterAll(async () => {
  await server.closeDatabaseConnection();
});

describe("MessageRoutes", () => {
  describe("POST /messages", () => {
    it("should send a message successfully", async () => {
      (MessageService.prototype.saveMessage as jest.Mock).mockResolvedValue(mockMessage);

      const response = await request(server.App)
        .post("/messages")
        .send(mockMessage);

      expect(response.status).toBe(200);
      expect(response.body.message).toBe("Message sent successfully");
      expect(response.body.data).toEqual(mockMessage);
    });

    it("should return an error if sending a message fails", async () => {
      (MessageService.prototype.saveMessage as jest.Mock).mockRejectedValue(new Error("Error"));

      const response = await request(server.App)
        .post("/messages")
        .send(mockMessage);

      expect(response.status).toBe(500);
      expect(response.body.message).toBe("Internal Server Error");
    });
  });

  describe("GET /messages/:senderId/:receiverId", () => {
    it("should return messages successfully", async () => {
      (MessageService.prototype.getMessages as jest.Mock).mockResolvedValue([mockMessage]);

      const response = await request(server.App)
        .get(`/messages/${mockMessage.senderId}/${mockMessage.receiverId}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveLength(1);
      expect(response.body[0]).toEqual(mockMessage);
    });

    it("should return an error if fetching messages fails", async () => {
      (MessageService.prototype.getMessages as jest.Mock).mockRejectedValue(new Error("Error"));

      const response = await request(server.App)
        .get(`/messages/${mockMessage.senderId}/${mockMessage.receiverId}`);

      expect(response.status).toBe(500);
      expect(response.body.message).toBe("Internal Server Error");
    });
  });
});
