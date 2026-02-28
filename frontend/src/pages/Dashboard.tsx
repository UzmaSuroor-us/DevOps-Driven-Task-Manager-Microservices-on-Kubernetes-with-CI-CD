import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { projectAPI, taskAPI, fileAPI } from '../services/api';
import { Project, Task } from '../types';
import { useAuth } from '../context/AuthContext';
import './Dashboard.css';

const Dashboard: React.FC = () => {
  const [projects, setProjects] = useState<Project[]>([]);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [files, setFiles] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    fetchData();
    // Auto-refresh every 30 seconds
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, []);

  const fetchData = async () => {
    try {
      const [projectsRes, tasksRes] = await Promise.all([
        projectAPI.getAll(),
        taskAPI.getAll(),
      ]);
      setProjects(projectsRes.data);
      setTasks(tasksRes.data);
      
      // Fetch files separately to avoid blocking
      try {
        const filesRes = await fileAPI.getAll();
        setFiles(filesRes.data || []);
      } catch (err) {
        console.log('Files endpoint not available');
        setFiles([]);
      }
    } catch (error) {
      console.error('Failed to fetch data', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteFile = async (fileName: string) => {
    if (!window.confirm(`Delete ${fileName}?`)) return;
    try {
      await fileAPI.delete(fileName);
      setFiles(files.filter(f => f !== fileName));
    } catch (error) {
      alert('Failed to delete file');
    }
  };

  const getTaskStats = () => {
    return {
      total: tasks.length,
      todo: tasks.filter(t => t.status === 'TODO').length,
      inProgress: tasks.filter(t => t.status === 'IN_PROGRESS').length,
      done: tasks.filter(t => t.status === 'DONE').length,
    };
  };

  const stats = getTaskStats();

  if (loading) return <div className="loading">Loading...</div>;

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <h1>Task Manager Dashboard</h1>
        <div className="user-info">
          <button onClick={() => navigate('/upload')} className="btn-view" style={{ marginRight: '10px' }}>Upload Files</button>
          <span>Welcome, {user?.email}</span>
          <button onClick={logout} className="btn-logout">Logout</button>
        </div>
      </header>

      <div className="stats-grid">
        <div className="stat-card">
          <h3>Total Projects</h3>
          <p className="stat-number">{projects.length}</p>
        </div>
        <div className="stat-card">
          <h3>Total Tasks</h3>
          <p className="stat-number">{stats.total}</p>
        </div>
        <div className="stat-card">
          <h3>In Progress</h3>
          <p className="stat-number">{stats.inProgress}</p>
        </div>
        <div className="stat-card">
          <h3>Uploaded Files</h3>
          <p className="stat-number">{files.length}</p>
        </div>
      </div>

      <div className="content-grid">
        <div className="projects-section">
          <div className="section-header">
            <h2>Projects</h2>
            <button onClick={() => navigate('/projects')} className="btn-add">
              Manage Projects
            </button>
          </div>
          <div className="projects-list">
            {projects.map(project => (
              <div
                key={project.id}
                className="project-card"
              >
                <h3>{project.name}</h3>
                <p>{project.description}</p>
                <div className="project-meta">
                  <span>{tasks.filter(t => t.projectId === project.id).length} tasks</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="tasks-section">
          <div className="section-header">
            <h2>Recent Tasks</h2>
            <button onClick={() => navigate('/tasks')} className="btn-view">
              Manage Tasks
            </button>
          </div>
          <div className="tasks-list">
            {tasks.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '40px', color: '#999' }}>
                <p>No tasks yet</p>
              </div>
            ) : (
              tasks.slice(0, 5).map(task => (
                <div key={task.id} className="task-item">
                  <div className="task-info">
                    <h4>{task.title}</h4>
                    <p>{task.description}</p>
                    {task.fileId && <small style={{ color: '#667eea' }}>📎 File attached</small>}
                  </div>
                  <span className={`task-status status-${task.status.toLowerCase()}`}>
                    {task.status.replace('_', ' ')}
                  </span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      <div style={{ padding: '0 40px 40px' }}>
        <div className="section-header">
          <h2>Uploaded Files</h2>
          <button onClick={() => navigate('/upload')} className="btn-add">
            Upload New
          </button>
        </div>
        <div className="projects-list">
          {files.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '40px', color: '#999', background: 'white', borderRadius: '8px' }}>
              <p>No files uploaded yet</p>
            </div>
          ) : (
            files.map((file, index) => (
              <div key={index} style={{ background: 'white', padding: '15px 20px', borderRadius: '8px', boxShadow: '0 2px 4px rgba(0,0,0,0.1)', display: 'flex', alignItems: 'center', gap: '10px' }}>
                <span style={{ fontSize: '24px' }}>📄</span>
                <span style={{ flex: 1, color: '#333' }}>{file}</span>
                <button onClick={() => handleDeleteFile(file)} style={{ padding: '6px 12px', background: '#ff4444', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '12px' }}>Delete</button>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
