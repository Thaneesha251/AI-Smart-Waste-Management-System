import api from './axiosConfig';

const USE_MOCK = import.meta.env.VITE_USE_MOCK_DATA === 'true';

const mockVerifications = [
  {
    id: 'V001',
    complaint: 'Garbage Overflow',
    worker: 'Ravi',
    type: 'Photo Proof',
    zone: 'Zone 1',
    submitted: '22 May 2025, 10:00 AM',
    status: 'Pending',
    similarity: '95%',
    beforeImg: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=600&h=400&fit=crop&q=80',
    afterImg: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&h=400&fit=crop&q=80',
  },
  {
    id: 'V002',
    complaint: 'Illegal Dumping',
    worker: 'Suresh',
    type: 'Photo Proof',
    zone: 'Zone 2',
    submitted: '22 May 2025, 09:30 AM',
    status: 'Approved',
    similarity: '88%',
    beforeImg: 'https://images.unsplash.com/photo-1605600659908-0ef719419d41?w=600&h=400&fit=crop&q=80',
    afterImg: 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=600&h=400&fit=crop&q=80',
  },
  {
    id: 'V003',
    complaint: 'Roadside Waste',
    worker: 'Anu',
    type: 'Photo Proof',
    zone: 'Zone 3',
    submitted: '21 May 2025, 17:00 AM',
    status: 'Pending',
    similarity: '72%',
    beforeImg: 'https://images.unsplash.com/photo-1567870374493-4eca3b682a55?w=600&h=400&fit=crop&q=80',
    afterImg: 'https://images.unsplash.com/photo-1490351267196-b7a67e26e41b?w=600&h=400&fit=crop&q=80',
  },
  {
    id: 'V004',
    complaint: 'Bin Full',
    worker: 'Karthik',
    type: 'Photo Proof',
    zone: 'Zone 4',
    submitted: '21 May 2025, 14:00 AM',
    status: 'Rejected',
    similarity: '45%',
    beforeImg: 'https://images.unsplash.com/photo-1611284446314-60a58ac0deb9?w=600&h=400&fit=crop&q=80',
    afterImg: 'https://images.unsplash.com/photo-1572190043778-8f47e0e51b86?w=600&h=400&fit=crop&q=80',
  },
];

export const getVerifications = async () => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockVerifications), 300);
    });
  }
  const response = await api.get('/verifications');
  return response.data;
};

export const updateVerification = async (id, status, comment) => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => resolve({ id, status, comment }), 300);
    });
  }
  const response = await api.patch(`/verifications/${id}`, { status, comment });
  return response.data;
};
