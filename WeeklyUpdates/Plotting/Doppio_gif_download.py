import datetime
import os
import requests

def save_dtm_map(save_directory):
    """
    Downloads the DTM map and saves it to a user-defined directory.
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
    file_name = f"{now}_{deg}_dtm.gif"
    full_path = os.path.join(save_directory, file_name)

    # Skip download if file already exists locally
    if os.path.exists(full_path):
        return full_path

    # Download request using the dtm endpoint
    url = f'http://{addr_ddn_api}:{port_ddn_api}/dtm?t={now}&deg={deg}'
    
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        
        with open(full_path, 'wb') as f:
            f.write(response.content)
            
        return full_path

    except Exception as err:
        print(f"Failed to download DTM map: {err}")
        return None

# --- Example Usage ---
if __name__ == "__main__":
    # Specify your save point here
    target_path = "C:/Users/george.maynard/Downloads/"
    result = save_dtm_map(target_path)
    
    if result:
        print(f"File saved successfully: {result}")
