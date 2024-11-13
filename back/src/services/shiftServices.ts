import { IShift, IShiftDetail, ShiftModel } from "../models/DatabaseModels/shiftModel";

export class ShiftService {
  public constructor() {}

  public async getShifts(): Promise<IShift[]> {
    try {
      const result = await ShiftModel.find().exec();
      return result;
    } catch (err) {
      console.error("Error fetching shift data:", err);
      return [];
    }
  }

  public async getShiftsByMatricule(matricule: string): Promise<IShift | null> {
    try {
      const result = await ShiftModel.findOne({ 'matricules.matricule': matricule }).exec();
      return result;
    } catch (err) {
      console.error("Error fetching shift data:", err);
      return null;
    }
  }

  public async createShift(cafeName: string): Promise<IShift | null> {
    try {
      const newShift = new ShiftModel({ cafeName, matricules: [] });
      return await newShift.save();
    } catch (err) {
      console.error("Error creating new shift:", err);
      return null;
    }
  }

  public async addShiftDetail(cafeName: string, matricule: string, shiftDetail: IShiftDetail): Promise<IShift | null> {
    try {
      const result = await ShiftModel.findOneAndUpdate(
        { cafeName, 'matricules.matricule': matricule },
        { $push: { 'matricules.$.shifts': shiftDetail } },
        { new: true }
      ).exec();
      return result;
    } catch (err) {
      console.error("Error adding shift detail:", err);
      return null;
    }
  }

  public async updateShift(cafeName: string, matricule: string, date: Date, updatedShiftDetail: IShiftDetail): Promise<IShift | null> {
    try {
      const result = await ShiftModel.findOneAndUpdate(
        { cafeName, 'matricules.matricule': matricule, 'matricules.shifts.date': date },
        { $set: { 'matricules.$.shifts.$[elem]': updatedShiftDetail } },
        { new: true, arrayFilters: [{ 'elem.date': date }] }
      ).exec();
      return result;
    } catch (err) {
      console.error("Error updating shift detail:", err);
      return null;
    }
  }

  public async removeShiftDetail(cafeName: string, matricule: string, date: Date): Promise<IShift | null> {
    try {
      const result = await ShiftModel.findOneAndUpdate(
        { cafeName, 'matricules.matricule': matricule },
        { $pull: { 'matricules.$.shifts': { date: date } } },
        { new: true }
      ).exec();
      return result;
    } catch (err) {
      console.error("Error removing shift detail:", err);
      return null;
    }
  }

  public async isShiftDetailConfirmed(cafeName: string, matricule: string, date: Date): Promise<boolean | null> {
    try {
      const result = await ShiftModel.findOne(
        { cafeName, 'matricules.matricule': matricule, 'matricules.shifts.date': date },
        { 'matricules.$.shifts.$': 1 } 
      ).exec();

      if (result && result.matricules.length > 0) {
        const shift = result.matricules[0].shifts.find((s: IShiftDetail) => s.date === date);
        return shift ? shift.confirmed : null;
      }

      return null; 
    } catch (err) {
      console.error("Error checking if shift detail is confirmed:", err);
      return null;
    }
  }

  // Method to update the confirmed status of a shift detail
  public async updateShiftConfirmation(cafeName: string, matricule: string, date: Date, confirmed: boolean): Promise<IShift | null> {
    try {
      const result = await ShiftModel.findOneAndUpdate(// they say findOneAndUpdate is faster
        { cafeName, 'matricules.matricule': matricule, 'matricules.shifts.date': date },
        { $set: { 'matricules.$.shifts.$[elem].confirmed': confirmed } }, 
        { new: true, arrayFilters: [{ 'elem.date': date }] }
      ).exec();
      return result;
    } catch (err) {
      console.error("Error updating the confirmed status of shift detail:", err);
      return null;
    }
  }
}

export default ShiftService;
