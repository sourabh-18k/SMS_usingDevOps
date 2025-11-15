import { FormEvent, useEffect, useState } from "react";
import { motion } from "framer-motion";
import { useNavigate } from "react-router-dom";
import { api } from "../api/client";
import { useAuth } from "../hooks/useAuth";
import { Layout, HeroCard, StatCard, ChartCard, StudentTable, StudentForm, UploadCard } from "../components/ui";
import { Student, StudentFormPayload } from "../types";

export const LoginPage = () => {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [error, setError] = useState("");

  const submit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const data = new FormData(e.currentTarget);
    const email = data.get("email") as string;
    const password = data.get("password") as string;
    try {
      await login(email, password);
      navigate("/dashboard");
    } catch (err) {
      setError("Invalid credentials");
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-white to-gray-200 flex items-center justify-center">
      <motion.form
        initial={{ opacity: 0, y: 40 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-white rounded-3xl shadow-2xl p-10 w-full max-w-md space-y-6"
        onSubmit={submit}
      >
        <h1 className="text-3xl font-semibold">Welcome back</h1>
        {error && <p className="text-red-500 text-sm">{error}</p>}
        <input name="email" placeholder="Email" className="w-full border rounded-2xl px-4 py-3" defaultValue="admin@sms.dev" />
        <input name="password" placeholder="Password" type="password" className="w-full border rounded-2xl px-4 py-3" defaultValue="ChangeMe123!" />
        <button className="w-full rounded-2xl py-3 bg-black text-white">Login</button>
      </motion.form>
    </div>
  );
};

export const DashboardPage = () => {
  const [metrics, setMetrics] = useState<any>(null);

  useEffect(() => {
    api.getDashboard().then((res) => setMetrics(res.data));
  }, []);

  return (
    <Layout>
      <HeroCard title="Effortless control" subtitle="Monitor every cohort, attendance pulse, and performance snapshot." />
      {metrics ? (
        <div className="grid md:grid-cols-4 gap-4">
          <StatCard label="Students" value={metrics.totalStudents.toString()} />
          <StatCard label="Teachers" value={metrics.totalTeachers.toString()} />
          <StatCard label="Courses" value={metrics.totalCourses.toString()} />
          <StatCard label="Avg Attendance" value={`${metrics.averageAttendance}%`} />
        </div>
      ) : (
        <p className="text-gray-500">Loading metrics...</p>
      )}
      <ChartCard
        data={[
          { label: "Week 1", value: 92 },
          { label: "Week 2", value: 94 },
          { label: "Week 3", value: 90 },
          { label: "Week 4", value: metrics?.averageAttendance || 88 }
        ]}
      />
    </Layout>
  );
};

export const StudentsPage = () => {
  const [students, setStudents] = useState<Student[]>([]);
  const [search, setSearch] = useState("");
  const [selected, setSelected] = useState<Student | null>(null);

  const fetchStudents = () =>
    api.listStudents({ search }).then((res) => setStudents(res.data.content));

  useEffect(() => {
    fetchStudents();
  }, []);

  const handleCreate = async (payload: StudentFormPayload) => {
    await api.createStudent({ ...payload, dob: payload.dob || "2004-01-01", enrollDate: payload.enrollDate || "2022-08-01" });
    fetchStudents();
  };

  const handleUpdate = async (payload: StudentFormPayload) => {
    if (!selected?.id) return;
    await api.updateStudent(selected.id, payload);
    setSelected(null);
    fetchStudents();
  };

  const handleDelete = async (student: Student) => {
    if (!student.id) return;
    await api.deleteStudent(student.id);
    fetchStudents();
  };

  const handleUpload = async (file: File) => {
    await api.uploadStudents(file);
    fetchStudents();
  };

  return (
    <Layout>
      <div className="flex flex-col lg:flex-row gap-6">
        <div className="flex-1 space-y-4">
          <div className="flex items-center gap-3">
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search"
              className="border rounded-2xl px-4 py-2 flex-1"
            />
            <button onClick={fetchStudents} className="px-4 py-2 rounded-2xl bg-black text-white">
              Search
            </button>
          </div>
          <StudentTable students={students} onEdit={setSelected} onDelete={handleDelete} />
        </div>
        <div className="w-full lg:w-96 space-y-4">
          <div className="rounded-2xl bg-white dark:bg-gray-900 p-6 border border-gray-100 dark:border-gray-800">
            <h2 className="text-lg font-semibold mb-4">{selected ? "Edit student" : "Create student"}</h2>
            <StudentForm initial={selected || undefined} onSubmit={selected ? handleUpdate : handleCreate} />
          </div>
          <UploadCard onUpload={handleUpload} />
        </div>
      </div>
    </Layout>
  );
};

export const TeachersPage = () => {
  const [teachers, setTeachers] = useState<any[]>([]);
  const [form, setForm] = useState({
    employeeId: "",
    name: "",
    email: "",
    phone: "",
    departmentId: "1",
    subjects: ""
  });

  const load = () => api.listTeachers().then((res) => setTeachers(res.data.content ?? res.data));

  useEffect(() => {
    load();
  }, []);

  const updateForm = (key: string, value: string) => setForm((prev) => ({ ...prev, [key]: value }));

  const submit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    await api.createTeacher({
      employeeId: form.employeeId,
      name: form.name,
      email: form.email,
      phone: form.phone,
      departmentId: Number(form.departmentId),
      subjects: form.subjects
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean)
    });
    setForm({ employeeId: "", name: "", email: "", phone: "", departmentId: "1", subjects: "" });
    load();
  };

  return (
    <Layout>
      <div className="grid lg:grid-cols-2 gap-6">
        <div className="rounded-3xl bg-white dark:bg-gray-900 p-6 border border-gray-100 dark:border-gray-800 space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-semibold">Faculty roster</h2>
            <span className="text-sm text-gray-500">{teachers.length} members</span>
          </div>
          <div className="space-y-3 max-h-[32rem] overflow-auto pr-2">
            {teachers.map((teacher) => (
              <motion.div
                key={teacher.id}
                initial={{ opacity: 0, y: 12 }}
                animate={{ opacity: 1, y: 0 }}
                className="rounded-2xl border border-gray-100 dark:border-gray-800 p-4 flex flex-col gap-1 bg-gray-50/60 dark:bg-gray-800/40"
              >
                <div className="flex items-center justify-between">
                  <p className="font-semibold">{teacher.name}</p>
                  <span className="text-xs text-gray-500">{teacher.employeeId}</span>
                </div>
                <p className="text-sm text-gray-500">{teacher.email}</p>
                <p className="text-xs text-gray-400">{teacher.phone}</p>
                <div className="flex flex-wrap gap-1 pt-2">
                  {(teacher.subjects || []).map((subject: string) => (
                    <span key={subject} className="text-xs px-2 py-1 rounded-xl bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-700">
                      {subject}
                    </span>
                  ))}
                </div>
              </motion.div>
            ))}
          </div>
        </div>
        <form
          onSubmit={submit}
          className="rounded-3xl bg-white dark:bg-gray-900 p-6 border border-gray-100 dark:border-gray-800 space-y-4"
        >
          <h2 className="text-xl font-semibold">Invite teacher</h2>
          <p className="text-sm text-gray-500">Auto-provision LMS access, schedules, and onboarding packets from here.</p>
          <div className="grid grid-cols-1 gap-3">
            <input value={form.employeeId} onChange={(e) => updateForm("employeeId", e.target.value)} placeholder="Employee ID" className="rounded-2xl border px-4 py-3 bg-transparent" />
            <input value={form.name} onChange={(e) => updateForm("name", e.target.value)} placeholder="Full name" className="rounded-2xl border px-4 py-3 bg-transparent" />
            <input value={form.email} onChange={(e) => updateForm("email", e.target.value)} placeholder="Email" type="email" className="rounded-2xl border px-4 py-3 bg-transparent" />
            <input value={form.phone} onChange={(e) => updateForm("phone", e.target.value)} placeholder="Phone" className="rounded-2xl border px-4 py-3 bg-transparent" />
            <select value={form.departmentId} onChange={(e) => updateForm("departmentId", e.target.value)} className="rounded-2xl border px-4 py-3 bg-transparent">
              <option value="1">Engineering</option>
              <option value="2">Science</option>
              <option value="3">Arts</option>
            </select>
            <textarea
              value={form.subjects}
              onChange={(e) => updateForm("subjects", e.target.value)}
              placeholder="Subjects (comma separated)"
              className="rounded-2xl border px-4 py-3 bg-transparent"
              rows={3}
            />
          </div>
          <button className="w-full rounded-2xl bg-black text-white py-3">Send invite</button>
        </form>
      </div>
    </Layout>
  );
};

