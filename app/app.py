"""
Secure 3-Tier Web App - Flask API
A simple REST API with health checks and basic endpoints
"""
from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
import os
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__,
            static_folder='static',
            template_folder='templates')

# Enable CORS for API endpoints
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Configuration
APP_VERSION = os.getenv('APP_VERSION', '1.0.0')
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')

# In-memory storage (for demo purposes)
tasks = [
    {
        "id": 1,
        "title": "Learn DevOps",
        "description": "Study DevOps principles, tools, and best practices",
        "completed": False,
        "created_at": datetime.utcnow().isoformat()
    },
    {
        "id": 2,
        "title": "Build CI/CD Pipeline",
        "description": "Create automated deployment pipeline with GitHub Actions",
        "completed": False,
        "created_at": datetime.utcnow().isoformat()
    }
]

@app.route('/')
def home():
    """Home endpoint - serves the dashboard UI"""
    return render_template('index.html')

@app.route('/api')
def api_info():
    """API information endpoint"""
    return jsonify({
        "message": "Welcome to Secure Web App Pipeline API!",
        "version": APP_VERSION,
        "environment": ENVIRONMENT,
        "timestamp": datetime.utcnow().isoformat(),
        "endpoints": {
            "health": "/health",
            "tasks": "/api/tasks",
            "task_by_id": "/api/tasks/<id>"
        }
    })

@app.route('/health')
def health():
    """Health check endpoint for monitoring"""
    return jsonify({
        "status": "healthy",
        "version": APP_VERSION,
        "timestamp": datetime.utcnow().isoformat()
    }), 200

@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    """Get all tasks"""
    logger.info("Fetching all tasks")
    return jsonify({"tasks": tasks, "count": len(tasks)})

@app.route('/api/tasks', methods=['POST'])
def create_task():
    """Create a new task"""
    data = request.get_json()
    
    if not data or 'title' not in data:
        return jsonify({"error": "Title is required"}), 400
    
    new_task = {
        "id": len(tasks) + 1,
        "title": data['title'],
        "description": data.get('description', ''),
        "completed": data.get('completed', False),
        "created_at": datetime.utcnow().isoformat()
    }
    tasks.append(new_task)
    logger.info(f"Created new task: {new_task['title']}")
    
    return jsonify(new_task), 201

@app.route('/api/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    """Get a specific task"""
    task = next((t for t in tasks if t['id'] == task_id), None)
    
    if not task:
        return jsonify({"error": "Task not found"}), 404
    
    return jsonify({"task": task})

@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    """Update a task"""
    task = next((t for t in tasks if t['id'] == task_id), None)
    
    if not task:
        return jsonify({"error": "Task not found"}), 404
    
    data = request.get_json()
    task['title'] = data.get('title', task['title'])
    task['description'] = data.get('description', task.get('description', ''))
    task['completed'] = data.get('completed', task['completed'])
    
    logger.info(f"Updated task {task_id}")
    return jsonify({"task": task})

@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    """Delete a task"""
    global tasks
    task = next((t for t in tasks if t['id'] == task_id), None)
    
    if not task:
        return jsonify({"error": "Task not found"}), 404
    
    tasks = [t for t in tasks if t['id'] != task_id]
    logger.info(f"Deleted task {task_id}")
    
    return jsonify({"message": "Task deleted successfully"}), 200

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({"error": "Endpoint not found"}), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"Internal error: {error}")
    return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=(ENVIRONMENT == 'development'))
