import { Schema, Document, model } from "mongoose";

// Interface for a single shift
interface IShiftDetail extends Document {
  date: Date;
  startTime: string;
  endTime: string;
  confirmed: boolean;
}

// Interface for the main Matricule Shift document
interface IMatriculeShift {
  matricule: string;
  shifts: IShiftDetail[];
}

// Main Shift document interface
interface IShift extends Document {
  cafe_name: string;
  matricules: IMatriculeShift[];
}


// Schema for a single shift detail
const ShiftDetailSchema: Schema = new Schema({
  date: { type: Date, required: true },
  startTime: { type: String, required: true },
  endTime: { type: String, required: true },
  confirmed: { type: Boolean, default: false },
});

// Schema for matricule and its respective shift details
const MatriculeShiftSchema: Schema = new Schema({
  matricule: { type: String, required: true },
  shifts: { type: [ShiftDetailSchema], required: true },
});

// Main Shift schema
const ShiftSchema: Schema = new Schema({
  cafe_name: { type: String, required: true }, 
  matricules: { type: [MatriculeShiftSchema], required: true }, // Change to Matricule Shift see with the prof
});



// Creating the models
const ShiftDetailModel = model<IShiftDetail>("ShiftDetail", ShiftDetailSchema);
const ShiftModel = model<IShift>("Shift", ShiftSchema, "shifts");

export { ShiftModel, IShift, IShiftDetail };


//export { ShiftModel, IShift, ShiftDetailModel, IShiftDetail };

/**
 * Example ajouter a la db
{
  "cafe_id": 56372318
  "cafe_name": "Tore et Fraction",
  "shifts": [
    {
      "date": "2023-10-01T00:00:00Z",
      "startTime": "09:00",
      "endTime": "17:00",
      "min": 3,
      closed
      "staff": [
      {
        matricule: "12345678",
        confirmed: true
      }
  ],
  ]
}
 */
