import { createContext, useContext, useEffect, useState } from 'react';

const SettingsContext = createContext(null);

export const SettingsProvider = ({ children }) => {
  const [darkMode, setDarkMode] = useState(() => localStorage.getItem('darkMode') === 'true');
  const [autoAssign, setAutoAssign] = useState(() => localStorage.getItem('autoAssign') !== 'false');

  useEffect(() => {
    localStorage.setItem('darkMode', darkMode);
    document.body.classList.toggle('dark-mode', darkMode);
  }, [darkMode]);

  useEffect(() => {
    localStorage.setItem('autoAssign', autoAssign);
  }, [autoAssign]);

  return (
    <SettingsContext.Provider value={{ darkMode, setDarkMode, autoAssign, setAutoAssign }}>
      {children}
    </SettingsContext.Provider>
  );
};

export const useSettings = () => {
  const ctx = useContext(SettingsContext);
  if (!ctx) throw new Error('useSettings must be used within a SettingsProvider');
  return ctx;
};

export default SettingsContext;
