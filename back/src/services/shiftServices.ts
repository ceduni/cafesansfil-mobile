import { IShift, ShiftModel, IStaff } from "../models/DatabaseModels/shiftModel";

// Define a type for the days of the week that are valid keys
type DayOfTheWeek = 'monday' | 'tuesday' | 'wednesday' | 'thursday' | 'friday';

export class ShiftService {
  public constructor() {}

  // Retrieve all shifts
  public async getAllShifts(): Promise<IShift[]> {
    try {
      return await ShiftModel.find().exec();
    } catch (err) {
      console.error("Error fetching all shifts:", err);
      return [];
    }
  }

  // Add staff to a specific hour on a specific day
  public async addStaffToHour(cafeName: string, day: DayOfTheWeek, hourName: string, matricule: string, name: string): Promise<IShift | null> {
    try {
      const shift = await ShiftModel.findOne({ cafe_name: cafeName });
      if (shift) {
        const targetHour = shift.shifts[day]?.hours.find(hr => hr.hourName === hourName);
        if (targetHour) {

          const existingStaff = targetHour.staff.find(staff => staff.matricule === matricule);
          if (existingStaff) {
            return null;
          }
          targetHour.staff.push({ matricule, set: false, name });
          await shift.save();
          console.log(shift);
          return shift;
        }
      }
      return null;
    } catch (err) {
      console.error("Error adding staff to hour:", err);
      return null;
    }
  }


  // Remove staff from a specific hour on a specific day
  public async removeStaffFromHour(cafeName: string, day: DayOfTheWeek, hourName: string, matricule: string): Promise<IShift | null> {
    try {
      const shift = await ShiftModel.findOne({ cafe_name: cafeName });
      if (shift) {
        const targetHour = shift.shifts[day]?.hours.find(hr => hr.hourName === hourName);
        if (targetHour) {
          targetHour.staff = targetHour.staff.filter(staff => staff.matricule !== matricule); // Remove staff
          await shift.save();
          return shift;
        }
      }
      return null;
    } catch (err) {
      console.error("Error removing staff from hour:", err);
      return null;
    }
  }

  // Confirm staff for a specific hour on a specific day
  public async confirmStaff(cafeName: string, day: DayOfTheWeek, hourName: string, matricule: string): Promise<IShift | null> {
    try {
        const shift = await ShiftModel.findOne({ cafe_name: cafeName });
        if (shift) {
            const targetHour = shift.shifts[day]?.hours.find(hr => hr.hourName === hourName);
            if (targetHour) {
                const staff = targetHour.staff.find(staff => staff.matricule === matricule);
                if (staff) {
                    staff.set = true; // Set confirmed to true
                    await shift.save();
                    return shift;
                }
            }
        }
        return null;
    } catch (err) {
        console.error("Error confirming staff:", err);
        return null;
    }
  }

  // Get the staff list for a specific day at a specific hour
  public async getStaffList(cafeName: string, day: DayOfTheWeek, hourName: string): Promise<IStaff[] | null> {
    try {
      const shift = await ShiftModel.findOne({ cafe_name: cafeName });
      if (shift) {
        const targetHour = shift.shifts[day]?.hours.find(hr => hr.hourName === hourName);
        if (targetHour) {
          return targetHour.staff; // Return the staff list for the specified hour
        }
      }
      return null;
    } catch (err) {
      console.error("Error fetching staff list:", err);
      return null;
    }
  }

}

export default ShiftService;
