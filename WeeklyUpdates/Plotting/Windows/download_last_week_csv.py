import requests

def download_last_week_csv(target_url, output_path):
    try:
        print(f"Connecting to ERDDAP...")
        # Send a GET request to the URL
        response = requests.get(target_url, timeout=60)
        
        # Raise an exception if the request was unsuccessful (e.g., 404 or 500 errors)
        response.raise_for_status()
        
        # Write the content to a file in binary mode
        with open(output_path, 'wb') as f:
            f.write(response.content)
            
        print(f"Success! File saved as: {output_path}")

    except requests.exceptions.HTTPError as http_err:
        print(f"HTTP error occurred: {http_err}")
    except Exception as err:
        print(f"An error occurred: {err}")
