import axios from "axios";

// @ts-ignore - Runtime config from window
const API_BASE_URL = (window as any).APP_CONFIG?.API_BASE_URL || import.meta.env.VITE_API_BASE_URL || "http://localhost:8080";

const client = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: false
});

client.interceptors.request.use((config) => {
  const token = localStorage.getItem("sms_token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const api = {
  login: (payload: { email: string; password: string }) => client.post("/api/auth/login", payload),
  register: (payload: { fullName: string; email: string; password: string; role: string }) =>
    client.post("/api/auth/register", payload),
  getDashboard: () => client.get("/api/admin/dashboard"),
  listStudents: (params: Record<string, string | number>) => client.get("/api/students", { params }),
  createStudent: (body: unknown) => client.post("/api/students", body),
  updateStudent: (id: number, body: unknown) => client.put(`/api/students/${id}`, body),
  deleteStudent: (id: number) => client.delete(`/api/students/${id}`),
  uploadStudents: (file: File) => {
    const form = new FormData();
    form.append("file", file);
    return client.post("/api/admin/students/bulk-upload", form, {
      headers: { "Content-Type": "multipart/form-data" }
    });
  },
  listTeachers: () => client.get("/api/teachers"),
  createTeacher: (body: unknown) => client.post("/api/teachers", body),
  listCourses: () => client.get("/api/courses"),
  createCourse: (body: unknown) => client.post("/api/courses", body),
  markAttendance: (body: unknown) => client.post("/api/attendance", body),
  listAttendance: (params: Record<string, string | number>) => client.get("/api/attendance", { params }),
  recordMark: (body: unknown) => client.post("/api/marks", body),
  listMarks: (params?: Record<string, string | number>) => client.get("/api/marks", { params })
};

export default client;
