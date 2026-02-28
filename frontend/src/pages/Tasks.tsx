import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { taskAPI, projectAPI, userAPI, fileAPI } from '../services/api';
import { Task, Project } from '../types';
import './Dashboard.css';

const Tasks: React.FC = () => {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [users, setUsers] = useState<any[]>([]);
  const [files, setFiles] = useState<any[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [projectId, setProjectId] = useState<number>(0);
  const [status, setStatus] = useState('TODO');
  const [assignedTo, setAssignedTo] = useState('');
  const [fileId, setFileId] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [tasksRes, projectsRes, usersRes, filesRes] = await Promise.all([
        taskAPI.getAll(),
        projectAPI.getAll(),
        userAPI.getAllUsers(),
        fileAPI.getAll(),
      ]);
      setTasks(tasksRes.data);
      setProjects(projectsRes.data);
      setUsers(usersRes.data);
      setFiles(filesRes.data || []);
    } catch (error) {
      console.error('Failed to fetch data', error);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    try {
      await taskAPI.create({ title, description, projectId, status, assignedTo, fileId });
      setTitle('');
      setDescription('');
      setProjectId(0);
      setStatus('TODO');
      setAssignedTo('');
      setFileId('');
      setShowForm(false);
      fetchData();
    } catch (error: any) {
      setError(error.response?.data?.message || 'Failed to create task');
    }
  };

  const handleStatusChange = async (taskId: number, newStatus: string) => {
    try {
      await taskAPI.updateStatus(taskId, newStatus);
      fetchData();
    } catch (error) {
      console.error('Failed to update status', error);
    }
  };

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <h1>📋 Tasks</h1>
        <button onClick={() => navigate('/dashboard')} className="btn-logout">← Back</button>
      </header>

      <div style={{ padding: '40px' }}>
        <button onClick={() => setShowForm(!showForm)} className="btn-add" style={{ marginBottom: '20px' }}>
          {showForm ? '✕ Cancel' : '+ New Task'}
        </button>

        {showForm && (
          <div style={{ background: 'white', padding: '30px', borderRadius: '10px', marginBottom: '30px', boxShadow: '0 2px 8px rgba(0,0,0,0.1)' }}>
            <h2 style={{ marginTop: 0 }}>Create New Task</h2>
            {error && <div style={{ color: '#e74c3c', marginBottom: '15px' }}>{error}</div>}
            <form onSubmit={handleSubmit}>
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '8px', fontWeight: '500' }}>Task Title</label>
                <input
                  type="text"
                  placeholder="Enter task title"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  required
                  style={{ width: '100%', padding: '12px', border: '1px solid #ddd', borderRadius: '5px', fontSize: '14px' }}
                />
              </div>
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '8px', fontWeight: '500' }}>Description</label>
                <textarea
                  placeholder="Enter task description"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows={3}
                  style={{ width: '100%', padding: '12px', border: '1px solid #ddd', borderRadius: '5px', fontSize: '14px', resize: 'vertical' }}
                />
              </div>
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '8px', fontWeight: '500' }}>Project</label>
                <select
                  value={projectId}
                  onChange={(e) => setProjectId(Number(e.target.value))}
                  required
                  style={{ width: '100%', padding: '12px', border: '1px solid #ddd', borderRadius: '5px', fontSize: '14px' }}
                >
                  <option value={0}>Select a project</option>
                  {projects.map(project => (
                    <option key={project.id} value={project.id}>{project.name}</option>
                  ))}
                </select>
              </div>
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '8px', fontWeight: '500' }}>Assign To</label>
                <select
                  value={assignedTo}
                  onChange={(e) => setAssignedTo(e.target.value)}
                  required
                  style={{ width: '100%', padding: '12px', border: '1px solid #ddd', borderRadius: '5px', fontSize: '14px' }}
                >
                  <option value="">Select a user</option>
                  {users.map(user => (
                    <option key={user.id} value={user.email}>{user.name} ({user.email})</option>
                  ))}
                </select>
              </div>
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '8px', fontWeight: '500' }}>Attach File (optional)</label>
                <select
                  value={fileId}
                  onChange={(e) => setFileId(e.target.value)}
                  style={{ width: '100%', padding: '12px', border: '1px solid #ddd', borderRadius: '5px', fontSize: '14px' }}
                >
                  <option value="">No file</option>
                  {files.map(file => (
                    <option key={file.id} value={file.id}>{file.fileName}</option>
                  ))}
                </select>
                <small style={{ color: '#666', marginTop: '5px', display: 'block' }}>
                  Upload files from <span onClick={() => navigate('/upload')} style={{ color: '#667eea', cursor: 'pointer', textDecoration: 'underline' }}>here</span>
                </small>
              </div>
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '8px', fontWeight: '500' }}>Status</label>
                <select
                  value={status}
                  onChange={(e) => setStatus(e.target.value)}
                  style={{ width: '100%', padding: '12px', border: '1px solid #ddd', borderRadius: '5px', fontSize: '14px' }}
                >
                  <option value="TODO">To Do</option>
                  <option value="IN_PROGRESS">In Progress</option>
                  <option value="DONE">Done</option>
                </select>
              </div>
              <button type="submit" className="btn-add">Create Task</button>
            </form>
          </div>
        )}

        <div className="tasks-list">
          {tasks.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px', color: '#999' }}>
              <h3>No tasks yet</h3>
              <p>Create your first task to get started!</p>
            </div>
          ) : (
            tasks.map(task => (
              <div key={task.id} className="task-item">
                <div className="task-info">
                  <h4>✓ {task.title}</h4>
                  <p>{task.description || 'No description'}</p>
                  <small style={{ color: '#999' }}>
                    Project: {projects.find(p => p.id === task.projectId)?.name || 'Unknown'}
                    {task.assignedTo && ` • Assigned to: ${task.assignedTo}`}
                    {task.fileId && ` • 📎 File attached`}
                  </small>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', alignItems: 'flex-end' }}>
                  <span className={`task-status status-${task.status.toLowerCase()}`}>
                    {task.status.replace('_', ' ')}
                  </span>
                  <select
                    value={task.status}
                    onChange={(e) => handleStatusChange(task.id, e.target.value)}
                    style={{ padding: '6px 10px', border: '1px solid #ddd', borderRadius: '5px', fontSize: '12px' }}
                  >
                    <option value="TODO">TODO</option>
                    <option value="IN_PROGRESS">IN PROGRESS</option>
                    <option value="DONE">DONE</option>
                  </select>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default Tasks;
