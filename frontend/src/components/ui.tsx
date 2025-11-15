import { ReactNode, useMemo, useState } from "react";
import { motion } from "framer-motion";
import { Link, useLocation } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";
import { Student, StudentFormPayload } from "../types";
import { ChevronDown, Users } from "lucide-react";
import { ResponsiveContainer, LineChart, Line, Tooltip, XAxis, YAxis } from "recharts";

export const Layout = ({ children }: { children: ReactNode }) => (
  <div className="min-h-screen bg-gray-50 text-gray-900 dark:bg-black dark:text-gray-100 flex">
    <Sidebar />
    <div className="flex-1 flex flex-col">
      <NavBar />
      <main className="p-8 space-y-6">{children}</main>
    </div>
  </div>
);

const navLinks = [
  { to: "/dashboard", label: "Dashboard" },
  { to: "/students", label: "Students" },
  { to: "/teachers", label: "Teachers" },
  { to: "/courses", label: "Courses" },
  { to: "/attendance", label: "Attendance" },
  { to: "/marks", label: "Marks" }
];

const Sidebar = () => {
  const location = useLocation();
  return (
    <aside className="w-64 hidden lg:flex flex-col p-6 border-r border-gray-200 dark:border-gray-800 bg-white/70 dark:bg-gray-950/70 backdrop-blur-xl">
      <div className="flex items-center gap-3 mb-8">
        <img src="/src/assets/logo.svg" alt="logo" className="h-10 w-10" />
        <div>
          <p className="text-lg font-semibold">SMS</p>
          <p className="text-xs text-gray-500">Inspired by Apple</p>
        </div>
      </div>
      <nav className="space-y-2">
        {navLinks.map((link) => (
          <Link
            key={link.to}
            to={link.to}
            className={`block px-4 py-2 rounded-xl text-sm font-medium transition ${
              location.pathname === link.to
                ? "bg-black text-white dark:bg-white dark:text-black"
                : "text-gray-600 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-900"
            }`}
          >
            {link.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
};

const NavBar = () => {
  const { user, logout } = useAuth();
  return (
    <header className="flex items-center justify-between px-4 lg:px-10 py-6 border-b border-gray-200 dark:border-gray-800 bg-white/60 dark:bg-gray-950/60 backdrop-blur-xl sticky top-0 z-20">
      <h1 className="text-2xl font-semibold tracking-tight">Student Management</h1>
      <div className="flex items-center gap-4">
        <DarkModeToggle />
        {user && (
          <button
            onClick={logout}
            className="px-4 py-2 rounded-full bg-black text-white text-sm dark:bg-white dark:text-black"
          >
            Logout ({user.role})
          </button>
        )}
      </div>
    </header>
  );
};

const DarkModeToggle = () => {
  const [enabled, setEnabled] = useState(document.documentElement.classList.contains("dark"));
  const toggle = () => {
    document.documentElement.classList.toggle("dark");
    setEnabled((prev) => !prev);
  };
  return (
    <button
      onClick={toggle}
      className="px-3 py-1 rounded-full border border-gray-300 dark:border-gray-700 text-sm"
    >
      {enabled ? "Light" : "Dark"} Mode
    </button>
  );
};

export const HeroCard = ({ title, subtitle }: { title: string; subtitle: string }) => (
  <motion.div
    initial={{ opacity: 0, y: 30 }}
    animate={{ opacity: 1, y: 0 }}
    className="rounded-3xl bg-gradient-to-r from-gray-900 via-black to-gray-900 text-white p-10 shadow-2xl"
  >
    <h2 className="text-4xl font-semibold mb-3">{title}</h2>
    <p className="text-lg text-gray-200">{subtitle}</p>
  </motion.div>
);

export const StatCard = ({ label, value, trend }: { label: string; value: string; trend?: string }) => (
  <div className="rounded-2xl bg-white dark:bg-gray-900 p-6 shadow-sm border border-gray-100 dark:border-gray-800 space-y-2">
    <p className="text-sm uppercase tracking-wide text-gray-500">{label}</p>
    <p className="text-3xl font-semibold">{value}</p>
    {trend && <p className="text-xs text-emerald-500">{trend}</p>}
  </div>
);

export const ChartCard = ({ data }: { data: { label: string; value: number }[] }) => (
  <div className="rounded-2xl bg-white dark:bg-gray-900 p-6 shadow-sm border border-gray-100 dark:border-gray-800">
    <h3 className="text-sm uppercase text-gray-500 mb-4">Attendance Trend</h3>
    <ResponsiveContainer width="100%" height={220}>
      <LineChart data={data}>
        <XAxis dataKey="label" />
        <YAxis />
        <Tooltip />
        <Line dataKey="value" stroke="#111" strokeWidth={3} dot={false} />
      </LineChart>
    </ResponsiveContainer>
  </div>
);

export const StudentTable = ({
  students,
  onEdit,
  onDelete
}: {
  students: Student[];
  onEdit: (student: Student) => void;
  onDelete: (student: Student) => void;
}) => {
  const [sortKey, setSortKey] = useState<keyof Student>("firstName");
  const sorted = useMemo(() => {
    return [...students].sort((a, b) => {
      const aValue = `${a[sortKey]}`.toLowerCase();
      const bValue = `${b[sortKey]}`.toLowerCase();
      return aValue.localeCompare(bValue);
    });
  }, [students, sortKey]);

  return (
    <div className="bg-white dark:bg-gray-900 rounded-2xl border border-gray-100 dark:border-gray-800 shadow-sm overflow-hidden">
      <div className="flex justify-between items-center px-6 py-4">
        <h3 className="text-lg font-semibold">Students</h3>
        <button onClick={() => setSortKey("firstName")} className="text-sm text-gray-500 flex items-center gap-1">
          Sort
          <ChevronDown className="h-4 w-4" />
        </button>
      </div>
      <table className="w-full text-left text-sm">
        <thead>
          <tr className="bg-gray-50 dark:bg-gray-800/50 text-gray-500 uppercase text-xs">
            <th className="px-6 py-3">Name</th>
            <th className="px-6 py-3">Roll No</th>
            <th className="px-6 py-3">Department</th>
            <th className="px-6 py-3">Status</th>
            <th className="px-6 py-3" />
          </tr>
        </thead>
        <tbody>
          {sorted.map((student) => (
            <tr key={student.id} className="border-t border-gray-100 dark:border-gray-800">
              <td className="px-6 py-4">{student.firstName} {student.lastName}</td>
              <td className="px-6 py-4">{student.rollNo}</td>
              <td className="px-6 py-4">{student.departmentId}</td>
              <td className="px-6 py-4">
                <span className={`px-3 py-1 rounded-full text-xs ${student.status === "ACTIVE" ? "bg-emerald-100 text-emerald-700" : "bg-gray-200 text-gray-700"}`}>
                  {student.status}
                </span>
              </td>
              <td className="px-6 py-4 flex gap-3 text-xs">
                <button onClick={() => onEdit(student)} className="text-blue-600">Edit</button>
                <button onClick={() => onDelete(student)} className="text-red-500">Delete</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export const StudentForm = ({
  initial,
  onSubmit
}: {
  initial?: StudentFormPayload;
  onSubmit: (payload: StudentFormPayload) => void;
}) => {
  const [form, setForm] = useState<StudentFormPayload>(
    initial || {
      rollNo: "",
      firstName: "",
      lastName: "",
      email: "",
      phone: "",
      dob: "",
      gender: "M",
      address: "",
      departmentId: 1,
      enrollDate: "",
      profilePhotoUrl: "",
      status: "ACTIVE"
    }
  );
  return (
    <form
      className="grid md:grid-cols-2 gap-4"
      onSubmit={(e) => {
        e.preventDefault();
        onSubmit(form);
      }}
    >
      {Object.entries(form).map(([key, value]) => (
        <label key={key} className="text-sm text-gray-500 flex flex-col gap-2">
          {key}
          <input
            className="border border-gray-200 dark:border-gray-700 rounded-xl px-4 py-2 bg-transparent"
            value={value as string}
            onChange={(e) => setForm((prev) => ({ ...prev, [key]: e.target.value }))}
          />
        </label>
      ))}
      <button className="md:col-span-2 rounded-full bg-black text-white py-3 mt-4">Save Student</button>
    </form>
  );
};

export const UploadCard = ({ onUpload }: { onUpload: (file: File) => void }) => (
  <div className="rounded-2xl border border-dashed border-gray-300 dark:border-gray-700 p-6 flex flex-col items-center gap-3 text-center bg-white dark:bg-gray-900">
    <Users className="h-10 w-10 text-gray-400" />
    <p className="text-sm text-gray-500">Bulk upload CSV</p>
    <input
      type="file"
      accept=".csv"
      onChange={(e) => {
        if (e.target.files?.[0]) onUpload(e.target.files[0]);
      }}
      className="hidden"
      id="csvUpload"
    />
    <label htmlFor="csvUpload" className="px-4 py-2 rounded-full border border-gray-200 dark:border-gray-700 cursor-pointer">
      Upload
    </label>
  </div>
);
