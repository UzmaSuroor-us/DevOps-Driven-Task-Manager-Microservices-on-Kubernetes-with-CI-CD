export interface User {
  id: number;
  name: string;
  email: string;
  role: string;
}

export interface Project {
  id: number;
  name: string;
  description: string;
  ownerId: number;
  createdAt: string;
  updatedAt: string;
}

export interface Task {
  id: number;
  title: string;
  description: string;
  status: 'TODO' | 'IN_PROGRESS' | 'DONE';
  priority: 'LOW' | 'MEDIUM' | 'HIGH';
  projectId: number;
  assignedTo?: number;
  dueDate?: string;
  fileId?: string;
  createdAt: string;
  updatedAt: string;
}

export interface AuthContextType {
  user: User | null;
  token: string | null;
  login: (email: string, password: string) => Promise<void>;
  googleLogin: (token: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
}
