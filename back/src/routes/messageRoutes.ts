import { Router, Request, Response } from "express";
import { MessageService } from '../services/messageServices';
import { authMiddleware } from '../middleware/authMiddleware';

export class MessageRoutes {
    private _router: Router;
    private messageService: MessageService;

    constructor() {
        this._router = Router();
        this.messageService = new MessageService();
        this.init();
    }

    private init() {
        this._router.post("/messages", this.sendMessage.bind(this));
        this._router.get("/messages/:senderId/:receiverId", authMiddleware, this.getMessages.bind(this));
    }

    public get router(): Router {
        return this._router;
    }

    public async sendMessage(req: Request, res: Response) {
      try {
          const { senderId, receiverId, content } = req.body;
          const message = await this.messageService.saveMessage(senderId, receiverId, content); // Save and return the message
          res.status(200).send({
              message: "Message sent successfully",
              data: message, // Return the message data
          });
      } catch (err) {
          console.error("Error sending message:", err);
          res.status(500).send({ message: "Internal Server Error", error: err });
      }
  }
  
    public async getMessages(req: Request, res: Response) {
      try {
        // Extract senderId and receiverId from the route parameters instead of query
        const { senderId, receiverId } = req.params;
        const messages = await this.messageService.getMessages(senderId, receiverId);
        res.status(200).send(messages);
      } catch (err) {
        console.error("Error fetching messages:", err);
        res.status(500).send({ message: "Internal Server Error", error: err });
      }
    }
    
}
