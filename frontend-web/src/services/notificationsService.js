import api from './axiosConfig';

const USE_MOCK = import.meta.env.VITE_USE_MOCK_DATA === 'true';

let mockNotifications = [
  { id: 1, type: 'critical', title: 'Emergency Alert', description: 'Overflow reported near Ring Road.', created_at: new Date(Date.now() - 2 * 60000).toISOString(), is_read: false, icon: 'AlertTriangle' },
  { id: 2, type: 'warning', title: 'Worker Delay', description: 'Ravi is delayed by 15 minutes.', created_at: new Date(Date.now() - 15 * 60000).toISOString(), is_read: false, icon: 'Bell' },
  { id: 3, type: 'info', title: 'Route Update', description: 'A new sanitation route was assigned.', created_at: new Date(Date.now() - 60 * 60000).toISOString(), is_read: true, icon: 'Info' },
  { id: 4, type: 'success', title: 'Cleanup Complete', description: 'Zone B waste collection has finished.', created_at: new Date(Date.now() - 120 * 60000).toISOString(), is_read: true, icon: 'CheckCircle' }
];

// Backend only sends a single "message" field, plus is_read/created_at/
// related_complaint_id — no title/description/type/icon split like the
// UI expects. We infer those here based on the message content.
const inferType = (message) => {
  const lower = message.toLowerCase();
  if (lower.includes('assigned')) return 'info';
  if (lower.includes('resolved')) return 'success';
  if (lower.includes('rejected')) return 'critical';
  return 'warning';
};

const iconForType = {
  critical: 'AlertTriangle',
  warning: 'Bell',
  info: 'Info',
  success: 'CheckCircle',
};

const titleForType = {
  critical: 'Complaint Rejected',
  warning: 'Status Update',
  info: 'Worker Assigned',
  success: 'Complaint Resolved',
};

const transformNotification = (n) => {
  const type = inferType(n.message);
  return {
    id: n.id,
    type,
    icon: iconForType[type],
    title: titleForType[type],
    description: n.message,
    created_at: n.created_at,
    is_read: n.is_read,
    related_complaint_id: n.related_complaint_id,
  };
};

export const getNotifications = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockNotifications), 300);
    });
  }
  const response = await api.get('/notifications/');
  const results = response.data.data || [];
  return results.map(transformNotification);
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
  // Backend has no DELETE /notifications/{id} endpoint yet.
  const response = await api.patch(`/notifications/${id}/read`);
  return response.data;
};