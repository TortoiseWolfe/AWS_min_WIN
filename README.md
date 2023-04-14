# Inactivity Monitoring and Shutdown

-------------------------------------------------------
<https://youtu.be/jnQoRZkPoWM>

This repository contains PowerShell scripts to automatically monitor user inactivity on a Windows EC2 instance starting at 5 PM and prompt the user to shut down the instance when inactivity is detected. The setup is mostly automated through the user data script provided.

## Scripts

-------------------------------------------------------
There are three main PowerShell scripts in this repository:

1. `user_data.ps1`  This script is used as the user data when launching a new EC2 instance. It automates the setup process by installing required software, cloning the repository, and creating a scheduled task to run the monitor_inactivity.ps1 script at startup.

2. `monitor_inactivity.ps1`  This script is run at startup and monitors user inactivity starting at 5 PM. When a specified period of inactivity is detected, it triggers the shutdown_prompt.ps1 script to prompt the user for shutting down the instance.

3. `shutdown_prompt.ps1`  This script displays a prompt to the user, asking if they want to shut down the instance. If the user does not respond within a specified time, the script will automatically terminate the instance.

## Usage

-------------------------------------------------------

1. Launch a new Windows EC2 instance using the AWS Management Console or AWS CLI.

2. When configuring the instance details, copy the entire contents of the `user_data.ps1` script (provided above) and paste it into the `"User data"` field in the `"Advanced Details"` section.

3. Launch the instance.

4. The instance will automatically run the `user_data.ps1` script during startup. The script will install Git, clone the repository to `C:\Program Files\AWS_min_WIN`, and create a scheduled task to run the `monitor_inactivity.ps1` script at startup.

5. The `monitor_inactivity.ps1` script will run in the background and monitor user inactivity starting at 5 PM. When a specified period of inactivity is detected, it will trigger the `shutdown_prompt.ps1` script, prompting the user to shut down the instance.

6. If the user does not respond to the prompt within the specified time, the instance will be terminated automatically.

## the Instance will need an IAM role with permission in order to delete itself

-------------------------------------------------------

1. Create an IAM Policy:
   - Go to IAM console, click on "Policies", then "Create policy".
   - Paste the JSON policy document to allow termination of instances with the "Name" tag set to `minWIN`.
   - Review the policy, give it a name (e.g., "Terminate_Windows_Instance"), and create the policy.

   ```json
   
   {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:TerminateInstances",
            "Resource": "arn:aws:ec2:*:*:instance/*",
        }
    ]
    }
   ```

   ```json
   
   {
            "Resource": "arn:aws:ec2:REGION:ACCOUNT_ID:instance/INSTANCE_ID"

    }
   ```

2. Create an IAM Role:
   - In the IAM console, click on "Roles", then "Create role".
   - Select "AWS service" and "EC2", then click "Next: Permissions".
   - Search for the "TerminateWindowsInstance" policy, select it, and proceed.
   - (Optional) Add tags, then give the role a name (e.g., "EC2_TerminateR") and create the role.

3. Attach the IAM Role to your EC2 Windows Instance:
   - In the EC2 console, select the Windows instance.
   - Click "Instance Settings" -> "Attach/Replace IAM Role".
   - Select the "EC2TerminateRole" and click "Apply".

4. Tag your EC2 Windows Instance:
   - In the EC2 console, select your Windows instance.
   - Click on the "Tags" tab, then "Add/Edit Tags".
   - Create a tag with the key "Name" and the value `minWIN`, then save.
