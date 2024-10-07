import os
import zipfile
import io
import paramiko
from datetime import datetime

# acts like a os.walk for an SFTP connection.
def sftp_walk(sftp, remote_path):
    print(f"Walking through: {remote_path}") # Debug 
    results = []
    for entry in sftp.listdir_attr(remote_path):
        entry_path = os.path.join(remote_path, entry.filename)
        results.append(entry_path)
        print(f"Found: {entry_path}")  # Debugging 
    return results

def create_zip_and_cleanup(sftp, file_paths):
    """
    Creates a zip file in memory from the specified file paths and deletes them.
    """
    zip_buffer = io.BytesIO()  # Create an in-memory bytes buffer
    
    with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zf:
        for file_path in file_paths:
            # Download file into memory
            with io.BytesIO() as file_buffer:
                sftp.getfo(file_path, file_buffer) # Copy from sftp path into a file in this scenario into bytes 
                file_buffer.seek(0)  # Move to the start of the object
                archive_name = os.path.relpath(file_path, start=os.path.dirname(file_path)) # Add file to zip, by taking 
                zf.writestr(archive_name, file_buffer.read())

            # Remove the old file from the SFTP server
            sftp.remove(file_path)
            print(f"Removed: {file_path}")  # Debugging output
    
    zip_buffer.seek(0)  # Move to the start of the BytesIO object for reading
    return zip_buffer


def time():
    now = datetime.now()
    current_year = now.year
    current_month = now.month
    current_day = now.day
    current_hour = now.hour       
    current_minute = now.minute  

    return f'{current_hour}:{current_minute}_{current_year}_{current_month}_{current_day}'

def upload_zip(sftp, zip):
    try:
        with sftp.open(f"data-{time()}.zip", 'wb') as f:
            f.write(zip)
        return f"Uploaded zip into sftp"
    except Exception as e:
        return f"Failed to upload file: {e}"       

def main():
    remote_path = "/home/sftpuser/data-lake"  # change Folder path /home/sftpuser/data-lake
    # SFTP credentials 
    SFTP_HOST = os.getenv('SFTP_HOST')
    SFTP_USER = os.getenv('SFTP_USER')
    SFTP_PASS = os.getenv('SFTP_PASS')

    try:
        transport = paramiko.Transport((SFTP_HOST, 22))
        transport.connect(username=SFTP_USER, password=SFTP_PASS)
        sftp_client = paramiko.SFTPClient.from_transport(transport)
        file_paths = sftp_walk(sftp_client, remote_path)  # Get all file paths
        zip_file = create_zip_and_cleanup(sftp_client, file_paths)  # Create zip and cleanup old files
        upload_zip(sftp_client, zip_file.read()) # save the zip into sftp home directory 
    
        # Save the zip into local file 
        # with open('output.zip', 'wb') as f:
        #     f.write(zip_file.read())
        
        print("Created zip file and removed original files.")
    
    except Exception as e:
        print(f"An error occurred: {e}")
    
    finally:
        transport.close()

if __name__ == "__main__":
    main()
