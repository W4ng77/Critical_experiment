import os
import pandas as pd

# Directory containing the log files
log_dir = 'log_files'

# Function to extract results from a log file
def extract_results_from_file(filepath):
    try:
        with open(filepath, 'r') as file:
            lines = file.readlines()

        if len(lines) < 6:
            raise ValueError("Not enough lines in file for extracting results.")

        # Extracting the last 6 lines which contain the results and timestamp
        results = lines[-6:]
        finished_line = results[5]

        if "Finished" not in finished_line:
            raise ValueError("Finished line not in expected format.")

        parts = finished_line.split('Finished')[-1].strip().split('_')
        if len(parts) < 3:
            raise ValueError(f"Filename parts length is less than expected: {parts}")

        dataset = parts[-1]
        layer = parts[-2]
        model = '_'.join(parts[:-2])

        return {
            'Model': model,
            'Layer': layer,
            'Dataset': dataset,
            'Val ROC AUC Mean': results[1].split(': ')[1].strip(),
            'Val ROC AUC Std': results[2].split(': ')[1].strip(),
            'Test ROC AUC Mean': results[3].split(': ')[1].strip(),
            'Test ROC AUC Std': results[4].split(': ')[1].strip()
        }
    except Exception as e:
        print(f"Error processing file {filepath}: {e}")
        return None

# Collecting results
data = []
for filename in os.listdir(log_dir):
    if filename.endswith('.log'):
        # Extracting results from the file
        filepath = os.path.join(log_dir, filename)
        results = extract_results_from_file(filepath)
        if results:
            data.append(results)

# Creating a DataFrame
df = pd.DataFrame(data)

# Sorting the DataFrame
df.sort_values(by=['Model', 'Layer', 'Dataset'], inplace=True)

# Saving the DataFrame to an Excel file
df.to_excel('extracted_results.xlsx', index=False)

print("Data extraction complete. Results saved in 'extracted_results.xlsx'.")
