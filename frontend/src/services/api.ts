import Cookies from 'js-cookie';

const API_URL = process.env.NEXT_PUBLIC_API_URL ? `${process.env.NEXT_PUBLIC_API_URL}/api` : 'http://localhost:8000/api';

const getAuthHeaders = (): Record<string, string> => {
  const token = Cookies.get('access_token');
  return token ? { 'Authorization': `Bearer ${token}` } : {};
};

const handleUnauthorized = () => {
  Cookies.remove('access_token');
  Cookies.remove('refresh_token');
  if (typeof window !== 'undefined') {
    window.location.assign('/login');
  }
};

export const uploadDocument = async (file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  
  const response = await fetch(`${API_URL}/upload`, {
    method: 'POST',
    headers: {
      ...getAuthHeaders(),
    },
    body: formData,
  });
  
  if (response.status === 401) handleUnauthorized();
  if (!response.ok) throw new Error('Upload failed');
  return response.json();
};

export const chatWithAskMe = async (question: string) => {
  const response = await fetch(`${API_URL}/chat`, {
    method: 'POST',
    headers: { 
      'Content-Type': 'application/json',
      ...getAuthHeaders(),
    },
    body: JSON.stringify({ question }),
  });
  
  if (response.status === 401) handleUnauthorized();
  if (!response.ok) throw new Error('Chat request failed');
  return response.json();
};

export const login = async (username: string, password: string) => {
  const formData = new URLSearchParams();
  formData.append('username', username);
  formData.append('password', password);

  const response = await fetch(`${API_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: formData,
  });

  if (!response.ok) throw new Error('Login failed');
  const data = await response.json();
  
  Cookies.set('access_token', data.access_token, { expires: 1/48 }); // 30 min
  Cookies.set('refresh_token', data.refresh_token, { expires: 7 }); // 7 days
  return data;
};

export const registerUser = async (email: string, password: string) => {
  const response = await fetch(`${API_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });

  if (!response.ok) throw new Error('Registration failed');
  return response.json();
};

export const logout = () => {
  Cookies.remove('access_token');
  Cookies.remove('refresh_token');
  if (typeof window !== 'undefined') window.location.assign('/login');
};
