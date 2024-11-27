import { Schema, Document, model } from "mongoose";

// Interface for a staff member
interface IStaff {
  matricule: string;
  set: boolean; // false by default
}

// Staff schema
const StaffSchema: Schema = new Schema({
  matricule: { type: String, required: true },
  set: { type: Boolean, default: false } // false by default
});

// Interface for hourly shifts
interface IHourlyShift {
  hourName: string;
  staffCountmin: number; // Renamed from staffCount to staffCountmin
  staff: IStaff[];
}

// Hourly Shift schema
const HourlyShiftSchema: Schema = new Schema({
  hourName: { type: String, required: true },
  staffCountmin: { type: Number, required: true }, // Count of minimum staff required
  staff: { 
    type: [StaffSchema], // Using the staff schema here
    required: true 
  }
});

// Interface for a day's shifts
interface IDayShift {
  hours: IHourlyShift[];
}

// Day Shift schema
const DayShiftSchema: Schema = new Schema({
  hours: { 
    type: [HourlyShiftSchema], 
    required: true 
  }
});

// Main Shift document interface
interface IShift extends Document {
  cafe_id: string;
  cafe_name: string;
  shifts: {
    monday: IDayShift;
    tuesday: IDayShift;
    wednesday: IDayShift;
    thursday: IDayShift;
    friday: IDayShift;
    saturday?: IDayShift; // Optional
    sunday?: IDayShift;   // Optional
  };
}

// Main Shift schema
const ShiftSchema: Schema = new Schema({
  cafe_id: { type: String, required: true },
  cafe_name: { type: String, required: true }, 
  shifts: {
    monday: { type: DayShiftSchema, required: true },
    tuesday: { type: DayShiftSchema, required: true },
    wednesday: { type: DayShiftSchema, required: true },
    thursday: { type: DayShiftSchema, required: true },
    friday: { type: DayShiftSchema, required: true },
    saturday: { type: DayShiftSchema, default: null }, // Optional
    sunday: { type: DayShiftSchema, default: null },   // Optional
  }
});

const ShiftModel = model<IShift>("Shift", ShiftSchema, "shift");

export { ShiftModel, IShift, IStaff };