export const CoursesPage = () => {
  const [courses, setCourses] = useState<any[]>([]);
  const [form, setForm] = useState({
    code: "",
    title: "",
    description: "",
    credits: "4",
    departmentId: "1",
    teacherId: ""
  });

  const load = () => api.listCourses().then((res) => setCourses(res.data.content ?? res.data));

  useEffect(() => {
    load();
  }, []);

  const updateForm = (key: string, value: string) => setForm((prev) => ({ ...prev, [key]: value }));

  const submit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    await api.createCourse({
      code: form.code,
      title: form.title,
      description: form.description,
      credits: Number(form.credits),
      departmentId: Number(form.departmentId),
      teacherId: form.teacherId ? Number(form.teacherId) : null
    });
    setForm({ code: "", title: "", description: "", credits: "4", departmentId: "1", teacherId: "" });
    load();
  };

  return (
    <Layout>
      <div className="grid xl:grid-cols-2 gap-6">
        <div className="grid md:grid-cols-2 gap-4">
          {courses.map((course) => (
            <motion.div
              key={course.id || course.code}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="p-5 rounded-3xl bg-white dark:bg-gray-900 border border-gray-100 dark:border-gray-800 flex flex-col gap-2"
            >
              <span className="text-sm text-gray-500">{course.code}</span>
              <p className="text-lg font-semibold leading-tight">{course.title}</p>
              <p className="text-xs text-gray-500 flex-1">{course.description}</p>
              <div className="text-xs text-gray-400 flex items-center gap-3">
                <span>{course.credits} credits</span>
                <span>Dept {course.department?.name || course.departmentId}</span>
              </div>
            </motion.div>
          ))}
        </div>
        <form
          onSubmit={submit}
          className="rounded-3xl bg-white dark:bg-gray-900 p-6 space-y-4 border border-gray-100 dark:border-gray-800"
        >
          <div>
            <h2 className="text-xl font-semibold">Spin up a course</h2>
            <p className="text-sm text-gray-500">One click to sync LMS shells, rosters, and grading policies.</p>
          </div>
          <input value={form.code} onChange={(e) => updateForm("code", e.target.value)} placeholder="Code" className="rounded-2xl border px-4 py-3 bg-transparent w-full" />
          <input value={form.title} onChange={(e) => updateForm("title", e.target.value)} placeholder="Title" className="rounded-2xl border px-4 py-3 bg-transparent w-full" />
          <textarea
            value={form.description}
            onChange={(e) => updateForm("description", e.target.value)}
            placeholder="Description"
            className="rounded-2xl border px-4 py-3 bg-transparent w-full"
            rows={3}
          />
          <div className="grid grid-cols-2 gap-3">
            <input value={form.credits} onChange={(e) => updateForm("credits", e.target.value)} placeholder="Credits" className="rounded-2xl border px-4 py-3 bg-transparent" />
            <input value={form.teacherId} onChange={(e) => updateForm("teacherId", e.target.value)} placeholder="Teacher ID" className="rounded-2xl border px-4 py-3 bg-transparent" />
          </div>
          <select value={form.departmentId} onChange={(e) => updateForm("departmentId", e.target.value)} className="rounded-2xl border px-4 py-3 bg-transparent w-full">
            <option value="1">Engineering</option>
            <option value="2">Science</option>
            <option value="3">Arts</option>
          </select>
          <button className="w-full rounded-2xl bg-black text-white py-3">Create course</button>
        </form>
      </div>
    </Layout>
  );
};

