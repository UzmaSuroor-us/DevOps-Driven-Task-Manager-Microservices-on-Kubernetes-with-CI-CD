import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { fileAPI } from '../services/api';
import './FileUpload.css';

const FileUpload: React.FC = () => {
  const navigate = useNavigate();
  const [file, setFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const [message, setMessage] = useState('');

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setFile(e.target.files[0]);
      setMessage('');
    }
  };

  const handleUpload = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!file) {
      setMessage('Please select a file');
      return;
    }

    setUploading(true);
    try {
      const response = await fileAPI.upload(file);
      setMessage(`File uploaded successfully! ID: ${response.data.fileId}`);
      setFile(null);
    } catch (error: any) {
      setMessage(error.response?.data?.message || 'Upload failed');
    } finally {
      setUploading(false);
    }
  };

  return (
    <div className="file-upload-container">
      <div className="file-upload-card">
        <h2>Upload File</h2>
        
        <form onSubmit={handleUpload}>
          <div className="file-input-wrapper">
            <input
              type="file"
              id="file-input"
              onChange={handleFileChange}
              disabled={uploading}
              accept=".png,.jpg,.jpeg,.gif,.bmp,.svg,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv,.zip,.rar"
            />
            <label htmlFor="file-input" className="file-input-label">
              {file ? file.name : 'Choose a file'}
            </label>
          </div>

          {file && (
            <div className="file-info">
              <p>Size: {(file.size / 1024).toFixed(2)} KB</p>
              <p>Type: {file.type || 'Unknown'}</p>
            </div>
          )}

          <button
            type="submit"
            className="btn-upload"
            disabled={!file || uploading}
          >
            {uploading ? 'Uploading...' : 'Upload'}
          </button>
        </form>

        {message && (
          <div className={`message ${message.includes('success') ? 'success' : 'error'}`}>
            {message}
            {message.includes('success') && (
              <button onClick={() => navigate('/dashboard')} className="btn-back">
                Back to Dashboard
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default FileUpload;
