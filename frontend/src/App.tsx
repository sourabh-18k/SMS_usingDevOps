import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import { AuthProvider } from "./context/AuthContext";
import { useThemeSync } from "./utils/theme";
import { ProtectedRoute } from "./router/ProtectedRoute";
import { LoginPage, DashboardPage, StudentsPage, TeachersPage, CoursesPage, AttendancePage, MarksPage } from "./pages";

export default function App() {
  useThemeSync();
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route
            path="/dashboard"
            element={
              <ProtectedRoute allowedRoles={["ADMIN", "TEACHER", "STUDENT"]}>
                <DashboardPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/students"
            element={
              <ProtectedRoute allowedRoles={["ADMIN", "TEACHER"]}>
                <StudentsPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/teachers"
            element={
              <ProtectedRoute allowedRoles={["ADMIN"]}>
                <TeachersPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/courses"
            element={
              <ProtectedRoute allowedRoles={["ADMIN", "TEACHER"]}>
                <CoursesPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/attendance"
            element={
              <ProtectedRoute allowedRoles={["ADMIN", "TEACHER"]}>
                <AttendancePage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/marks"
            element={
              <ProtectedRoute allowedRoles={["ADMIN", "TEACHER"]}>
                <MarksPage />
              </ProtectedRoute>
            }
          />
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
