# SFTP File Compression Script

## Overview

This Python script automates the process of compressing all files from a specified folder into a zip archive, appending a timestamp to the archive name. After successful compression, the script deletes all files in the specified folder to maintain a clean working environment.

## Environment Variables

To connect to the SFTP server, the script utilizes the following environment variables:

- `SFTP_HOST`: The hostname or IP address of the SFTP server.
- `SFTP_USER`: The username for SFTP authentication.
- `SFTP_PASS`: The password for SFTP authentication.

Please ensure these environment variables are set in your environment before running the script.

## Terraform Configuration

The accompanying Terraform configuration will provision a virtual machine to simulate an SFTP server for testing purposes. This setup allows you to test the script in a controlled environment.

### Steps to Run the Script

1. **Set Environment Variables**: Define the necessary environment variables in your shell or environment configuration.
   ```bash
   export SFTP_HOST='your_sftp_host'
   export SFTP_USER='your_sftp_user'
   export SFTP_PASS='your_sftp_password'
   export ARM_SUBSCRIPTION_ID="CHANGE-TO-SUB-ID"  
```
2.Need to change the folder path inside the script


