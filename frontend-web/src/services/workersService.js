import api from './axiosConfig';

const USE_MOCK = import.meta.env.VITE_USE_MOCK_DATA === 'true';

const mockWorkers = [
  { id: 1, name: 'Ravi', zone: 'Zone A', phone: '+91 98765 43210', status: 'On Duty', tasks: 4, completed: 18 },
  { id: 2, name: 'Suresh', zone: 'Zone B', phone: '+91 98765 43211', status: 'Off Duty', tasks: 2, completed: 12 },
  { id: 3, name: 'Anu', zone: 'Zone C', phone: '+91 98765 43212', status: 'On Leave', tasks: 1, completed: 9 },
  { id: 4, name: 'Mohan', zone: 'Zone D', phone: '+91 98765 43213', status: 'On Duty', tasks: 3, completed: 16 },
  { id: 5, name: 'Deepa', zone: 'Zone E', phone: '+91 98765 43214', status: 'On Duty', tasks: 5, completed: 22 },
  { id: 6, name: 'Karthik', zone: 'Zone F', phone: '+91 98765 43215', status: 'Off Duty', tasks: 0, completed: 6 }
];

const mockWorkersForMap = [
  { id: 1, name: 'Ravi', status: 'On Duty', currentTask: 'Complaint #1001', battery: 88, sos: false, progress: 60, lat: 11.0168, lng: 76.9558 },
  { id: 2, name: 'Suresh', status: 'On Duty', currentTask: 'None', battery: 74, sos: false, progress: 0, lat: 11.0210, lng: 76.9640 }
];

export const getWorkers = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockWorkers), 300);
    });
  }
  const response = await api.get('/workers');
  return response.data;
};

export const getWorkersForMap = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockWorkersForMap), 300);
    });
  }
  const response = await api.get('/workers/map');
  return response.data;
};
