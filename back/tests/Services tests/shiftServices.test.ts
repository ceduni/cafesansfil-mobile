import { MainController } from "../../src/contollers/mainController";
import ShiftService from "../../src/services/shiftServices";
import { IShift } from "../../src/models/DatabaseModels/shiftModel";

let server: MainController;
let shiftService: ShiftService;

beforeAll(() => {
  server = new MainController();
  shiftService = new ShiftService();
});

afterAll(async () => {
  await server.closeDatabaseConnection();
});

describe("ShiftService test", () => {
  describe("getAllShifts", () => {
    it("should return an array of shifts", async () => {
      const shifts: IShift[] = await shiftService.getAllShifts();
      expect(shifts).toBeInstanceOf(Array);
    });
  });

  describe("addStaffToHour", () => {
    it("should add staff to a specific hour on a specific day", async () => {
      const cafeName = "TestCafe";
      const day = "monday" as const;
      const hourName = "10:00";
      const matricule = "123456";
      const name = "John Doe"; // Include the name since it's required

      const updatedShift = await shiftService.addStaffToHour(cafeName, day, hourName, matricule, name);
      expect(updatedShift).not.toBeNull();
      if (updatedShift) {
        const targetHour = updatedShift.shifts[day]?.hours.find(hr => hr.hourName === hourName);
        expect(targetHour?.staff).toEqual(
          expect.arrayContaining([{ matricule, set: false, name }]) // Include the name in the expectation
        );
      }
    });
  });

  describe("removeStaffFromHour", () => {
    it("should remove staff from a specific hour on a specific day", async () => {
      const cafeName = "TestCafe";
      const day = "monday" as const;
      const hourName = "10:00";
      const matricule = "123456";
      
      const updatedShift = await shiftService.removeStaffFromHour(cafeName, day, hourName, matricule);
      expect(updatedShift).not.toBeNull();
      if (updatedShift) {
        const targetHour = updatedShift.shifts[day]?.hours.find(hr => hr.hourName === hourName);
        expect(targetHour?.staff).not.toEqual(
          expect.arrayContaining([{ matricule, set: false }]) // Match with the structure, set can be false or true
        );
      }
    });
  });

  describe("confirmStaff", () => {
    it("should confirm staff for a specific hour on a specific day", async () => {
      const cafeName = "TestCafe";
      const day = "monday" as const;
      const hourName = "10:00";
      const matricule = "123456";
      
      const updatedShift = await shiftService.confirmStaff(cafeName, day, hourName, matricule);
      expect(updatedShift).not.toBeNull();
      if (updatedShift) {
        const targetHour = updatedShift.shifts[day]?.hours.find(hr => hr.hourName === hourName);
        const staff = targetHour?.staff.find(s => s.matricule === matricule);
        expect(staff?.set).toBe(true);
      }
    });
  });

  describe("getStaffList", () => {
    it("should return the staff list for a specific day at a specific hour", async () => {
      const cafeName = "TestCafe";
      const day = "monday" as const;
      const hourName = "10:00";
      
      const staffList = await shiftService.getStaffList(cafeName, day, hourName);
      expect(staffList).toBeInstanceOf(Array);
    });
  });
});


/*
describe("ShiftService Tests", () => {
  it("getShifts should return an array of shifts", async () => {
    const shifts: IShift[] = await shiftService.getShifts();
    expect(shifts).toBeInstanceOf(Array);
  });

  it("getShiftsByMatricule should return a shift by matricule", async () => {
    const matricule = "20281527"; // existing shift
    const shift: IShift | null = await shiftService.getShiftsByMatricule(
      matricule
    );
    if (shift) {
      expect(shift.matricule).toBe(matricule);
    } else {
      expect(true).toBe(false); // Shift not found, test should fail
    }
  });
});*/
