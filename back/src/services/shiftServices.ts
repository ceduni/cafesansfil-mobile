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
      const result = await ShiftModel.findOne({ matricule: matricule }).exec();
      return result;
    } catch (err) {
      console.error("Error fetching shift data:", err);
      return null;
    }
  }
  public async createShift(newShift: IShift): Promise<IShift> {
    try {
        const shift = new ShiftModel(newShift);
        return await shift.save();
    } catch (err) {
        console.error("Error creating shift:", err);
        throw err;
    }
  }
  
  public async addShiftDetail(matricule: string, newShiftDetail: IShiftDetail): Promise<IShift | null> {
    try {
        const shift = await ShiftModel.findOne({ matricule: matricule }).exec(); // Find shift by matricule
        if (!shift) {
            throw new Error("Shift not found");
        }
        shift.shift.push(newShiftDetail); // Add new shift detail to the shift array
        return await shift.save(); // Save the updated shift
    } catch (err) {
        console.error("Error adding shift detail:", err);
        throw err;
    }
  }



  public async updateShift(id: string, updatedShift: Partial<IShift>): Promise<IShift | null> {
    try {
        const shift = await ShiftModel.findByIdAndUpdate(id, updatedShift, { new: true }).exec();
        return shift;
    } catch (err) {
        console.error("Error updating shift:", err);
        throw err;
    }
  }
  // New method for checking ownership
  public async shiftBelongsToUser(shiftId: string, userId: string): Promise<boolean> {
    try {
        const shift = await ShiftModel.findById(shiftId).exec();
        if (!shift) {
            return false;
        }
        return shift.matricule === userId; // Check ownership
    } catch (err) {
        console.error("Error checking shift ownership:", err);
        return false; // If there is an error
    }
  }
}

export default ShiftService;
