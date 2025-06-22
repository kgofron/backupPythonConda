# Conda Environment Backup Script

This repository contains a robust bash script for backing up conda environments to YAML files.

## Files

- `backup_envs.sh` - Main backup script
- `test_backup.sh` - Test script to verify backup functionality
- `README.md` - This documentation

## Features

The improved backup script includes:

- ✅ **Proper conda initialization** using `conda shell.bash hook`
- ✅ **Timestamped backup directories** to avoid overwrites
- ✅ **Error handling** with colored output
- ✅ **Safe environment parsing** that handles conda's output format correctly
- ✅ **Base environment protection** (skips base to avoid issues)
- ✅ **Backup summary** with restoration instructions
- ✅ **Cross-platform compatibility** (works with Anaconda, Miniconda, etc.)

## Usage

### Basic Usage

```bash
./backup_envs.sh
```

This will:
1. Create a timestamped backup directory (e.g., `conda_envs_20241201_143022`)
2. Export all conda environments to YAML files
3. Create a summary file with restoration instructions

### Testing the Script

```bash
./test_backup.sh
```

This will:
1. Create a test conda environment
2. Run the backup script
3. Verify the backup was created correctly
4. Clean up the test environment

## Output

The script creates a directory structure like this:

```
conda_envs_20241201_143022/
├── backup_summary.txt
├── conda_envs_list.txt
├── my_env1_env.yml
├── my_env2_env.yml
└── ...
```

## Restoring Environments

To restore an environment from backup:

```bash
conda env create -f environment_name_env.yml
```

## Issues with the Original Script

The original script had several problems:

1. **Hardcoded paths**: Assumed Anaconda was in `~/anaconda3/`
2. **Incorrect conda activation**: Used `source ~/anaconda3/bin/activate` instead of proper initialization
3. **Poor file parsing**: The logic for reading `conda env list` output was flawed
4. **No error handling**: Would fail silently on errors
5. **No timestamping**: Could overwrite previous backups
6. **Base environment issues**: Could cause problems when trying to export the base environment

## Requirements

- Bash shell
- Conda (Anaconda, Miniconda, or any conda distribution)
- Write permissions in the current directory

## Troubleshooting

### "conda command not found"
Make sure conda is installed and in your PATH. You may need to initialize conda first:
```bash
conda init bash
```

### Permission denied
Make the script executable:
```bash
chmod +x backup_envs.sh
```

### No environments found
This is normal if you don't have any conda environments created yet.

## License

This script is provided as-is for educational and practical use. 