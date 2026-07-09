import api from './axiosConfig';

const USE_MOCK = import.meta.env.VITE_USE_MOCK_DATA === 'true';

// ── SINGLE SHARED SOURCE OF TRUTH for all 6 workers ─────────────────
// Used by BOTH Workers.jsx (list view) and LiveTracking.jsx (map view)
// so names, status, and current task always match everywhere.
let mockWorkers = [
  { id: 1, name: 'Ravi',    zone: 'Zone A', phone: '+91 98765 43210', status: 'On Duty',  tasks: 4, completed: 18, currentTask: 'None', battery: 88, sos: false, progress: 0, lat: 11.0168, lng: 76.9558 },
  { id: 2, name: 'Suresh',  zone: 'Zone B', phone: '+91 98765 43211', status: 'Off Duty', tasks: 2, completed: 12, currentTask: 'None', battery: 74, sos: false, progress: 0, lat: 11.0210, lng: 76.9640 },
  { id: 3, name: 'Anu',     zone: 'Zone C', phone: '+91 98765 43212', status: 'On Leave', tasks: 1, completed: 9,  currentTask: 'None', battery: 55, sos: false, progress: 0, lat: 11.0140, lng: 76.9500 },
  { id: 4, name: 'Mohan',   zone: 'Zone D', phone: '+91 98765 43213', status: 'On Duty',  tasks: 3, completed: 16, currentTask: 'None', battery: 90, sos: false, progress: 0, lat: 11.0090, lng: 76.9610 },
  { id: 5, name: 'Deepa',   zone: 'Zone E', phone: '+91 98765 43214', status: 'On Duty',  tasks: 5, completed: 22, currentTask: 'None', battery: 67, sos: false, progress: 0, lat: 11.0230, lng: 76.9520 },
  { id: 6, name: 'Karthik', zone: 'Zone F', phone: '+91 98765 43215', status: 'Off Duty', tasks: 0, completed: 6,  currentTask: 'None', battery: 30, sos: false, progress: 0, lat: 11.0050, lng: 76.9450 },
];

// Off Duty and On Leave workers stay fixed. Only On Duty workers drift
// slightly on each poll to simulate real GPS movement.
function simulateMovement(worker) {
  const isStationary = worker.status === 'Off Duty' || worker.status === 'On Leave';
  if (isStationary) return worker;
  const drift = () => (Math.random() - 0.5) * 0.0018;
  return { ...worker, lat: worker.lat + drift(), lng: worker.lng + drift() };
}

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
    mockWorkers = mockWorkers.map(simulateMovement);
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockWorkers), 300);
    });
  }
  const response = await api.get('/workers/map');
  return response.data;
};

// Assign a worker to a complaint — updates the SAME shared dataset
export const assignWorkerToComplaint = async (workerId, complaintId) => {
  if (USE_MOCK) {
    mockWorkers = mockWorkers.map(w =>
      w.id === workerId ? { ...w, currentTask: `Complaint ${complaintId}`, progress: 10 } : w
    );
    return new Promise((resolve) => setTimeout(() => resolve({ success: true }), 200));
  }
  const response = await api.patch(`/workers/${workerId}/assign`, { complaintId });
  return response.data;
};

// Free up a worker — used before Reassign so they become idle again
export const unassignWorker = async (workerId) => {
  if (USE_MOCK) {
    mockWorkers = mockWorkers.map(w =>
      w.id === workerId ? { ...w, currentTask: 'None', progress: 0 } : w
    );
    return new Promise((resolve) => setTimeout(() => resolve({ success: true }), 200));
  }
  const response = await api.patch(`/workers/${workerId}/unassign`);
  return response.data;
};
