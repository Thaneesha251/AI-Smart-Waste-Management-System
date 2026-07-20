import api from './axiosConfig';

const USE_MOCK = import.meta.env.VITE_USE_MOCK_DATA === 'true';

export const login = async (email, password) => {
  if (USE_MOCK) {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve({
          access_token: 'mock-token-12345',
          user: { name: 'Admin Officer', role: 'admin' }
        });
      }, 300);
    });
  }

  const formData = new URLSearchParams();
  formData.append('grant_type', 'password');
  formData.append('username', email);
  formData.append('password', password);

  const response = await api.post('/auth/login', formData, {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
  });

  return response.data.data;
};

export const logout = async () => {
  localStorage.removeItem('authToken');
  localStorage.removeItem('authUser');
  localStorage.removeItem('isLoggedIn');
  return { success: true };
};