// Secure Web App - Task Manager JavaScript

// API Base URL - will use same origin
const API_URL = '/api/tasks';

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    checkHealth();
    loadTasks();
    
    // Refresh health status every 30 seconds
    setInterval(checkHealth, 30000);
});

// Check API Health Status
async function checkHealth() {
    try {
        const response = await fetch('/health');
        const data = await response.json();
        
        const indicator = document.getElementById('health-indicator');
        const text = document.getElementById('health-text');
        
        if (data.status === 'healthy') {
            indicator.classList.add('healthy');
            indicator.classList.remove('unhealthy');
            text.textContent = 'Healthy';
        } else {
            indicator.classList.add('unhealthy');
            indicator.classList.remove('healthy');
            text.textContent = 'Unhealthy';
        }
    } catch (error) {
        console.error('Health check failed:', error);
        const indicator = document.getElementById('health-indicator');
        const text = document.getElementById('health-text');
        indicator.classList.add('unhealthy');
        indicator.classList.remove('healthy');
        text.textContent = 'Error';
    }
}

// Load all tasks from API
async function loadTasks() {
    const container = document.getElementById('tasks-container');
    
    try {
        const response = await fetch(API_URL);
        
        if (!response.ok) {
            throw new Error('Failed to load tasks');
        }
        
        const data = await response.json();
        const tasks = data.tasks || [];
        
        // Update statistics
        updateStats(tasks);
        
        // Render tasks
        if (tasks.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <i class="bi bi-inbox"></i>
                    <h5>No tasks yet</h5>
                    <p>Click "Add New Task" to create your first task</p>
                </div>
            `;
        } else {
            container.innerHTML = tasks.map(task => renderTask(task)).join('');
        }
    } catch (error) {
        console.error('Error loading tasks:', error);
        container.innerHTML = `
            <div class="alert alert-danger m-3" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i>
                Failed to load tasks. Please try again later.
            </div>
        `;
    }
}

// Render a single task
function renderTask(task) {
    const completedClass = task.completed ? 'completed' : '';
    const statusBadge = task.completed 
        ? '<span class="badge bg-success">Completed</span>'
        : '<span class="badge bg-warning text-dark">Pending</span>';
    
    return `
        <div class="task-item ${completedClass}">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h6 class="task-title">
                        <i class="bi bi-${task.completed ? 'check-circle-fill text-success' : 'circle'} me-2"></i>
                        ${escapeHtml(task.title)}
                    </h6>
                    ${task.description ? `<p class="task-description mb-2">${escapeHtml(task.description)}</p>` : ''}
                    <div class="task-meta">
                        <small>
                            <i class="bi bi-calendar me-1"></i>
                            Created: ${formatDate(task.created_at)}
                        </small>
                    </div>
                </div>
                <div class="col-md-4 text-md-end mt-3 mt-md-0">
                    <div class="task-actions">
                        ${statusBadge}
                        <button class="btn btn-outline-primary btn-sm" onclick="editTask(${task.id})">
                            <i class="bi bi-pencil"></i> Edit
                        </button>
                        <button class="btn btn-outline-danger btn-sm" onclick="deleteTask(${task.id})">
                            <i class="bi bi-trash"></i> Delete
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `;
}

// Update statistics
function updateStats(tasks) {
    const total = tasks.length;
    const completed = tasks.filter(t => t.completed).length;
    const pending = total - completed;
    
    document.getElementById('total-tasks').textContent = total;
    document.getElementById('completed-tasks').textContent = completed;
    document.getElementById('pending-tasks').textContent = pending;
}

// Add new task
async function addTask() {
    const title = document.getElementById('task-title').value.trim();
    const description = document.getElementById('task-description').value.trim();
    const completed = document.getElementById('task-completed').checked;
    
    if (!title) {
        showToast('Please enter a task title', 'warning');
        return;
    }
    
    const taskData = {
        title: title,
        description: description,
        completed: completed
    };
    
    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(taskData)
        });
        
        if (!response.ok) {
            throw new Error('Failed to create task');
        }
        
        // Close modal
        const modal = bootstrap.Modal.getInstance(document.getElementById('addTaskModal'));
        modal.hide();
        
        // Reset form
        document.getElementById('add-task-form').reset();
        
        // Reload tasks
        await loadTasks();
        
        showToast('Task created successfully!', 'success');
    } catch (error) {
        console.error('Error creating task:', error);
        showToast('Failed to create task. Please try again.', 'danger');
    }
}

// Edit task - populate modal with task data
async function editTask(taskId) {
    try {
        const response = await fetch(`${API_URL}/${taskId}`);
        
        if (!response.ok) {
            throw new Error('Failed to fetch task');
        }
        
        const data = await response.json();
        const task = data.task;
        
        // Populate edit form
        document.getElementById('edit-task-id').value = task.id;
        document.getElementById('edit-task-title').value = task.title;
        document.getElementById('edit-task-description').value = task.description || '';
        document.getElementById('edit-task-completed').checked = task.completed;
        
        // Show modal
        const modal = new bootstrap.Modal(document.getElementById('editTaskModal'));
        modal.show();
    } catch (error) {
        console.error('Error loading task:', error);
        showToast('Failed to load task details', 'danger');
    }
}

// Update task
async function updateTask() {
    const taskId = document.getElementById('edit-task-id').value;
    const title = document.getElementById('edit-task-title').value.trim();
    const description = document.getElementById('edit-task-description').value.trim();
    const completed = document.getElementById('edit-task-completed').checked;
    
    if (!title) {
        showToast('Please enter a task title', 'warning');
        return;
    }
    
    const taskData = {
        title: title,
        description: description,
        completed: completed
    };
    
    try {
        const response = await fetch(`${API_URL}/${taskId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(taskData)
        });
        
        if (!response.ok) {
            throw new Error('Failed to update task');
        }
        
        // Close modal
        const modal = bootstrap.Modal.getInstance(document.getElementById('editTaskModal'));
        modal.hide();
        
        // Reload tasks
        await loadTasks();
        
        showToast('Task updated successfully!', 'success');
    } catch (error) {
        console.error('Error updating task:', error);
        showToast('Failed to update task. Please try again.', 'danger');
    }
}

