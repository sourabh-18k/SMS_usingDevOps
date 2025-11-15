import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";

type Props = { children: JSX.Element; allowedRoles: string[] };

export function ProtectedRoute({ children, allowedRoles }: Props) {
  const { user } = useAuth();
  const location = useLocation();
  if (!user) {
    return <Navigate to="/login" replace state={{ from: location }} />;
  }
  if (!allowedRoles.includes(user.role)) {
    return <Navigate to="/dashboard" replace />;
  }
  return children;
}
