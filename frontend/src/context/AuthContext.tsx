import React, { createContext, useContext, useState, useEffect } from 'react';
import { jwtDecode } from 'jwt-decode';
import { authAPI } from '../services/api';
import { User, AuthContextType } from '../types';

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(localStorage.getItem('token'));

  useEffect(() => {
    if (token) {
      try {
        const decoded: any = jwtDecode(token);
        setUser({
          id: decoded.userId,
          name: decoded.name,
          email: decoded.sub,
          role: decoded.role,
        });
      } catch (error) {
        logout();
      }
    }
  }, [token]);

  const login = async (email: string, password: string) => {
    const response = await authAPI.login(email, password);
    const { token } = response.data;
    localStorage.setItem('token', token);
    setToken(token);
  };

  const googleLogin = async (googleToken: string) => {
    const response = await authAPI.googleLogin(googleToken);
    const { token } = response.data;
    localStorage.setItem('token', token);
    setToken(token);
  };

  const logout = () => {
    localStorage.removeItem('token');
    setToken(null);
    setUser(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        login,
        googleLogin,
        logout,
        isAuthenticated: !!token,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
