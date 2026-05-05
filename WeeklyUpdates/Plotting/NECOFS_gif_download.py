import datetime
import os
import requests

def save_gom_map(save_directory):
    """
    Downloads the GOM map and saves it to a user-defined directory.
    """
    # Configuration
    addr_ddn_api = 'ddn.lowellinstruments.com'
    port_ddn_api = 9000
    deg = 'F'
    
    # Create the directory if it doesn't exist
    if not os.path.exists(save_directory):
        os.makedirs(save_directory)

    # Generate filename based on current date
    now = datetime.datetime.now().strftime('%Y%m%d')
    file_name = f"{now}_{deg}_gom.gif"
    full_path = os.path.join(save_directory, file_name)

    # Skip download if file already exists
    if os.path.exists(full_path):
        return full_path

    # Download request
    url = f'http://{addr_ddn_api}:{port_ddn_api}/gom?t={now}&deg={deg}'
    
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        
        with open(full_path, 'wb') as f:
            f.write(response.content)
            
        return full_path

    except Exception as err:
        print(f"Failed to download map: {err}")
        return None

# --- Quick Start Example ---
if __name__ == "__main__":
    # Change this to your desired save point
    target_folder = "C:/Users/george.maynard/Downloads/" 
    result = save_gom_map(target_folder)
    
    if result:
        print(f"File ready at: {result}")

