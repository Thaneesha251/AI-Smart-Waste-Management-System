import { useEffect, useState } from 'react';
import { Bell, CalendarDays, Menu, Search } from 'lucide-react';
import NotificationPanel from './NotificationPanel';
import { getNotifications, markAllAsRead, markAsRead, deleteNotification } from '../services/notificationsService';
import '../styles/Navbar.css';

const Navbar = ({ onMenuToggle }) => {
  const [now, setNow] = useState(new Date());
  const [isPanelOpen, setIsPanelOpen] = useState(false);
  const [notifications, setNotifications] = useState([]);

  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    getNotifications().then(setNotifications);
  }, []);

  const unreadCount = notifications.filter(n => !n.is_read).length;

  const handleTogglePanel = () => {
    setIsPanelOpen((prev) => !prev);
  };

  const handleMarkAsRead = async (id) => {
    await markAsRead(id);
    setNotifications((prev) => prev.map(n => (n.id === id ? { ...n, is_read: true } : n)));
  };

  const handleMarkAllAsRead = async () => {
    await markAllAsRead();
    setNotifications((prev) => prev.map(n => ({ ...n, is_read: true })));
  };

  const handleDelete = async (id) => {
    await deleteNotification(id);
    setNotifications((prev) => prev.filter(n => n.id !== id));
  };

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
        <div className="navbar-icon-wrap" onClick={handleTogglePanel} style={{ cursor: 'pointer' }}>
          <Bell size={18} />
          {unreadCount > 0 && <span className="nav-badge">{unreadCount}</span>}
        </div>

        <NotificationPanel
          isOpen={isPanelOpen}
          onClose={() => setIsPanelOpen(false)}
          notifications={notifications}
          unreadCount={unreadCount}
          onMarkAsRead={handleMarkAsRead}
          onDelete={handleDelete}
          onMarkAllAsRead={handleMarkAllAsRead}
        />

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
