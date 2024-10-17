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
        this._router.post("/messages", authMiddleware, this.sendMessage.bind(this));
        this._router.get("/messages/:senderId/:receiverId", authMiddleware, this.getMessages.bind(this));
    }

    public get router(): Router {
        return this._router;
    }

    private async sendMessage(req: Request, res: Response) {
      const { senderId, receiverId, content } = req.body;

      try {
        await this.messageService.saveMessage(senderId, receiverId, content);
        res.status(201).json({ message: 'Message sent successfully.' });
      } catch (error) {
        res.status(400).json({ message: 'Error while sending message.', error });
      }
    }

    private async getMessages(req: Request, res: Response) {
      const { senderId, receiverId } = req.query;

      try {
        const messages = await this.messageService.getMessages(senderId as string, receiverId as string);
        res.status(200).json(messages);
      } catch (error) {
        res.status(400).json({ message: 'Error while fetching messages.', error });
      }
    }
}
