import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { taskAPI, projectAPI } from '../services/api';
import { Task, Project } from '../types';
import './Dashboard.css';

const Completed: React.FC = () => {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const navigate = useNavigate();

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [tasksRes, projectsRes] = await Promise.all([
        taskAPI.getAll(),
        projectAPI.getAll(),
      ]);
      setTasks(tasksRes.data.filter((t: Task) => t.status === 'DONE'));
      setProjects(projectsRes.data);
    } catch (error) {
      console.error('Failed to fetch data', error);
    }
  };

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <h1>✅ Completed Tasks</h1>
        <button onClick={() => navigate('/dashboard')} className="btn-logout">← Back</button>
      </header>

      <div style={{ padding: '40px' }}>
        <div className="tasks-list">
          {tasks.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px', color: '#999' }}>
              <h3>No completed tasks yet</h3>
              <p>Complete some tasks to see them here!</p>
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
                <span className="task-status status-done">
                  DONE
                </span>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default Completed;
