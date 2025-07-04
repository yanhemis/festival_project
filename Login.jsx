import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import InputField from '../components/InputField';
import '../styles/Auth.css';

function Login() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = (e) => {
    e.preventDefault();
    if (!email || !password) {
      alert('모든 항목을 입력해주세요.');
      return;
    }

    console.log('로그인 시도:', { email, password });
    // 서버 연결 기능 추가해야함
  };

  return (
    <div className="auth-container">
      <div className="auth-box">
        <h2 className="auth-title">로그인</h2>

        <form onSubmit={handleLogin}>
          <InputField
            type="email"
            label="이메일"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="example@domain.com"
          />
          <InputField
            type="password"
            label="비밀번호"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="비밀번호 입력"
          />
          <button type="submit" className="auth-button">
            로그인
          </button>
        </form>

        <div className="auth-divider">또는</div>

        <button className="auth-oauth-button google">
          Google 계정으로 로그인
        </button>
        <button className="auth-oauth-button apple">
          Apple 계정으로 로그인
        </button>

        <p className="auth-footer">
          계정이 없으신가요?{' '}
          <span className="auth-link" onClick={() => navigate('/signup')}>
            회원가입
          </span>
        </p>
      </div>
    </div>
  );
}

export default Login;
