import { MainController } from "../../src/contollers/mainController";
import ShiftService from "../../src/services/shiftServices";
import { IShift, ShiftModel } from "../../src/models/DatabaseModels/shiftModel";

let server: MainController;
let shiftService: ShiftService;

beforeAll(async () => {
  server = new MainController();
  shiftService = new ShiftService();
  
  await ShiftModel.create({
    cafe_id: "1",
    cafe_name: "TestCafe",
    shifts: {
      monday: {
        hours: [
          {
            hourName: "10:00",
            staffCountmin: 1,
            staff: []
          }
        ]
      },
      tuesday: {
        hours: [
          {
            hourName: "10:00",
            staffCountmin: 1,
            staff: []
          }
        ]
      },
      wednesday: {
        hours: [
          {
            hourName: "11:00",
            staffCountmin: 1,
            staff: []
          }
        ]
      },
      thursday: {
        hours: [
          {
            hourName: "12:00",
            staffCountmin: 1,
            staff: []
          }
        ]
      },
      friday: {
        hours: [
          {
            hourName: "14:00",
            staffCountmin: 1,
            staff: []
          }
        ]
      },
    }
  });
});

afterAll(async () => {
  await server.closeDatabaseConnection();
  // Clean up the database after tests
  await ShiftModel.deleteMany({});
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
      const day = "monday";
      const hourName = "10:00";
      const matricule = "123456";
      const name = "John Doe";

      const updatedShift = await shiftService.addStaffToHour(cafeName, day, hourName, matricule, name);//cause a issue because the response in not given in time so we get a null value
      console.log(updatedShift);
      expect(updatedShift).not.toBeNull();
      if (updatedShift) {
        const targetHour = updatedShift.shifts[day]?.hours.find(hr => hr.hourName === hourName);
        expect(targetHour?.staff).toEqual(
          expect.arrayContaining([{ matricule, set: false, name }])
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

      // add staff before trying to remove them
      await shiftService.addStaffToHour(cafeName, day, hourName, matricule, "John Doe");
      
      const updatedShift = await shiftService.removeStaffFromHour(cafeName, day, hourName, matricule);
      expect(updatedShift).not.toBeNull();
      if (updatedShift) {
        const targetHour = updatedShift.shifts[day]?.hours.find(hr => hr.hourName === hourName);
        expect(targetHour?.staff).not.toEqual(
          expect.arrayContaining([{ matricule, set: false }])
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

      //add staff before confirming them
      await shiftService.addStaffToHour(cafeName, day, hourName, matricule, "John Doe");

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

      // add staff before fetching the list
      await shiftService.addStaffToHour(cafeName, day, hourName, "123456", "John Doe");

      const staffList = await shiftService.getStaffList(cafeName, day, hourName);
      expect(staffList).toBeInstanceOf(Array);
    });
  });
});
