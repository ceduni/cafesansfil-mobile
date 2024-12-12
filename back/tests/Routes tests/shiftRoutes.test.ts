import request from "supertest";
import { MainController } from "../../src/contollers/mainController";
import ShiftService from "../../src/services/shiftServices";

let server: MainController;
let shiftService: ShiftService;

beforeAll(() => {
  server = new MainController();
  shiftService = new ShiftService();
});

afterAll(async () => {
  await server.closeDatabaseConnection();
});

describe("ShiftRoutes test", () => {
  describe("GET /shifts/all", () => {
    it("should return all shifts", async () => {
      const response = await request(server.App).get("/shifts/all");
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("shifts");
      expect(response.body.shifts).toBeInstanceOf(Array);
    });
  });

  describe("POST /shifts/:day/addStaff", () => {
    it("should add staff to a specific hour", async () => {
      const response = await request(server.App)
        .post("/shifts/monday/addStaff")
        .send({
          cafeName: "TestCafe",
          hourName: "10:00",
          matricule: "123456",
        });
      expect(response.status).toBe(200);
      expect(response.body.message).toEqual("Staff added successfully");
    });
  });

  describe("DELETE /shifts/:day/removeStaff", () => {
    it("should remove staff from a specific hour", async () => {
      const response = await request(server.App)
        .delete("/shifts/monday/removeStaff")
        .send({
          cafeName: "TestCafe",
          hourName: "10:00",
          matricule: "123456",
        });
      expect(response.status).toBe(200);
      expect(response.body.message).toEqual("Staff removed successfully");
    });
  });

  describe("PUT /shifts/:day/:hourName/confirmStaff", () => {
    it("should confirm staff for a specific hour", async () => {
      const response = await request(server.App)
        .put("/shifts/monday/10:00/confirmStaff")
        .send({
          cafeName: "TestCafe",
          matricule: "123456",
        });
      expect(response.status).toBe(200);
      expect(response.body.message).toEqual("Staff confirmed successfully");
    });
  });

  describe("GET /shifts/:cafeName/:day/:hourName/staff", () => {
    it("should return the staff list for a specific hour", async () => {
      const response = await request(server.App)
        .get("/shifts/TestCafe/monday/10:00/staff");
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("staff");
      expect(response.body.staff).toBeInstanceOf(Array);
    });
  });
});

/*
describe("GET /api/v1/shifts", () => {
  it("should return a list of all shifts", async () => {
    const response = await request(server.App).get("/api/v1/shifts");
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("Shifts");
    expect(response.body.Shifts).toBeInstanceOf(Array);
  });
});

describe("GET /api/v1/shifts/matricule/:matricule", () => {
  it("should return a shift by matricule", async () => {
    const matricule = "20281527"; // existing shift
    const shift = await shiftService.getShiftsByMatricule(matricule);
    if (shift) {
      const response = await request(server.App).get(
        `/api/v1/shifts/matricule/${matricule}`
      );
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("shifts");
      expect(response.body.shifts).toHaveProperty("shift");
      expect(response.body.shifts.shift).toBeInstanceOf(Array);
    } else {
      expect(true).toBe(false); // shift not found, test should fail
    }
  });
});

describe("GET /api/v1/shifts/matricule/:matricule", () => {
  it("should return a null because matricule not found", async () => {
    const matricule = "90000000"; // non existing shift
    const response = await request(server.App).get(
      `/api/v1/shifts/matricule/${matricule}`
    );
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("shifts");
    expect(response.body.shifts).toEqual(null);
  });
});*/
