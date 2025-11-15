export type StudentStatus = "ACTIVE" | "INACTIVE";

export type Student = {
  id?: number;
  rollNo: string;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  dob: string;
  gender: string;
  address: string;
  departmentId: number;
  enrollDate: string;
  profilePhotoUrl?: string;
  status: StudentStatus;
};

export type StudentFormPayload = Omit<Student, "id">;
