import api from './axiosConfig';

export const getMyProfile = async () => {
  const response = await api.get('/auth/me');
  return response.data.data;
};

export const updateMyProfile = async (data) => {
  const response = await api.put('/auth/me', data);
  return response.data.data;
};
