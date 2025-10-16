#!/bin/bash

# MkDocs Serve Script
# This script finds and kills any process using port 8000, then builds and serves MkDocs documentation

set -e  # Exit on any error

echo "🚀 Starting MkDocs serve process..."

# Function to kill process on port 8000
kill_port_8000() {
    echo "🔍 Checking for processes using port 8000..."
    
    # Find PIDs using port 8000
    PIDS=$(lsof -ti:8000 2>/dev/null || true)
    
    if [ -z "$PIDS" ]; then
        echo "✅ No processes found using port 8000"
        return 0
    fi
    
    echo "⚠️  Found processes using port 8000: $PIDS"
    
    # Show what processes are running
    echo "📋 Processes details:"
    lsof -i:8000
    
    # Kill the processes
    echo "🔫 Killing processes on port 8000..."
    for PID in $PIDS; do
        echo "   Killing PID: $PID"
        kill -9 "$PID" 2>/dev/null || echo "   Warning: Could not kill PID $PID"
    done
    
    # Wait a moment for processes to die
    sleep 2
    
    # Verify they're gone
    REMAINING_PIDS=$(lsof -ti:8000 2>/dev/null || true)
    if [ -n "$REMAINING_PIDS" ]; then
        echo "❌ Warning: Some processes may still be running on port 8000"
        return 1
    else
        echo "✅ Successfully cleared port 8000"
        return 0
    fi
}

# Function to build and serve MkDocs
serve_mkdocs() {
    echo "📚 Building MkDocs documentation..."
    
    # Build the documentation
    if mkdocs build; then
        echo "✅ Documentation built successfully"
    else
        echo "❌ Failed to build documentation"
        exit 1
    fi
    
    echo "🌐 Starting MkDocs development server..."
    echo "📱 Server will be available at: http://127.0.0.1:8000"
    echo "🔄 Auto-reload is enabled - changes will be reflected automatically"
    echo "⏹️  Press Ctrl+C to stop the server"
    echo ""
    
    # Serve the documentation
    mkdocs serve --dev-addr=127.0.0.1:8000
}

# Main execution
main() {
    echo "🎯 MkDocs Development Server Launcher"
    echo "====================================="
    echo ""
    
    # Check if we're in the right directory
    if [ ! -f "mkdocs.yml" ]; then
        echo "❌ Error: mkdocs.yml not found. Please run this script from your MkDocs project root."
        exit 1
    fi
    
    # Check if virtual environment is activated
    if [ -z "$VIRTUAL_ENV" ]; then
        echo "⚠️  Warning: Virtual environment not detected."
        echo "   It's recommended to activate your virtual environment first:"
        echo "   source .venv/bin/activate"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Exiting..."
            exit 1
        fi
    else
        echo "✅ Virtual environment detected: $VIRTUAL_ENV"
    fi
    
    # Kill any existing processes on port 8000
    if ! kill_port_8000; then
        echo "❌ Failed to clear port 8000. Please check manually and try again."
        exit 1
    fi
    
    echo ""
    
    # Build and serve MkDocs
    serve_mkdocs
}

# Run main function
main "$@"
