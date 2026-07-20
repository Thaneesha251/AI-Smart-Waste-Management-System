import api from './axiosConfig';

const USE_MOCK = import.meta.env.VITE_USE_MOCK_DATA === 'true';

const mockComplaints = [
  { id: '#145', location: 'Ring Road', type: 'Garbage Overflow', status: 'Pending', time: '10 mins ago', priority: 'High' },
  { id: '#144', location: 'GV Residency', type: 'Roadside Waste', status: 'In Progress', time: '25 mins ago', priority: 'Medium' },
  { id: '#143', location: 'Nehru Street', type: 'Bin Full', status: 'Resolved', time: '40 mins ago', priority: 'Low' },
  { id: '#142', location: 'Kovai Pudur', type: 'Illegal Dumping', status: 'Pending', time: '1 hr ago', priority: 'High' },
  { id: '#141', location: 'Town Hall', type: 'Garbage Overflow', status: 'In Progress', time: '1 hr ago', priority: 'Medium' },
  { id: '#140', location: 'Peelamedu', type: 'Roadside Waste', status: 'Resolved', time: '2 hrs ago', priority: 'Low' },
  { id: '#139', location: 'Saravanampatti', type: 'Bin Full', status: 'Pending', time: '3 hrs ago', priority: 'High' },
  { id: '#138', location: 'RS Puram', type: 'Illegal Dumping', status: 'Resolved', time: '4 hrs ago', priority: 'Medium' }
];

const STATUS_LABELS = {
  pending: 'Pending',
  in_progress: 'In Progress',
  resolved: 'Resolved',
  rejected: 'Rejected',
};

const timeAgo = (isoString) => {
  if (!isoString) return '—';
  const diffMs = Date.now() - new Date(isoString).getTime();
  const mins = Math.floor(diffMs / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins} min${mins === 1 ? '' : 's'} ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs} hr${hrs === 1 ? '' : 's'} ago`;
  const days = Math.floor(hrs / 24);
  return `${days} day${days === 1 ? '' : 's'} ago`;
};

const transformComplaint = (c) => ({
  id: c.id,
  location: c.title || '—',
  type: c.category ? c.category.replace('_', ' ') : 'General',
  priority: c.priority ? c.priority.charAt(0).toUpperCase() + c.priority.slice(1) : 'Low',
  status: STATUS_LABELS[c.status] || c.status,
  time: timeAgo(c.created_at),
  description: c.description,
  raw_status: c.status,
});

export const getComplaints = async (params = {}) => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockComplaints), 300);
    });
  }
  const response = await api.get('/complaints/complaints/all', { params });
  const results = response.data.data.results || [];
  return results.map(transformComplaint);
};

export const getComplaintById = async (id) => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockComplaints.find((item) => item.id === id) || null), 300);
    });
  }
  const response = await api.get(`/complaints/complaints/${id}`);
  return transformComplaint(response.data.data);
};

export const getRecentComplaints = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockComplaints.slice(0, 6)), 300);
    });
  }
  const response = await api.get('/complaints/complaints/all', { params: { limit: 6, skip: 0 } });
  const results = response.data.data.results || [];
  return results.map(transformComplaint);
};