export const AttendancePage = () => {
  const [entries, setEntries] = useState<any[]>([]);
  const [form, setForm] = useState({ studentId: "", courseId: "", date: new Date().toISOString().slice(0, 10), status: "PRESENT" });

  const updateForm = (key: string, value: string) => setForm((prev) => ({ ...prev, [key]: value }));

  const fetchEntries = async (courseId?: string) => {
    const params: Record<string, string> = {};
    if (courseId) params.courseId = courseId;
    const res = await api.listAttendance(params);
    setEntries(res.data.content ?? res.data);
  };

  useEffect(() => {
    fetchEntries(form.courseId || undefined);
  }, []);

  const submit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    await api.markAttendance({
      studentId: Number(form.studentId),
      courseId: Number(form.courseId),
      date: form.date,
      status: form.status
    });
    fetchEntries(form.courseId);
  };

  return (
    <Layout>
      <div className="grid md:grid-cols-2 gap-6">
        <form onSubmit={submit} className="rounded-3xl bg-white dark:bg-gray-900 p-6 border border-gray-100 dark:border-gray-800 space-y-4">
          <div>
            <h2 className="text-xl font-semibold">Mark attendance</h2>
            <p className="text-sm text-gray-500">Real-time syncing to student profiles and notification workflows.</p>
          </div>
          <input value={form.studentId} onChange={(e) => updateForm("studentId", e.target.value)} placeholder="Student ID" className="rounded-2xl border px-4 py-3 bg-transparent w-full" />
          <input value={form.courseId} onChange={(e) => updateForm("courseId", e.target.value)} placeholder="Course ID" className="rounded-2xl border px-4 py-3 bg-transparent w-full" />
          <input value={form.date} type="date" onChange={(e) => updateForm("date", e.target.value)} className="rounded-2xl border px-4 py-3 bg-transparent w-full" />
          <select value={form.status} onChange={(e) => updateForm("status", e.target.value)} className="rounded-2xl border px-4 py-3 bg-transparent w-full">
            <option value="PRESENT">Present</option>
            <option value="ABSENT">Absent</option>
            <option value="LATE">Late</option>
            <option value="EXCUSED">Excused</option>
          </select>
          <button className="w-full rounded-2xl bg-black text-white py-3">Log attendance</button>
        </form>
        <div className="rounded-3xl bg-white dark:bg-gray-900 p-6 border border-gray-100 dark:border-gray-800">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold">Timeline</h2>
            <button
              onClick={() => fetchEntries(form.courseId || undefined)}
              className="text-sm text-gray-500 hover:text-gray-900"
              type="button"
            >
              Refresh
            </button>
          </div>
          <ul className="space-y-3 max-h-[32rem] overflow-auto">
            {entries.map((entry) => (
              <li key={`${entry.studentId}-${entry.date}-${entry.courseId}`} className="flex items-center justify-between text-sm border border-gray-100 dark:border-gray-800 rounded-2xl px-4 py-3">
                <div>
                  <p className="font-medium">Student {entry.studentId}</p>
                  <p className="text-xs text-gray-500">Course {entry.courseId}</p>
                </div>
                <div className="text-right">
                  <span className="text-xs uppercase tracking-wide text-gray-500">{entry.date}</span>
                  <p className="font-semibold">{entry.status}</p>
                </div>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </Layout>
  );
};

export const MarksPage = () => {
  const [entries, setEntries] = useState<any[]>([]);
  const [form, setForm] = useState({
    studentId: "",
    courseId: "",
    examType: "Midterm",
    marksObtained: "",
    maxMarks: "100"
  });

  const updateForm = (key: string, value: string) => setForm((prev) => ({ ...prev, [key]: value }));

  const fetchMarks = async () => {
    const res = await api.listMarks();
    setEntries(res.data.content ?? res.data);
  };

  useEffect(() => {
    fetchMarks();
  }, []);

  const submit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    await api.recordMark({
      studentId: Number(form.studentId),
      courseId: Number(form.courseId),
      examType: form.examType,
      marksObtained: Number(form.marksObtained),
      maxMarks: Number(form.maxMarks)
    });
    setForm({ ...form, studentId: "", courseId: "", marksObtained: "" });
    fetchMarks();
  };

  return (
    <Layout>
      <div className="grid md:grid-cols-2 gap-6">
        <form onSubmit={submit} className="rounded-3xl bg-white dark:bg-gray-900 p-6 border border-gray-100 dark:border-gray-800 space-y-4">
          <div>
            <h2 className="text-xl font-semibold">Record marks</h2>
            <p className="text-sm text-gray-500">Scores sync instantly to progress analytics and student reports.</p>
          </div>
          <input value={form.studentId} onChange={(e) => updateForm("studentId", e.target.value)} placeholder="Student ID" className="rounded-2xl border px-4 py-3 bg-transparent w-full" />
          <input value={form.courseId} onChange={(e) => updateForm("courseId", e.target.value)} placeholder="Course ID" className="rounded-2xl border px-4 py-3 bg-transparent w-full" />
          <input value={form.examType} onChange={(e) => updateForm("examType", e.target.value)} placeholder="Exam type" className="rounded-2xl border px-4 py-3 bg-transparent w-full" />
          <div className="grid grid-cols-2 gap-3">
            <input value={form.marksObtained} onChange={(e) => updateForm("marksObtained", e.target.value)} placeholder="Marks obtained" className="rounded-2xl border px-4 py-3 bg-transparent" />
            <input value={form.maxMarks} onChange={(e) => updateForm("maxMarks", e.target.value)} placeholder="Max marks" className="rounded-2xl border px-4 py-3 bg-transparent" />
          </div>
          <button className="w-full rounded-2xl bg-black text-white py-3">Save mark</button>
        </form>
        <div className="rounded-3xl bg-white dark:bg-gray-900 p-6 border border-gray-100 dark:border-gray-800">
          <h2 className="text-xl font-semibold mb-4">Recent scores</h2>
          <ul className="space-y-3 max-h-[32rem] overflow-auto">
            {entries.map((entry) => (
              <li key={`${entry.studentId}-${entry.courseId}-${entry.examType}`} className="rounded-2xl border border-gray-100 dark:border-gray-800 px-4 py-3 text-sm flex items-center justify-between">
                <div>
                  <p className="font-semibold">Student {entry.studentId}</p>
                  <p className="text-xs text-gray-500">Course {entry.courseId}</p>
                </div>
                <div className="text-right">
                  <p className="font-semibold">
                    {entry.marksObtained}/{entry.maxMarks}
                  </p>
                  <p className="text-xs text-gray-500">{entry.examType}</p>
                </div>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </Layout>
  );
};

