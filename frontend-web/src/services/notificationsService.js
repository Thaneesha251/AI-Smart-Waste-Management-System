import api from './axiosConfig';

const USE_MOCK = import.meta.env.VITE_USE_MOCK_DATA === 'true';

// Field names match what NotificationPanel.jsx expects: is_read, created_at
let mockNotifications = [
  { id: 1, type: 'critical', title: 'Emergency Alert', description: 'Overflow reported near Ring Road.', created_at: new Date(Date.now() - 2 * 60000).toISOString(), is_read: false, icon: 'AlertTriangle' },
  { id: 2, type: 'warning', title: 'Worker Delay', description: 'Ravi is delayed by 15 minutes.', created_at: new Date(Date.now() - 15 * 60000).toISOString(), is_read: false, icon: 'Bell' },
  { id: 3, type: 'info', title: 'Route Update', description: 'A new sanitation route was assigned.', created_at: new Date(Date.now() - 60 * 60000).toISOString(), is_read: true, icon: 'Info' },
  { id: 4, type: 'success', title: 'Cleanup Complete', description: 'Zone B waste collection has finished.', created_at: new Date(Date.now() - 120 * 60000).toISOString(), is_read: true, icon: 'CheckCircle' }
];

export const getNotifications = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockNotifications), 300);
    });
  }
  const response = await api.get('/notifications');
  return response.data;
};

export const markAllAsRead = async () => {
  if (USE_MOCK) {
    mockNotifications = mockNotifications.map(n => ({ ...n, is_read: true }));
    return new Promise((resolve) => {
      setTimeout(() => resolve({ success: true }), 300);
    });
  }
  const response = await api.patch('/notifications/read-all');
  return response.data;
};

export const markAsRead = async (id) => {
  if (USE_MOCK) {
    mockNotifications = mockNotifications.map(n => (n.id === id ? { ...n, is_read: true } : n));
    return new Promise((resolve) => {
      setTimeout(() => resolve({ success: true }), 200);
    });
  }
  const response = await api.patch(`/notifications/${id}/read`);
  return response.data;
};

export const deleteNotification = async (id) => {
  if (USE_MOCK) {
    mockNotifications = mockNotifications.filter(n => n.id !== id);
    return new Promise((resolve) => {
      setTimeout(() => resolve({ success: true }), 200);
    });
  }
  const response = await api.delete(`/notifications/${id}`);
  return response.data;
};
