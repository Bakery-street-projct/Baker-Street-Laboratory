#!/bin/bash

# Baker Street Laboratory - Run Script
# This script launches the research pipeline

set -e  # Exit on any error

echo "🔬 Baker Street Laboratory - Research Pipeline"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if virtual environment exists
check_venv() {
    if [ ! -d ".venv" ]; then
        print_error "Virtual environment not found. Please run ./install.sh first."
        exit 1
    fi
}

# Activate virtual environment
activate_venv() {
    print_status "Activating virtual environment..."
    source .venv/bin/activate
    print_success "Virtual environment activated"
}

# Check environment configuration
check_env() {
    if [ ! -f ".env" ]; then
        print_error ".env file not found. Please copy .env.example to .env and configure it."
        exit 1
    fi
    
    # Check for required API keys
    source .env
    
    if [ -z "$OPENAI_API_KEY" ] && [ -z "$ANTHROPIC_API_KEY" ]; then
        print_warning "No AI API keys found in .env file. Some features may not work."
    fi
}

# Display usage information
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo
    echo "Commands:"
    echo "  research [QUERY]    - Start a research session with optional query"
    echo "  interactive         - Start interactive research mode"
    echo "  pipeline [CONFIG]   - Run a specific pipeline configuration"
    echo "  test               - Run the test suite"
    echo "  jupyter            - Start Jupyter notebook server"
    echo "  status             - Show system status"
    echo "  help               - Show this help message"
    echo
    echo "Examples:"
    echo "  $0 research \"machine learning trends 2024\""
    echo "  $0 interactive"
    echo "  $0 pipeline config/custom_pipeline.yaml"
    echo "  $0 test"
    echo
}

# Start research session
start_research() {
    local query="$1"
    print_status "Starting research session..."
    
    if [ -n "$query" ]; then
        print_status "Research query: $query"
        python3 implementation/src/main.py --mode research --query "$query"
    else
        python3 implementation/src/main.py --mode research
    fi
}

# Start interactive mode
start_interactive() {
    print_status "Starting interactive research mode..."
    python3 implementation/src/main.py --mode interactive
}

# Run specific pipeline
run_pipeline() {
    local config_file="$1"
    
    if [ -z "$config_file" ]; then
        config_file="config/agents.yaml"
    fi
    
    if [ ! -f "$config_file" ]; then
        print_error "Configuration file not found: $config_file"
        exit 1
    fi
    
    print_status "Running pipeline with config: $config_file"
    python3 implementation/src/main.py --mode pipeline --config "$config_file"
}

# Run tests
run_tests() {
    print_status "Running test suite..."
    
    # Check if pytest is available
    if ! python3 -c "import pytest" 2>/dev/null; then
        print_error "pytest not found. Please run ./install.sh to install dependencies."
        exit 1
    fi
    
    python3 -m pytest implementation/tests/ -v
}

# Start Jupyter notebook
start_jupyter() {
    print_status "Starting Jupyter notebook server..."
    
    # Check if jupyter is available
    if ! python3 -c "import jupyter" 2>/dev/null; then
        print_error "Jupyter not found. Please run ./install.sh to install dependencies."
        exit 1
    fi
    
    jupyter notebook --notebook-dir=research/
}

# Show system status
show_status() {
    print_status "Baker Street Laboratory System Status"
    echo "======================================"
    
    # Python version
    echo "Python: $(python3 --version)"
    
    # Virtual environment
    if [ -d ".venv" ]; then
        echo "Virtual Environment: ✅ Active"
    else
        echo "Virtual Environment: ❌ Not found"
    fi
    
    # Environment file
    if [ -f ".env" ]; then
        echo "Environment Config: ✅ Found"
    else
        echo "Environment Config: ❌ Not found"
    fi
    
    # Database status
    if [ -f "data/metadata.db" ]; then
        echo "Metadata Database: ✅ Initialized"
    else
        echo "Metadata Database: ⚠️  Not initialized"
    fi
    
    # Vector store
    if [ -d "data/vector_store" ]; then
        echo "Vector Store: ✅ Directory exists"
    else
        echo "Vector Store: ❌ Directory not found"
    fi
    
    echo
    print_success "Status check complete"
}

# Main function
main() {
    local command="$1"
    shift || true
    
    # Check prerequisites
    check_venv
    activate_venv
    check_env
    
    case "$command" in
        "research")
            start_research "$*"
            ;;
        "interactive")
            start_interactive
            ;;
        "pipeline")
            run_pipeline "$1"
            ;;
        "test")
            run_tests
            ;;
        "jupyter")
            start_jupyter
            ;;
        "status")
            show_status
            ;;
        "help"|"--help"|"-h")
            show_usage
            ;;
        "")
            print_warning "No command specified. Starting interactive mode..."
            start_interactive
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
