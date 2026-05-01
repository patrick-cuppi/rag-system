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
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.detail || 'Upload failed');
  }
  return response.json();
};

export const chatWithAskMe = async (
  question: string,
  conversation_id?: number,
) => {
  const body: { question: string; conversation_id?: number } = { question };
  if (conversation_id) body.conversation_id = conversation_id;

  const response = await fetch("/api/chat", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (response.status === 401) handleUnauthorized();
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.detail || "Chat request failed");
  }
  return response.json();
};

export const getConversations = async () => {
  const response = await fetch("/api/conversations");
  if (response.status === 401) handleUnauthorized();
  if (!response.ok) throw new Error("Failed to fetch conversations");
  return response.json();
};

export const getConversationMessages = async (id: number) => {
  const response = await fetch(`/api/conversations/${id}`);
  if (response.status === 401) handleUnauthorized();
  if (!response.ok) throw new Error("Failed to fetch conversation");
  return response.json();
};

export const getTaskStatus = async (taskId: string) => {
  const response = await fetch(`/api/tasks/${taskId}`);
  if (response.status === 401) handleUnauthorized();
  if (!response.ok) throw new Error("Failed to fetch task status");
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
