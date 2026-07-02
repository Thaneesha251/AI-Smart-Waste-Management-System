import { useEffect, useState } from 'react';
import { Bell, CalendarDays, Menu, Search } from 'lucide-react';
import '../styles/Navbar.css';

const Navbar = ({ onMenuToggle }) => {
  const [now, setNow] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  return (
    <header className="navbar">
      <div className="navbar-left">
        <button className="menu-btn" onClick={onMenuToggle}>
          <Menu size={18} />
        </button>
      </div>

      <div className="navbar-center">
        <div className="search-box">
          <Search size={16} />
          <input type="text" placeholder="Search anything..." />
        </div>
      </div>

      <div className="navbar-right">
        <div className="navbar-icon-wrap">
          <Bell size={18} />
          <span className="nav-badge">5</span>
        </div>
        <div className="navbar-date">
          <CalendarDays size={16} />
          <span>{now.toLocaleDateString()}</span>
        </div>
        <div className="navbar-time">{now.toLocaleTimeString()}</div>
      </div>
    </header>
  );
};

export default Navbar;
