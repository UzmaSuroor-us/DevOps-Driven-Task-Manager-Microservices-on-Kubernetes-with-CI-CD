import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Auth API
export const authAPI = {
  login: (email: string, password: string) =>
    api.post('/user-service/api/auth/login', { email, password }),
  
  register: (name: string, email: string, password: string) =>
    api.post('/user-service/api/auth/register', { name, email, password }),
  
  googleLogin: (token: string) =>
    api.post('/user-service/api/auth/google', { token }),
};

// Project API
export const projectAPI = {
  getAll: () => api.get('/project-service/api/projects'),
  getById: (id: number) => api.get(`/project-service/api/projects/${id}`),
  create: (data: any) => api.post('/project-service/api/projects', data),
  update: (id: number, data: any) => api.put(`/project-service/api/projects/${id}`, data),
  delete: (id: number) => api.delete(`/project-service/api/projects/${id}`),
};

// Task API
export const taskAPI = {
  getAll: () => api.get('/task-service/api/tasks'),
  getByProject: (projectId: number) => api.get(`/task-service/api/tasks/project/${projectId}`),
  getById: (id: number) => api.get(`/task-service/api/tasks/${id}`),
  create: (data: any) => api.post('/task-service/api/tasks', data),
  update: (id: number, data: any) => api.put(`/task-service/api/tasks/${id}`, data),
  delete: (id: number) => api.delete(`/task-service/api/tasks/${id}`),
  updateStatus: (id: number, status: string) =>
    api.patch(`/task-service/api/tasks/${id}/status`, { status }),
};

// File API
export const fileAPI = {
  upload: (file: File) => {
    const formData = new FormData();
    formData.append('file', file);
    return api.post('/file-upload-service/api/files/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },
  download: (fileId: string) => api.get(`/file-upload-service/api/files/${fileId}`),
  getAll: () => api.get('/file-upload-service/api/files'),
  delete: (fileName: string) => api.delete(`/file-upload-service/api/files/${fileName}`),
};

// User API
export const userAPI = {
  getAllUsers: () => api.get('/user-service/api/auth/all'),
};

export default api;
