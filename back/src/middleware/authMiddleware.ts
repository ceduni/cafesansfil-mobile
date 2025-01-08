import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { config } from 'dotenv';

config(); // Load environment variables

export const authMiddleware = (req: Request, res: Response, next: NextFunction) => {
    const token = req.headers.authorization?.split(" ")[1]; // Get the token from the Authorization header

    if (!token) {
        return res.status(403).send({ message: "Access denied, no token provided." });
    }

    try {
        console.log(token);
        const decoded = jwt.verify(token, process.env.PHRASE_PASS!); 
        req.user = decoded; 
        next(); // Proceed to the next middleware or route handler
    } catch (error) {
        console.error("Token verification failed:", error);
        return res.status(401).send({ message: "Invalid token." });
    }
};
