import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { login as loginService, logout as logoutService } from '../services/authService';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const storedToken = localStorage.getItem('authToken');
    const storedUser = localStorage.getItem('authUser');

    if (storedToken && storedUser) {
      setIsLoggedIn(true);
      setUser(JSON.parse(storedUser));
    }
    setLoading(false);
  }, []);

  const login = async (email, password) => {
    const data = await loginService(email, password);
    localStorage.setItem('authToken', data.access_token);
    localStorage.setItem('authUser', JSON.stringify(data.user));
    setUser(data.user);
    setIsLoggedIn(true);
    return data;
  };

  const logout = async () => {
    await logoutService();
    setUser(null);
    setIsLoggedIn(false);
  };

  const value = useMemo(() => ({ user, isLoggedIn, loading, login, logout }), [user, isLoggedIn, loading]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export default AuthContext;
