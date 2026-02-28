import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { projectAPI } from '../services/api';
import { Project } from '../types';
import './Dashboard.css';

const Projects: React.FC = () => {
  const [projects, setProjects] = useState<Project[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    fetchProjects();
  }, []);

  const fetchProjects = async () => {
    try {
      const res = await projectAPI.getAll();
      setProjects(res.data);
    } catch (error) {
      console.error('Failed to fetch projects', error);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    try {
      await projectAPI.create({ name, description });
      setName('');
      setDescription('');
      setShowForm(false);
      fetchProjects();
    } catch (error: any) {
      setError(error.response?.data?.message || 'Failed to create project');
    }
  };

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <h1>📁 Projects</h1>
        <button onClick={() => navigate('/dashboard')} className="btn-logout">← Back</button>
      </header>

      <div style={{ padding: '40px' }}>
        <button onClick={() => setShowForm(!showForm)} className="btn-add" style={{ marginBottom: '20px' }}>
          {showForm ? '✕ Cancel' : '+ New Project'}
        </button>

        {showForm && (
          <div style={{ background: 'white', padding: '30px', borderRadius: '10px', marginBottom: '30px', boxShadow: '0 2px 8px rgba(0,0,0,0.1)' }}>
            <h2 style={{ marginTop: 0 }}>Create New Project</h2>
            {error && <div style={{ color: '#e74c3c', marginBottom: '15px' }}>{error}</div>}
            <form onSubmit={handleSubmit}>
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '8px', fontWeight: '500' }}>Project Name</label>
                <input
                  type="text"
                  placeholder="Enter project name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  required
                  style={{ width: '100%', padding: '12px', border: '1px solid #ddd', borderRadius: '5px', fontSize: '14px' }}
                />
              </div>
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '8px', fontWeight: '500' }}>Description</label>
                <textarea
                  placeholder="Enter project description"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows={4}
                  style={{ width: '100%', padding: '12px', border: '1px solid #ddd', borderRadius: '5px', fontSize: '14px', resize: 'vertical' }}
                />
              </div>
              <button type="submit" className="btn-add">Create Project</button>
            </form>
          </div>
        )}

        <div className="projects-list">
          {projects.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px', color: '#999' }}>
              <h3>No projects yet</h3>
              <p>Create your first project to get started!</p>
            </div>
          ) : (
            projects.map(project => (
              <div key={project.id} className="project-card">
                <h3>📋 {project.name}</h3>
                <p>{project.description || 'No description'}</p>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default Projects;