// Delete task
async function deleteTask(taskId) {
    if (!confirm('Are you sure you want to delete this task?')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_URL}/${taskId}`, {
            method: 'DELETE'
        });
        
        if (!response.ok) {
            throw new Error('Failed to delete task');
        }
        
        // Reload tasks
        await loadTasks();
        
        showToast('Task deleted successfully!', 'success');
    } catch (error) {
        console.error('Error deleting task:', error);
        showToast('Failed to delete task. Please try again.', 'danger');
    }
}

// Show toast notification
function showToast(message, type = 'info') {
    const toastContainer = document.getElementById('toast-container') || createToastContainer();
    
    const toastId = `toast-${Date.now()}`;
    const bgClass = `bg-${type}`;
    const textClass = type === 'warning' ? 'text-dark' : 'text-white';
    
    const toastHtml = `
        <div id="${toastId}" class="toast ${bgClass} ${textClass}" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="toast-body d-flex align-items-center">
                <i class="bi bi-${getToastIcon(type)} me-2"></i>
                <span>${message}</span>
                <button type="button" class="btn-close btn-close-${type === 'warning' ? 'dark' : 'white'} ms-auto" data-bs-dismiss="toast"></button>
            </div>
        </div>
    `;
    
    toastContainer.insertAdjacentHTML('beforeend', toastHtml);
    
    const toastElement = document.getElementById(toastId);
    const toast = new bootstrap.Toast(toastElement, { delay: 3000 });
    toast.show();
    
    // Remove toast element after it's hidden
    toastElement.addEventListener('hidden.bs.toast', function() {
        toastElement.remove();
    });
}

// Create toast container if it doesn't exist
function createToastContainer() {
    const container = document.createElement('div');
    container.id = 'toast-container';
    container.className = 'toast-container';
    document.body.appendChild(container);
    return container;
}

// Get icon for toast type
function getToastIcon(type) {
    const icons = {
        'success': 'check-circle-fill',
        'danger': 'exclamation-circle-fill',
        'warning': 'exclamation-triangle-fill',
        'info': 'info-circle-fill'
    };
    return icons[type] || icons['info'];
}

// Utility: Escape HTML to prevent XSS
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}

// Utility: Format date
function formatDate(dateString) {
    if (!dateString) return 'N/A';
    
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);
    
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins} minute${diffMins > 1 ? 's' : ''} ago`;
    if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
    if (diffDays < 7) return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`;
    
    return date.toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric' 
    });
}
