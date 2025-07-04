import React, { useState } from 'react';
import './Login.css';

function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleEmailLogin = () => {
    console.log('로그인 시도:', email, password);
  };

  return (
    <div className="login-container">
      <h1 className="login-title">앱 이름</h1>
      <p className="login-subtitle">로그인 하기</p>
      <p className="login-description">이 앱에 로그인하려면 이메일을 입력하세요</p>

      <input
        type="email"
        placeholder="email@domain.com"
        className="login-input"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      <input
        type="password"
        placeholder="비밀번호 입력"
        className="login-input"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />

      <button type="button" className="login-primary-button" onClick={handleEmailLogin}>
        계속
      </button>

      <div className="login-separator-container">
        <div className="login-line"></div>
        <div className="login-or-text">또는</div>
        <div className="login-line"></div>
      </div>

      <button type="button" className="login-oauth-button">
        <img
          src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg"
          alt="google"
          className="login-icon"
        />
        Google 계정으로 계속하기
      </button>

      <button type="button" className="login-oauth-button">
        <img
          src="https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg"
          alt="apple"
          className="login-icon"
        />
        Apple 계정으로 계속하기
      </button>

      <p className="login-terms">
        계속을 클릭하면 당사의 <strong>서비스 이용 약관</strong> 및 <strong>개인정보 처리방침</strong>에 동의하는 것으로 간주됩니다.
      </p>

            // 회원가입 페이지 이동
      <p className="login-bottom-text">
         계정이 없으신가요?{' '}
         <span className="login-link" onClick={() => navigate('/signup')}>
           회원가입
         </span>
       </p>       
    </div>
  );
}

export default Login;
