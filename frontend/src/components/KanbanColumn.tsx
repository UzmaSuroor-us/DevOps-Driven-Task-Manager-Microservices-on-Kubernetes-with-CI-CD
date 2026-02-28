import React from 'react';
import { useDroppable } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { Task } from '../types';
import TaskCard from './TaskCard';
import './KanbanColumn.css';

interface KanbanColumnProps {
  status: Task['status'];
  tasks: Task[];
}

const statusLabels = {
  TODO: 'To Do',
  IN_PROGRESS: 'In Progress',
  DONE: 'Done',
};

const KanbanColumn: React.FC<KanbanColumnProps> = ({ status, tasks }) => {
  const { setNodeRef } = useDroppable({ id: status });

  return (
    <div className="kanban-column">
      <div className={`column-header status-${status.toLowerCase()}`}>
        <h3>{statusLabels[status]}</h3>
        <span className="task-count">{tasks.length}</span>
      </div>

      <div ref={setNodeRef} className="column-content">
        <SortableContext
          items={tasks.map(t => t.id)}
          strategy={verticalListSortingStrategy}
        >
          {tasks.map(task => (
            <TaskCard key={task.id} task={task} />
          ))}
        </SortableContext>
      </div>
    </div>
  );
};

export default KanbanColumn;
