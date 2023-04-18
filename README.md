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

```powershell
Start-Job -FilePath .\monitor_inactivity.ps1
```

## Starting a New Instance on AWS
<!-- 
1. **Name Tag**
2. **My AMI**
3. **Key**
4. **Access from Local IP Address**
5. **Spot Request**
6. **IAM Permissions**
7. **User Data** -->

## 1. Name Tag

- **Assign a unique and descriptive name tag to your instance to easily identify it.**
- **The name tag should follow a consistent naming convention for better organization.**
- **To add a name tag, navigate to the 'Tags' tab in the instance creation wizard and click 'Add Tag.' Enter 'Name' as the key and your desired instance name as the value.**

## 2. My AMI

- **Choose an Amazon Machine Image (AMI) that meets your requirements.**
- **The AMI is a template containing the software configuration (operating system, application server, and applications) needed to launch an instance.**
- **AWS provides a variety of AMIs, including Amazon Linux, Ubuntu, Windows, and more. You can also create and use your own custom AMI.**

## 3. Key

- **Create or select an existing key pair for securely accessing your instance.**
- **Key pairs consist of a public and private key that enable secure SSH connections.**
- **To create a new key pair, navigate to the 'Key Pair' section in the instance creation wizard and choose 'Create a new key pair.' Download and save the private key (.pem) file securely.**

## 4. Security Group

- **Configure the security group settings to allow access to your instance from your local IP address.**
- **In the instance creation wizard, navigate to the 'Configure Security Group' section.**
- **Create a new security group or select an existing one, and add a rule to allow traffic from your local IP address.**
- **For SSH access, set the 'Type' to 'SSH', the 'Protocol' to 'TCP', and the 'Port Range' to '22'. Under 'Source,' choose 'My IP' to automatically populate your current IP address.**

