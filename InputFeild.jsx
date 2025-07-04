import React from 'react';
import './Auth.css';

function InputField({ type, label, value, onChange, placeholder }) {
  return (
    <div className="input-group">
      <label className="input-label">{label}</label>
      <input
        type={type}
        className="input-box"
        value={value}
        onChange={onChange}
        placeholder={placeholder}
      />
    </div>
  );
}

export default InputField;
