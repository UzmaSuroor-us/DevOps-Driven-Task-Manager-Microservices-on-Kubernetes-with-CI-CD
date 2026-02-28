import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { authAPI } from '../services/api';
import './Login.css';

const Login: React.FC = () => {
  const [isLogin, setIsLogin] = useState(true);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    
    try {
      if (isLogin) {
        await login(email, password);
        navigate('/dashboard');
      } else {
        await authAPI.register(name, email, password);
        setSuccess('Registration successful! Please login.');
        setIsLogin(true);
        setName('');
        setPassword('');
      }
    } catch (err: any) {
      setError(err.response?.data?.message || (isLogin ? 'Login failed' : 'Registration failed'));
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <h1>Task Manager</h1>
        <h2>{isLogin ? 'Login' : 'Register'}</h2>
        
        {error && <div className="error-message">{error}</div>}
        {success && <div className="success-message">{success}</div>}
        
        <form onSubmit={handleSubmit}>
          {!isLogin && (
            <div className="form-group">
              <label>Name</label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
              />
            </div>
          )}
          
          <div className="form-group">
            <label>Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          
          <div className="form-group">
            <label>Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          
          <button type="submit" className="btn-primary">
            {isLogin ? 'Login' : 'Register'}
          </button>
        </form>
        
        <div className="toggle-form">
          {isLogin ? (
            <p>
              Don't have an account?{' '}
              <span onClick={() => setIsLogin(false)}>Register here</span>
            </p>
          ) : (
            <p>
              Already have an account?{' '}
              <span onClick={() => setIsLogin(true)}>Login here</span>
            </p>
          )}
        </div>
      </div>
    </div>
  );
};

export default Login;
