import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import '../styles/Login.css';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [remember, setRemember] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await login(email, password);
      navigate('/dashboard');
    } catch (err) {
      setError('Invalid email or password.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-page">
      <div className="login-card">
        <div className="login-logo-icon">
          <div style={{
            width: 72,
            height: 72,
            borderRadius: '50%',
            background: 'linear-gradient(135deg, #dcfce7, #bbf7d0)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: 40,
            boxShadow: '0 4px 16px rgba(34,197,94,0.25)'
          }}>
            ♻️
          </div>
        </div>
        <h1>SMART WASTE</h1>
        <h2>MANAGEMENT AI</h2>
        <p>Municipality Admin Dashboard</p>
        <form onSubmit={handleSubmit}>
          <input type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} required />
          <div className="password-row">
            <input type={showPassword ? 'text' : 'password'} placeholder="Password" value={password} onChange={(e) => setPassword(e.target.value)} required />
            <button type="button" className="show-btn" onClick={() => setShowPassword((v) => !v)}>{showPassword ? 'Hide' : 'Show'}</button>
          </div>
          <div className="form-row">
            <label><input type="checkbox" checked={remember} onChange={() => setRemember((v) => !v)} /> Remember Me</label>
            <a href="#">Forgot Password?</a>
          </div>
          {error ? <div className="login-error">{error}</div> : null}
          <button type="submit" className="login-btn" disabled={loading}>{loading ? 'Signing in...' : 'LOGIN'}</button>
        </form>
      </div>
    </div>
  );
};

export default Login;
