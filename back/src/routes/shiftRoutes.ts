import { Router, Request, Response } from "express";

import { IUser } from "../models/DatabaseModels/userModel";
import ShiftService from "../services/shiftServices";
import { IShift, IShiftDetail, ShiftModel } from "../models/DatabaseModels/shiftModel";

export class ShiftRoutes {
  private _router: Router;
  private ShiftService: ShiftService;
  constructor() {
    this._router = Router();
    this.ShiftService = new ShiftService();
    this.init();
  }

  private init() {
    this._router.get("/shifts", this.getShift.bind(this));
    this._router.get(
      "/shifts/matricule/:matricule",
      this.getShiftByMatricule.bind(this)
    );
    this._router.post("/shifts", this.createShift.bind(this));
    this._router.put("/shifts/:id", this.updateShift.bind(this));
    this._router.post("/shifts/matricule/:matricule/details", this.addShiftDetail.bind(this));
  }

  public get router(): Router {
    return this._router;
  }

  public async getShift(req: Request, res: Response): Promise<void> {
    try {
      const Shifts: IShift[] | null = await this.ShiftService.getShifts();
      res.status(200).send({
        message: "Success",
        Shifts: Shifts,
      });
    } catch (error) {
      console.log("Error in the getShift:", error);
      res.status(500).send({
        message: "Internal Server Error",
        error: error,
      });
    }
  }

  public async getShiftByMatricule(req: Request, res: Response): Promise<void> {
    try {
      const matricule = req.params.matricule;
      const shifts: IShift | null =
        await this.ShiftService.getShiftsByMatricule(matricule);
      res.status(200).send({
        message: "Success",
        shifts: shifts,
      });
    } catch (err) {
      console.log("Error in the getShiftByMatricule:", err);
      res.status(500).send({
        message: "Internal Server Error",
        error: err,
      });
    }
  }
  public async createShift(req: Request, res: Response): Promise<void> {
    try {
        const newShift = req.body; 
        const createdShift = await this.ShiftService.createShift(newShift);
        res.status(201).send(createdShift);
    } catch (error) {
        console.log("Error in the createShift:", error);
        res.status(500).send({
            message: "Internal Server Error",
            error: error,
        });
    }
  }

  public async addShiftDetail(req: Request, res: Response): Promise<void> {
    try {
        const matricule = req.params.matricule; // Get matricule from params
        const newShiftDetail = req.body; // New shift detail from request body
        const updatedShift = await this.ShiftService.addShiftDetail(matricule, newShiftDetail); // Pass matricule
        res.status(200).send(updatedShift);
    } catch (error) {
        console.log("Error in the addShiftDetail:", error);
        res.status(500).send({
            message: "Internal Server Error",
            error: error,
        });
    }
  }



  public async updateShift(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params; // Get shift ID from params
      const updatedShiftData = req.body; // Assume it contains the necessary fields
      const userId = req.body.matricule; // Assume userId comes from request body

      const ownsShift = await this.ShiftService.shiftBelongsToUser(id, userId);
      if (!ownsShift) {
        res.status(403).send({ message: "You do not have permission to update this shift." });
        return;
      }

      const updatedShift = await this.ShiftService.updateShift(id, updatedShiftData);
      if (!updatedShift) {
        res.status(404).send({ message: "Shift not found" });
        return;
      }
      res.status(200).send(updatedShift);
    } catch (error) {
      console.log("Error in the updateShift:", error);
      res.status(500).send({
        message: "Internal Server Error",
        error: error,
      });
    }
  }

}
