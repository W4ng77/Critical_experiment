#!/bin/bash

# Directory for log files
log_dir="log_files"
mkdir -p $log_dir  # Create the directory if it doesn't exist

# Define datasets and models
datasets=("roman-empire" "amazon-ratings" "minesweeper" "tolokers" "questions")
models=("ResNet" "ResNet_SGC" "ResNet_adj" "GCN" "SAGE" "GAT" "GAT_sep" "GT" "GT_sep")

# Loop through datasets and models
for dataset in "${datasets[@]}"; do
    for model in "${models[@]}"; do
        for i in {1..5}; do
            job_name="${model}_l${i}_${dataset}"
            echo "Submitting job: $job_name"

            # Define a unique log file for each job
            job_log_file="$log_dir/${job_name}.log"
            slurm_output="$log_dir/${job_name}_slurm_output_%j.txt"
            slurm_error="$log_dir/${job_name}_slurm_error_%j.txt"

            # Construct the Python command
            command="python train.py --name ${model}_l${i} --dataset ${dataset} --model ${model} --num_layers ${i} --device cuda:0"
            [[ "$model" == "ResNet_SGC" ]] && command="python train.py --name ${model}_l${i} --dataset ${dataset} --model ResNet --num_layers ${i} --use_sgc_features --device cuda:0"
            [[ "$model" == "ResNet_adj" ]] && command="python train.py --name ${model}_l${i} --dataset ${dataset} --model ResNet --num_layers ${i} --use_adjacency_features --device cuda:0"

            # Submit the job
            sbatch --job-name=$job_name \
                   --output=$slurm_output \
                   --error=$slurm_error \
                   --time=03:00:00 \
                   --gres=gpu:1 \
                   --mem=16G \
                   --cpus-per-task=2\
                   --wrap="echo \"$(date): Starting $job_name\" >> $job_log_file; $command >> $job_log_file 2>&1; echo \"$(date): Finished $job_name\" >> $job_log_file"
        done
    done
done
