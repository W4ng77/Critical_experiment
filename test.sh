#!/bin/bash

# Directory for log files
log_dir="log_files"
mkdir -p $log_dir  # Create the directory if it doesn't exist

# Define a single dataset and model for the test
dataset="roman-empire"
model="ResNet"
num_layers=1

# Define the job name
job_name="${model}_l${num_layers}_${dataset}"
echo "Submitting job: $job_name"

# Define a unique log file for this job
job_log_file="$log_dir/${job_name}.log"
slurm_output="$log_dir/${job_name}_slurm_output_%j.txt"
slurm_error="$log_dir/${job_name}_slurm_error_%j.txt"

# Construct the Python command
command="python train.py --name ${model}_l${num_layers} --dataset ${dataset} --model ${model} --num_layers ${num_layers} --device cuda:0"

# Submit the job
sbatch --job-name=$job_name \
       --output=$slurm_output \
       --error=$slurm_error \
       --time=03:00:00 \
       --gres=gpu:1 \
       --mem=16G \
       --cpus-per-task=2 \
       --wrap="echo \"$(date): Starting $job_name\" >> $job_log_file; $command >> $job_log_file 2>&1; echo \"$(date): Finished $job_name\" >> $job_log_file"
