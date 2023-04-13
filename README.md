
# Inactivity Monitoring and Shutdown

-------------------------------------------------------
<https://youtu.be/jnQoRZkPoWM>

This repository contains PowerShell scripts to automatically monitor user inactivity on a Windows EC2 instance and prompt the user to shut down the instance when inactivity is detected. The setup is mostly automated through the user data script provided.

## Scripts

-------------------------------------------------------
There are three main PowerShell scripts in this repository:

1. `user_data.ps1`  This script is used as the user data when launching a new EC2 instance. It automates the setup process by installing required software, cloning the repository, and creating a scheduled task to run the monitor_inactivity.ps1 script at startup.

2. `monitor_inactivity.ps1`  This script is run at startup and monitors user inactivity. When a specified period of inactivity is detected, it triggers the shutdown_prompt.ps1 script to prompt the user for shutting down the instance.

3. `shutdown_prompt.ps1`  This script displays a prompt to the user, asking if they want to shut down the instance. If the user does not respond within a specified time, the script will automatically terminate the instance.

## Usage

-------------------------------------------------------

1. Launch a new Windows EC2 instance using the AWS Management Console or AWS CLI.

2. When configuring the instance details, copy the entire contents of the `user_data.ps1` script (provided above) and paste it into the `"User data"` field in the `"Advanced Details"` section.

3. Launch the instance.

4. The instance will automatically run the `user_data.ps1` script during startup. The script will install Git, clone the repository to `C:\Program Files\AWS_min_WIN`, and create a scheduled task to run the `monitor_inactivity.ps1` script at startup.

5. The `monitor_inactivity.ps1` script will run in the background and monitor user inactivity. When a specified period of inactivity is detected, it will trigger the `shutdown_prompt.ps1` script, prompting the user to shut down the instance.

6. If the user does not respond to the prompt within the specified time, the instance will be terminated automatically.
