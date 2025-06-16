#!/bin/bash  

echo "🚀 Starting RubixKube services with nohup..."

# --- Configuration Section ---
MEMORY_ENGINE_PATH="/home/roshanikk/Desktop/memory-engine/memory-engine-main/memory-engine"
OBSERVER_AGENT_PATH="/home/roshanikk/Desktop/Observer-agent/observer-agent-refactors"
LLM_AGENT_PATH="/home/priyank/code/llm-agent"
CONSOLE_PATH="/home/priyank/code/console"

BINARY_FILE_NAME="observer-agent"
LOGS_DIR="$(pwd)/logs"
BINARY_PATH="${OBSERVER_AGENT_PATH}/${BINARY_FILE_NAME}"  # Corrected variable name

# --- Create Logs Directory ---
mkdir -p "$LOGS_DIR"  # Production best practice: store logs in a central dir

# --- Function to Check if a Process is Running ---
is_process_running() {
    local process_name="$1"
    pgrep -f "$process_name" > /dev/null 2>&1
}

# --- Check if observer-agent is already running ---
if is_process_running "main.go"; then
    pid=$(pgrep -f "main.go" | head -1)
    echo "✅ observer-agent: running (PID: $pid)"
else
    echo "❌ observer-agent: not running"
fi

# ---- function to run the application  ---- 
run_observer_agent(){
    local binary_file_name=$1  # ✅ No spaces around '='
    
    echo "🚀 Starting $binary_file_name..."
    
    nohup "./${binary_file_name}" > "$LOGS_DIR/observer-agent.log" 2>&1 &
 
}
 # no hang up command is a command which runs our app even when we shut down terminal 
#    nohup: Keep running even if terminal closes

# ./observer-agent: Run your compiled Go binary

# >: Redirect standard output (stdout) to a file

# 2>&1: Redirect standard error (stderr) to the same file

# &: Run in the background
# }

# --- Function to Build Go App If Not Already Built ---
build_go_app() {
    local app_path="$1"
    local app_name="$2"

    echo "🔧 Building $app_name..."

    cd "$app_path" || {
        echo "❌ Failed to change directory to $app_path"
        return 1
    }

    if [[ -f "$BINARY_PATH" ]]; then
        echo "ℹ️  Build already exists at: $BINARY_PATH"
        echo "running observer agent"
        run_observer_agent "$BINARY_FILE_NAME"

        
    else
        if go build -o "$app_name" .; then
            echo "✅ $app_name built successfully."
        else
            echo "❌ Failed to build $app_name"
            cd - > /dev/null
            return 1
        fi
    fi

    cd - > /dev/null

    return 0
}

# --- Run the Build Function ---
if build_go_app "$OBSERVER_AGENT_PATH" "$BINARY_FILE_NAME"; then
    echo "✅ Build step complete."
else
    echo "❌ Build step failed."
fi
