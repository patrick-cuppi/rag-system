const handleUnauthorized = () => {
  if (typeof window !== 'undefined') {
    window.location.assign('/login');
  }
};

export const uploadDocument = async (file: File) => {
  const formData = new FormData();
  formData.append('file', file);

  const response = await fetch('/api/upload', {
    method: 'POST',
    body: formData,
  });

  if (response.status === 401) handleUnauthorized();
  if (!response.ok) throw new Error('Upload failed');
  return response.json();
};

export const chatWithAskMe = async (question: string) => {
  const response = await fetch('/api/chat', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ question }),
  });

  if (response.status === 401) handleUnauthorized();
  if (!response.ok) throw new Error('Chat request failed');
  return response.json();
};

export const login = async (username: string, password: string) => {
  const formData = new FormData();
  formData.append('username', username);
  formData.append('password', password);

  const response = await fetch('/api/auth/login', {
    method: 'POST',
    body: formData,
  });

  if (!response.ok) throw new Error('Login failed');
  return response.json();
};

export const registerUser = async (email: string, password: string) => {
  const response = await fetch('/api/auth/register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });

  if (!response.ok) throw new Error('Registration failed');
  return response.json();
};

export const logout = async () => {
  await fetch('/api/auth/logout', { method: 'POST' });
  if (typeof window !== 'undefined') window.location.assign('/login');
};