![alt text](https://github.com/TortoiseWolfe/AWS_min_WIN/blob/main/docs/Screenshot%202023-04-17%20105922.png?raw=true "1 Name Tag, 2 AMI, 3 Key, 4 Security Group")

### 4.1 Security Group

- **RDP port 3389 is open by default for Windows instances.**
- **You can also add rules to allow specific IP addresses or address ranges to reach your instance.**
- **By default, all inbound traffic is blocked and all outbound traffic is allowed.**

![alt text](https://github.com/TortoiseWolfe/AWS_min_WIN/blob/main/docs/RDP3389%202023-04-17%20160323.png?raw=true "4.1 Security Group")

## 5. Spot Request

- **To save costs, consider using Spot Instances, which allow you to bid on spare Amazon EC2 computing capacity.**
- **In the instance creation wizard, navigate to the 'Configure Instance Details' section and select 'Request Spot Instances.'**
- **Set your maximum price per instance hour, which should be less than the current Spot price for the desired instance type.**

## 6. IAM Permissions

- **Attach an IAM role to the instance to grant permissions for AWS service access.**
- **Create a new IAM role or select an existing one based on your application requirements.**
- **In the instance creation wizard, navigate to the 'Configure Instance Details' section and choose the desired IAM role from the 'IAM role' dropdown.**

<!-- ![alt text](https://github.com/TortoiseWolfe/AWS_min_WIN/blob/main/docs/Screenshot%202023-04-17%20110331.png?raw=true "5 Spot Request  6 IAM Permissions") -->
![alt text](https://github.com/TortoiseWolfe/AWS_min_WIN/blob/main/docs/Screenshot%202023-04-17%20081520.png?raw=true "5 Spot Request  6 IAM Permissions")

## 7. User Data

- **Provide user data scripts or cloud-init directives to configure the instance on launch.**
- **User data can be used for tasks such as installing software, configuring settings, or starting services.**
- **In the instance creation wizard, navigate to the 'Configure Instance Details' section and enter your user data script or cloud-init directives in the 'User data' field.**

![alt text](https://github.com/TortoiseWolfe/AWS_min_WIN/blob/main/docs/Screenshot%202023-04-17%20110735.png?raw=true "7 User Data")

After completing these steps, review your settings and click 'Launch' to start your new instance on AWS.

## 8. Connect to Your Instance

![8 Connect to Your Instancce](https://github.com/TortoiseWolfe/AWS_min_WIN/blob/main/docs/Screenshot%202023-04-17%20115039.png?raw=true "8 Connect to Your Instance")

### 8.1 Download RDP File

- **If you are using a Windows instance, you will need to download the Remote Desktop Protocol (RDP) file.**
- **Navigate to the 'Instances' section on the EC2 Dashboard, select your instance, and click 'Connect.'**
- **In the 'Connect To Your Instance' window, select the 'RDP client' tab and click 'Download Remote Desktop File.' Save the .rdp file to your computer.**

### 8.2 Get Password

- **To connect to a Windows instance, you will need to retrieve the administrator password.**
- **In the 'Connect To Your Instance' window, click 'Get Password.'**

![8.1 Download RDP File 8.2 Get Passord](https://github.com/TortoiseWolfe/AWS_min_WIN/blob/main/docs/Screenshot%202023-04-17%20115259.png?raw=true "8.1 Download RDP File 8.2 Get Passord")

### 8.3 Upload PEM File

- **You will be prompted to upload your private key (.pem) file to decrypt the administrator password.**
- **Click 'Browse' and select the .pem file associated with your instance.**

![8.3 Upload PEM File](https://github.com/TortoiseWolfe/AWS_min_WIN/blob/main/docs/Key%202023-04-17%20115558.png?raw=true "8.3 Upload PEM File")

### 8.4 Decrypt Password

- **After uploading the .pem file, click 'Decrypt Password.' The decrypted password will be displayed on the screen.**
- **Copy the decrypted password and keep it secure.**

![8.4 Decrypt Password](https://github.com/TortoiseWolfe/AWS_min_WIN/blob/main/docs/Decrypt%20PassWord%202023-04-17%20120019.png?raw=true "8.4 Decrypt Password")

### 8.5 Select RDP File

- **On your computer, locate and double-click the .rdp file you downloaded earlier to launch the Remote Desktop Connection client.**

![8.5 Select RDP File](https://github.com/TortoiseWolfe/AWS_min_WIN/blob/main/docs/Connect%20to%20RDP%202023-04-17%20120121.png?raw=true "8.5 Select RDP File")

### 8.6 Paste Password

- **When prompted for the password, paste the decrypted password you obtained in step 8.4.**
- **Click 'OK' to connect to your instance.**

![8.6 Paste Password](https://github.com/TortoiseWolfe/AWS_min_WIN/blob/main/docs/Paste%20PassWord%202023-04-17%20120333.png?raw=true "8.6 Paste Password")

## 9. Post-Connection Instance Configuration

After connecting to your instance, you may need to perform additional configuration to customize it to your needs. Some common tasks include:

### 9.1 Update Operating System

- For both Windows and Linux instances, it is recommended to update the operating system to ensure you have the latest security patches and software updates.
- On Windows instances, use Windows Update to download and install updates.
- On Linux instances, use the package manager for your distribution (e.g., 'yum' for Amazon Linux or 'apt-get' for Ubuntu) to update packages.

### 9.2 Install Required Software

- Install any necessary software or packages for your application or project.
- On Windows instances, you can use the built-in package manager or download and install software manually.
- On Linux instances, use the package manager for your distribution to install packages (e.g., 'yum install' for Amazon Linux or 'apt-get install' for Ubuntu).

### 9.3 Configure Security Settings

- Review and configure security settings for your instance and installed software as needed.
- Ensure that your instance is protected by a firewall and that only necessary ports are open.
- Regularly monitor your instance's security group settings to maintain a secure environment.

### 9.4 Set Up Monitoring and Logging

- Set up monitoring and logging to track your instance's performance, usage, and potential issues.
- AWS provides various monitoring tools, such as Amazon CloudWatch, that can help you monitor your instance's performance and set up alarms based on specific metrics.
- Additionally, you can enable AWS CloudTrail to log, monitor, and retain account activity related to actions across your AWS infrastructure.

### 9.5 Backup and Recovery

- Implement a backup and recovery strategy for your instance to safeguard against data loss or instance failure.
- Regularly create snapshots of your instance's Amazon Elastic Block Store (EBS) volumes to create point-in-time backups that can be used to recover your instance.
- Consider using Amazon S3 or another storage service for additional backup and storage options.

By following these steps, you can successfully launch, connect to, and configure an AWS instance for your specific needs. Remember to continuously monitor, update, and maintain your instance to ensure its optimal performance and security.

```powershell
git  clone https://github.com/TortoiseWolfe/AWS_min_WIN.git
```

```powershell
Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `".\update_PowerShell.ps1`"" -NoNewWindow
```

```powershell
Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `".\update_WinDowz_001.ps1`"" -NoNewWindow
```

```powershell
$PSVersionTable.PSVersion
```

```powershell
pwsh 
```