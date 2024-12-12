import { Router, Request, Response } from "express";

import ShiftService from "../services/shiftServices";
import { IShift } from "../models/DatabaseModels/shiftModel";

type DayOfWeek = 'monday' | 'tuesday' | 'wednesday' | 'thursday' | 'friday';

export class ShiftRoutes {
  private _router: Router;
  private ShiftService: ShiftService;

  constructor() {
    this._router = Router();
    this.ShiftService = new ShiftService();
    this.init();
  }

  private init() {
    this._router.get("/shifts/all", this.getAllShifts.bind(this)); // Get all shifts
    this._router.post("/shifts/:day/addStaff", this.addStaffToHour.bind(this)); // Add staff to hour
    this._router.delete("/shifts/:day/removeStaff", this.removeStaffFromHour.bind(this)); // Remove staff from hour
    this._router.put("/shifts/:day/:hourName/confirmStaff", this.confirmStaff.bind(this)); // Confirm staff with hourName
    this._router.get("/shifts/:cafeName/:day/:hourName/staff", this.getStaffList.bind(this));
  }

  public get router(): Router {
    return this._router;
  }

  public async getAllShifts(req: Request, res: Response): Promise<void> {
    try {
      
      const shifts: IShift[] = await this.ShiftService.getAllShifts();
      res.status(200).send({
        message: "Success",
        shifts: shifts,
      });
      
    } catch (error) {
      console.log("Error in getAllShifts:", error);
      res.status(404).send({
        message: "Internal Server Error",
        error: error,
      });
    }
  }

  public async addStaffToHour(req: Request, res: Response): Promise<void> {
    const { day } = req.params as { day: DayOfWeek };
    const { cafeName, hourName, matricule, name } = req.body; 
    try {
      const updatedShift = await this.ShiftService.addStaffToHour(cafeName, day, hourName, matricule, name);
      if (updatedShift) {
        res.status(200).send({
          message: "Staff added successfully",
          shift: updatedShift,
        });
      } else {
        res.status(404).send({
          message: "Shift not found or hour not found",
        });
      }
    } catch (error) {
      res.status(500).send({
        message: "Internal Server Error",
      });
    }
  }

  public async removeStaffFromHour(req: Request, res: Response): Promise<void> {
    const { cafeName, hourName, matricule } = req.body;
    const { day } = req.params as { day: DayOfWeek };
    try {
      const updatedShift = await this.ShiftService.removeStaffFromHour(cafeName, day, hourName, matricule);
      if (updatedShift) {
        res.status(200).send({
          message: "Staff removed successfully",
          shift: updatedShift,
        });
      } else {
        res.status(404).send({
          message: "Shift not found or hour not found",
        });
      }
    } catch (error) {
      res.status(500).send({
        message: "Internal Server Error",
      });
    }
  }

  public async confirmStaff(req: Request, res: Response): Promise<void> {
    const { cafeName, matricule } = req.body;
    const { day, hourName } = req.params as { day: DayOfWeek, hourName: string }; 
    try {
        const updatedShift = await this.ShiftService.confirmStaff(cafeName, day, hourName, matricule);
        if (updatedShift) {
            res.status(200).send({
                message: "Staff confirmed successfully",
                shift: updatedShift,
            });
        } else {
            res.status(404).send({
                message: "Shift not found or staff not found",
            });
        }
    } catch (error) {
        res.status(500).send({
            message: "Internal Server Error",
        });
    }
  }

  public async getStaffList(req: Request, res: Response): Promise<void> {
    const { cafeName, day, hourName } = req.params as {cafeName:string, day: DayOfWeek, hourName: string };
    try {
      const staffList = await this.ShiftService.getStaffList(cafeName, day, hourName);
      if (staffList) {
        res.status(200).send({
          message: "Staff list retrieved successfully",
          staff: staffList,
        });
      } else {
        res.status(404).send({
          message: "Shift not found or staff list not available",
        });
      }
    } catch (error) {
      res.status(500).send({
        message: "Internal Server Error",
      });
    }
  }
}
