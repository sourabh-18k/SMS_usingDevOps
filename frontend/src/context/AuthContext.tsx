import { createContext, useEffect, useState, ReactNode } from "react";
import { api } from "../api/client";

type User = { token: string; role: string };

type AuthContextValue = {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
};

export const AuthContext = createContext<AuthContextValue>({
  user: null,
  login: async () => {},
  logout: () => {}
});

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const token = localStorage.getItem("sms_token");
    const role = localStorage.getItem("sms_role");
    if (token && role) {
      setUser({ token, role });
    }
  }, []);

  const login = async (email: string, password: string) => {
    const { data } = await api.login({ email, password });
    localStorage.setItem("sms_token", data.token);
    localStorage.setItem("sms_role", data.role);
    setUser({ token: data.token, role: data.role });
  };

  const logout = () => {
    localStorage.removeItem("sms_token");
    localStorage.removeItem("sms_role");
    setUser(null);
  };

  return <AuthContext.Provider value={{ user, login, logout }}>{children}</AuthContext.Provider>;
};
