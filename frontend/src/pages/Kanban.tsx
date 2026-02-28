import React, { useEffect, useState } from 'react';
import {
  DndContext,
  DragEndEvent,
  DragOverlay,
  DragStartEvent,
  PointerSensor,
  useSensor,
  useSensors,
} from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { taskAPI } from '../services/api';
import { Task } from '../types';
import KanbanColumn from '../components/KanbanColumn';
import TaskCard from '../components/TaskCard';
import './Kanban.css';

const Kanban: React.FC = () => {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [activeTask, setActiveTask] = useState<Task | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    })
  );

  useEffect(() => {
    fetchTasks();
  }, []);

  const fetchTasks = async () => {
    try {
      const response = await taskAPI.getAll();
      setTasks(response.data);
    } catch (error) {
      console.error('Failed to fetch tasks', error);
    }
  };

  const handleDragStart = (event: DragStartEvent) => {
    const task = tasks.find(t => t.id === event.active.id);
    setActiveTask(task || null);
  };

  const handleDragEnd = async (event: DragEndEvent) => {
    const { active, over } = event;
    
    if (!over) return;

    const taskId = active.id as number;
    const newStatus = over.id as Task['status'];

    if (newStatus === 'TODO' || newStatus === 'IN_PROGRESS' || newStatus === 'DONE') {
      try {
        await taskAPI.updateStatus(taskId, newStatus);
        setTasks(tasks.map(task =>
          task.id === taskId ? { ...task, status: newStatus } : task
        ));
      } catch (error) {
        console.error('Failed to update task status', error);
      }
    }

    setActiveTask(null);
  };

  const columns: Task['status'][] = ['TODO', 'IN_PROGRESS', 'DONE'];

  return (
    <div className="kanban">
      <header className="kanban-header">
        <h1>Kanban Board</h1>
      </header>

      <DndContext
        sensors={sensors}
        onDragStart={handleDragStart}
        onDragEnd={handleDragEnd}
      >
        <div className="kanban-board">
          {columns.map(status => (
            <KanbanColumn
              key={status}
              status={status}
              tasks={tasks.filter(task => task.status === status)}
            />
          ))}
        </div>

        <DragOverlay>
          {activeTask ? <TaskCard task={activeTask} isDragging /> : null}
        </DragOverlay>
      </DndContext>
    </div>
  );
};

export default Kanban;
