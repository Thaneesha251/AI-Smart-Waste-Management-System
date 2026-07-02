import { useEffect, useState } from 'react';
import { AlertTriangle, Bell, CheckCircle, Clock, Info } from 'lucide-react';
import { getNotifications, markAllAsRead } from '../services/notificationsService';
import '../styles/Pages.css';

const iconMap = {
  AlertTriangle,
  Bell,
  Info,
  CheckCircle
};

const typeStyles = {
  critical: 'notif-critical',
  warning: 'notif-warning',
  info: 'notif-info',
  success: 'notif-success'
};

const Notifications = () => {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      const data = await getNotifications();
      setItems(data);
      setLoading(false);
    };
    load();
  }, []);

  const handleMarkAll = async () => {
    await markAllAsRead();
    setItems((prev) => prev.map((item) => ({ ...item, read: true })));
  };

  return (
    <div className="content-wrapper">
      <div className="content-header">
        <div>
          <h2 className="header-title">Notifications</h2>
          <p className="header-subtitle">System alerts and critical updates.</p>
        </div>
        <button className="mark-read-btn" onClick={handleMarkAll}>Mark all as read</button>
      </div>
      <div className="panel-card">
        {loading ? <div className="empty-state">Loading notifications...</div> : (
          <div className="notif-list">
            {items.map((item) => {
              const Icon = iconMap[item.icon] || Bell;
              return (
                <div key={item.id} className={`notif-item ${item.read ? '' : 'unread'}`}>
                  <div className={`notif-icon ${typeStyles[item.type]}`}>
                    <Icon size={18} />
                  </div>
                  <div className="notif-content">
                    <div className="notif-title">{item.title}</div>
                    <div className="notif-description">{item.description}</div>
                    <div className="notif-time"><Clock size={14} /> {item.time}</div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
};

export default Notifications;
