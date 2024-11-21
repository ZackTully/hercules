#!/bin/bash

# Determine the base path for Conda initialization
if [ -f "/home/$USER/anaconda3/etc/profile.d/conda.sh" ]; then
    # Common path for Anaconda on Linux
    CONDA_PATH="/home/$USER/anaconda3/etc/profile.d/conda.sh"
elif [ -f "/Users/$USER/anaconda3/etc/profile.d/conda.sh" ]; then
    # Common path for Anaconda on macOS
    CONDA_PATH="/Users/$USER/anaconda3/etc/profile.d/conda.sh"
elif [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
    # Alternative system-wide installation path
    CONDA_PATH="/opt/anaconda3/etc/profile.d/conda.sh"
elif [ -f "opt/miniconda3/etc/profile.d/conda.sh" ]; then
    # Alternative system-wide installation path
    CONDA_PATH="/opt/miniconda3/etc/profile.d/conda.sh"
elif command -v conda &> /dev/null; then
    # If conda is in PATH, use the which command to find conda location
    CONDA_PATH=$(dirname "$(which conda)")/../etc/profile.d/conda.sh
else
    echo "Conda installation not found. Please ensure Conda is installed and in your PATH."
    exit 1
fi

# Source the Conda initialization script
source "$CONDA_PATH"
conda activate hercules

# Clean up existing outputs
if [ -d outputs ]; then rm -r outputs; fi
mkdir -p outputs

# Set the helics port to use: 
#make sure you use the same port number in the amr_input.inp and hercules_input_000.yaml files. 
export HELICS_PORT=32000

# Wait for the open-loop control simulation to finish and then run the closed-loop simulation
helics_broker -t zmq  -f 2 --loglevel="debug" --local_port=$HELICS_PORT & 
python3 hercules_runscript_CLcontrol.py hercules_input_000.yaml >> outputs/hercules.log 2>&1 &
python3 floris_runscript.py inputs/amr_input.inp floris_standin_data.csv >> outputs/floris.log 2>&1

# Clean up helics output if there
# Search for a file that begins with the current year
# And ends with csv
# If the file exists, move to outputs folder
current_year=$(date +"%Y")
for file in ${current_year}*.csv; do
    if [ -f "$file" ]; then
        mv "$file" outputs/
    fi
done

# If everything is successful
echo "Finished running hercules"
exit 0