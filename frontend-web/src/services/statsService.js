import api from './axiosConfig';

const USE_MOCK = import.meta.env.VITE_USE_MOCK_DATA === 'true';

export const getSummary = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve({ total_complaints: 145, pending: 20, resolved: 110, active_workers: 15, emergency_alerts: 2 }), 300);
    });
  }
  const response = await api.get('/stats/summary');
  return response.data;
};

export const getWeeklyStats = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve([
        { day: 'Mon', Complaints: 18, Resolved: 14, Pending: 4 },
        { day: 'Tue', Complaints: 22, Resolved: 17, Pending: 5 },
        { day: 'Wed', Complaints: 20, Resolved: 16, Pending: 4 },
        { day: 'Thu', Complaints: 24, Resolved: 19, Pending: 5 },
        { day: 'Fri', Complaints: 26, Resolved: 21, Pending: 5 },
        { day: 'Sat', Complaints: 19, Resolved: 15, Pending: 4 },
        { day: 'Sun', Complaints: 16, Resolved: 13, Pending: 3 }
      ]), 300);
    });
  }
  const response = await api.get('/stats/weekly');
  return response.data;
};

export const getDistribution = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve([
        { name: 'Organic', value: 35, color: '#22c55e' },
        { name: 'Paper', value: 20, color: '#3b82f6' },
        { name: 'Plastic', value: 25, color: '#f59e0b' },
        { name: 'Metal', value: 12, color: '#8b5cf6' },
        { name: 'Glass', value: 8, color: '#ef4444' }
      ]), 300);
    });
  }
  const response = await api.get('/stats/distribution');
  return response.data;
};

export const getMonthlyStats = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve([
        { month: 'Jan', complaints: 28, resolved: 22 },
        { month: 'Feb', complaints: 31, resolved: 25 },
        { month: 'Mar', complaints: 34, resolved: 29 },
        { month: 'Apr', complaints: 37, resolved: 31 },
        { month: 'May', complaints: 40, resolved: 35 },
        { month: 'Jun', complaints: 42, resolved: 38 }
      ]), 300);
    });
  }
  const response = await api.get('/stats/monthly');
  return response.data;
};

export const getZoneStats = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve([
        { zone: 'Zone A', value: 32 },
        { zone: 'Zone B', value: 24 },
        { zone: 'Zone C', value: 18 },
        { zone: 'Zone D', value: 16 },
        { zone: 'Zone E', value: 10 }
      ]), 300);
    });
  }
  const response = await api.get('/stats/by-zone');
  return response.data;
};
