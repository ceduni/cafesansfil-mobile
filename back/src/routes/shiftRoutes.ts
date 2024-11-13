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
    this._router.get("/shifts/matricule/:matricule", this.getShiftByMatricule.bind(this));
    this._router.post("/shifts", this.createShift.bind(this));
    this._router.put("/shifts", this.updateShift.bind(this)); 
    this._router.post("/shifts/matricule/:matricule/details", this.addShiftDetail.bind(this));
    this._router.delete("/shifts/matricule/:matricule/details", this.removeShiftDetail.bind(this));
    this._router.get("/shifts/matricule/:matricule/details/confirmed/", this.checkShiftConfirmation.bind(this));
    this._router.put("/shifts/matricule/:matricule/details/confirmation", this.updateShiftConfirmation.bind(this));
  }

  public get router(): Router {
    return this._router;
  }

  public async getShift(req: Request, res: Response): Promise<void> {
    try {
      const shifts: IShift[] | null = await this.ShiftService.getShifts();
      res.status(200).send({
        message: "Success",
        shifts: shifts,
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
      const shifts: IShift | null = await this.ShiftService.getShiftsByMatricule(matricule);
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
      const { cafeName } = req.body;
      const newShift = await this.ShiftService.createShift(cafeName);
      res.status(201).send({
        message: "Shift created successfully",
        shift: newShift,
      });
    } catch (err) {
      console.error("Error in creating shift:", err);
      res.status(404).send({ message: "Internal Server Error", error: err });
    }
  }

  public async addShiftDetail(req: Request, res: Response): Promise<void> {
    try {
      const matricule  = req.params.matricule;
      const { shiftDetail } = req.body; 
      const updatedShift = await this.ShiftService.addShiftDetail(req.body.cafeName, matricule, shiftDetail);
      res.status(200).send({
        message: "Shift detail added successfully",
        shift: updatedShift,
      });
    } catch (err) {
      console.error("Error in adding shift detail:", err);
      res.status(404).send({ message: "Internal Server Error", error: err });
    }
  }

  public async updateShift(req: Request, res: Response): Promise<void> {
    try {
      const matricule  = req.params.matricule;
      const { date, updatedShiftDetail } = req.body;
      const updatedShift = await this.ShiftService.updateShift(req.body.cafeName, matricule, date, updatedShiftDetail);
      res.status(200).send({
        message: "Shift detail updated successfully",
        shift: updatedShift,
      });
    } catch (err) {
      console.error("Error in updating shift detail:", err);
      res.status(404).send({ message: "Internal Server Error", error: err });
    }
  }

  public async removeShiftDetail(req: Request, res: Response): Promise<void> {
    try {
      const matricule  = req.params.matricule;
      const { date } = req.body; 
      const updatedShift = await this.ShiftService.removeShiftDetail(req.body.cafeName, matricule, date);
      res.status(200).send({
        message: "Shift detail removed successfully",
        shift: updatedShift,
      });
    } catch (err) {
      console.error("Error in removing shift detail:", err);
      res.status(404).send({ message: "Internal Server Error", error: err });
    }
  }
  public async checkShiftConfirmation(req: Request, res: Response): Promise<void> {
    try {
      const matricule  = req.params.matricule;
      const { date } = req.body;
      const confirmed = await this.ShiftService.isShiftDetailConfirmed(req.body.cafeName, matricule, new Date(date));
      res.status(200).send({
        message: "Success",
        confirmed: confirmed,
      });
    } catch (err) {
      console.log("Error in checking shift confirmation:", err);
      res.status(404).send({
        message: "Internal Server Error",
        error: err,
      });
    }
  }
  
  // Method to update shift confirmation status
  public async updateShiftConfirmation(req: Request, res: Response): Promise<void> {
    try {
      const  matricule  = req.params.matricule;
      const { date, confirmed } = req.body;
      const updatedShift = await this.ShiftService.updateShiftConfirmation(req.body.cafeName, matricule, new Date(date), confirmed);
      res.status(200).send({
        message: "Shift confirmation updated successfully",
        shift: updatedShift,
      });
    } catch (err) {
      console.error("Error in updating shift confirmation:", err);
      res.status(404).send({ message: "Internal Server Error", error: err });
    }
  }

}
