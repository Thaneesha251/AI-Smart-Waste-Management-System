import api from './axiosConfig';

const USE_MOCK = import.meta.env.VITE_USE_MOCK_DATA === 'true';

const mockNotifications = [
  { id: 1, type: 'critical', title: 'Emergency Alert', description: 'Overflow reported near Ring Road.', time: '2 mins ago', read: false, icon: 'AlertTriangle' },
  { id: 2, type: 'warning', title: 'Worker Delay', description: 'Ravi is delayed by 15 minutes.', time: '15 mins ago', read: false, icon: 'Bell' },
  { id: 3, type: 'info', title: 'Route Update', description: 'A new sanitation route was assigned.', time: '1 hr ago', read: true, icon: 'Info' },
  { id: 4, type: 'success', title: 'Cleanup Complete', description: 'Zone B waste collection has finished.', time: '2 hrs ago', read: true, icon: 'CheckCircle' }
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
    return new Promise((resolve) => {
      setTimeout(() => resolve({ success: true }), 300);
    });
  }
  const response = await api.patch('/notifications/read-all');
  return response.data;
};
