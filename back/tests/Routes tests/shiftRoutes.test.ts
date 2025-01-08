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

  describe("DELETE /api/v1/shifts/:day/removeStaff", () => {
    it("should remove staff from a specific hour", async () => {
      const response = await request(server.App)
        .delete("/api/v1/shifts/monday/removeStaff")
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
        .put("/api/v1/shifts/monday/10:00/confirmStaff")
        .send({
          cafeName: "TestCafe",
          matricule: "123456",
        });
      expect(response.status).toBe(200);
      expect(response.body.message).toEqual("Staff confirmed successfully");
    });
  });

  describe("GET /api/v1/shifts/:cafeName/:day/:hourName/staff", () => {
    it("should return the staff list for a specific hour", async () => {
      const response = await request(server.App)
        .get("/api/v1/shifts/TestCafe/monday/10:00/staff");
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("staff");
      expect(response.body.staff).toBeInstanceOf(Array);
    });
  });
});

