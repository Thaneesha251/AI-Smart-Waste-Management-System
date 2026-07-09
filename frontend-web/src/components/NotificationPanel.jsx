import { useState, useEffect } from 'react';
import { Bell, X, Check, Trash2 } from 'lucide-react';
import '../styles/NotificationPanel.css';

const NotificationPanel = ({ isOpen, onClose, notifications = [], unreadCount = 0, onMarkAsRead, onDelete, onMarkAllAsRead }) => {
  if (!isOpen) return null;

  return (
    <div className="notification-overlay" onClick={onClose}>
      <div className="notification-panel" onClick={(e) => e.stopPropagation()}>
        <div className="notification-header">
          <h3>Notifications</h3>
          <div className="notification-actions">
            {unreadCount > 0 && (
              <button className="btn-mark-all" onClick={onMarkAllAsRead} title="Mark all as read">
                <Check size={16} />
              </button>
            )}
            <button className="btn-close" onClick={onClose}>
              <X size={20} />
            </button>
          </div>
        </div>

        <div className="notification-list">
          {notifications && notifications.length > 0 ? (
            notifications.map((notification) => (
              <div
                key={notification.id}
                className={`notification-item ${!notification.is_read ? 'unread' : 'read'}`}
              >
                <div className="notification-content">
                  <h4 className="notification-title">{notification.title}</h4>
                  <p className="notification-description">{notification.description}</p>
                  <span className="notification-time">
                    {new Date(notification.created_at).toLocaleString()}
                  </span>
                </div>
                <div className="notification-actions-item">
                  {!notification.is_read && (
                    <button
                      className="btn-mark-read"
                      onClick={() => onMarkAsRead(notification.id)}
                      title="Mark as read"
                    >
                      <Check size={16} />
                    </button>
                  )}
                  <button
                    className="btn-delete-notification"
                    onClick={() => onDelete(notification.id)}
                    title="Delete"
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>
            ))
          ) : (
            <div className="no-notifications">
              <Bell size={32} />
              <p>No notifications yet</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default NotificationPanel;
