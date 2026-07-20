import api from './axiosConfig';

const USE_MOCK = import.meta.env.VITE_USE_MOCK_DATA === 'true';

let mockWorkers = [
  { id: 1, name: 'Ravi',    zone: 'Zone A', phone: '+91 98765 43210', status: 'On Duty',  tasks: 4, completed: 18, currentTask: 'None', battery: 88, sos: false, progress: 0, lat: 11.0168, lng: 76.9558 },
  { id: 2, name: 'Suresh',  zone: 'Zone B', phone: '+91 98765 43211', status: 'Off Duty', tasks: 2, completed: 12, currentTask: 'None', battery: 74, sos: false, progress: 0, lat: 11.0210, lng: 76.9640 },
  { id: 3, name: 'Anu',     zone: 'Zone C', phone: '+91 98765 43212', status: 'On Leave', tasks: 1, completed: 9,  currentTask: 'None', battery: 55, sos: false, progress: 0, lat: 11.0140, lng: 76.9500 },
  { id: 4, name: 'Mohan',   zone: 'Zone D', phone: '+91 98765 43213', status: 'On Duty',  tasks: 3, completed: 16, currentTask: 'None', battery: 90, sos: false, progress: 0, lat: 11.0090, lng: 76.9610 },
  { id: 5, name: 'Deepa',   zone: 'Zone E', phone: '+91 98765 43214', status: 'On Duty',  tasks: 5, completed: 22, currentTask: 'None', battery: 67, sos: false, progress: 0, lat: 11.0230, lng: 76.9520 },
  { id: 6, name: 'Karthik', zone: 'Zone F', phone: '+91 98765 43215', status: 'Off Duty', tasks: 0, completed: 6,  currentTask: 'None', battery: 30, sos: false, progress: 0, lat: 11.0050, lng: 76.9450 },
];

function simulateMovement(worker) {
  const isStationary = worker.status === 'Off Duty' || worker.status === 'On Leave';
  if (isStationary) return worker;
  const drift = () => (Math.random() - 0.5) * 0.0018;
  return { ...worker, lat: worker.lat + drift(), lng: worker.lng + drift() };
}

const STATUS_LABELS = {
  online: 'On Duty',
  'on-job': 'On Job',
  offline: 'Off Duty',
};

const DEFAULT_LAT = 11.0168;
const DEFAULT_LNG = 76.9558;

const transformWorker = (w) => ({
  id: w.id,
  name: w.name,
  zone: w.zone || 'Unassigned',
  phone: w.phone,
  status: STATUS_LABELS[w.status] || w.status,
  tasks: w.current_job_id ? 1 : 0,
  completed: w.complaints_completed || 0,
  currentTask: w.current_job_id ? `Complaint ${w.current_job_id}` : 'None',
  battery: 100,
  sos: false,
  progress: 0,
  lat: w.latitude ?? DEFAULT_LAT,
  lng: w.longitude ?? DEFAULT_LNG,
});

export const getWorkers = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockWorkers), 300);
    });
  }
  const response = await api.get('/workers/');
  const results = response.data.data || [];
  return results.map(transformWorker);
};

export const getWorkersForMap = async () => {
  if (USE_MOCK) {
    mockWorkers = mockWorkers.map(simulateMovement);
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockWorkers), 300);
    });
  }
  const response = await api.get('/workers/');
  const results = response.data.data || [];
  return results.map(transformWorker);
};

export const assignWorkerToComplaint = async (workerId, complaintId) => {
  if (USE_MOCK) {
    mockWorkers = mockWorkers.map(w =>
      w.id === workerId ? { ...w, currentTask: `Complaint ${complaintId}`, progress: 10 } : w
    );
    return new Promise((resolve) => setTimeout(() => resolve({ success: true }), 200));
  }
  const response = await api.post(`/complaints/complaints/${complaintId}/assign`, { worker_id: workerId });
  return response.data;
};

export const unassignWorker = async (workerId, complaintId) => {
  if (USE_MOCK) {
    mockWorkers = mockWorkers.map(w =>
      w.id === workerId ? { ...w, currentTask: 'None', progress: 0 } : w
    );
    return new Promise((resolve) => setTimeout(() => resolve({ success: true }), 200));
  }
  const response = await api.delete(`/complaints/complaints/${complaintId}/assign`);
  return response.data;
};

export const addWorker = async (newWorker) => {
  if (USE_MOCK) {
    const nextId = mockWorkers.length > 0 ? Math.max(...mockWorkers.map(w => w.id)) + 1 : 1;
    const worker = {
      id: nextId,
      name: newWorker.name,
      zone: newWorker.zone,
      phone: newWorker.phone,
      status: 'On Duty',
      tasks: 0,
      completed: 0,
      currentTask: 'None',
      battery: 100,
      sos: false,
      progress: 0,
      lat: 11.0168 + (Math.random() - 0.5) * 0.02,
      lng: 76.9558 + (Math.random() - 0.5) * 0.02,
    };
    mockWorkers = [...mockWorkers, worker];
    return new Promise((resolve) => setTimeout(() => resolve(worker), 200));
  }
  const response = await api.post('/workers/', {
    name: newWorker.name,
    zone: newWorker.zone,
    phone: newWorker.phone,
    email: `${newWorker.name.toLowerCase().replace(/\s+/g, '.')}@placeholder.com`,
    is_verified: false,
    user_id: 1,
  });
  return transformWorker(response.data.data);
};