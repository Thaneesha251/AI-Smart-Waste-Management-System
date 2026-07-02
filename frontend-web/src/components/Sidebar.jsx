import { NavLink, useNavigate } from 'react-router-dom';
import { BarChart2, Bell, FileText, LayoutDashboard, LogOut, MapPin, MessageSquare, Recycle, Settings, ShieldCheck, Users } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import '../styles/Sidebar.css';

const navItems = [
  { to: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/complaints', icon: MessageSquare, label: 'Complaints' },
  { to: '/workers', icon: Users, label: 'Workers' },
  { to: '/live-tracking', icon: MapPin, label: 'Live Tracking' },
  { to: '/verification', icon: ShieldCheck, label: 'Verification' },
  { to: '/analytics', icon: BarChart2, label: 'Analytics' },
  { to: '/notifications', icon: Bell, label: 'Notifications' },
  { to: '/reports', icon: FileText, label: 'Reports' },
  { to: '/settings', icon: Settings, label: 'Settings' }
];

const Sidebar = ({ isOpen }) => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  return (
    <aside className={`sidebar ${isOpen ? '' : 'closed'}`}>
      <div className="sidebar-brand">
        <div className="sidebar-logo">
          <Recycle size={22} />
        </div>
        <div>
          <div className="sidebar-title">SMART WASTE</div>
          <div className="sidebar-subtitle">MANAGEMENT AI</div>
        </div>
      </div>

      <div className="sidebar-section">MAIN MENU</div>
      <nav className="sidebar-nav">
        {navItems.map(({ to, icon: Icon, label }) => (
          <NavLink key={to} to={to} className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
            <Icon size={18} />
            <span>{label}</span>
            {label === 'Notifications' && <span className="nav-badge">5</span>}
          </NavLink>
        ))}
      </nav>

      <div className="sidebar-user">
        <div className="sidebar-avatar">AO</div>
        <div className="sidebar-user-info">
          <div className="sidebar-user-name">{user?.name || 'Admin Officer'}</div>
          <div className="sidebar-user-role">Municipality</div>
        </div>
        <button className="logout-btn" onClick={handleLogout} title="Logout">
          <LogOut size={18} />
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;
