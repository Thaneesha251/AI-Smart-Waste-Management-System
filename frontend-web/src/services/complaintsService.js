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

export const getComplaints = async (params = {}) => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockComplaints), 300);
    });
  }
  const response = await api.get('/complaints', { params });
  return response.data.data || [];
};

export const getComplaintById = async (id) => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockComplaints.find((item) => item.id === id) || null), 300);
    });
  }
  const response = await api.get(`/complaints/${id}`);
  return response.data;
};

export const getRecentComplaints = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockComplaints.slice(0, 6)), 300);
    });
  }
  const response = await api.get('/complaints/recent');
  return response.data;
};
