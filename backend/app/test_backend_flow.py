import requests
import json

BASE_URL = "http://127.0.0.1:8000/api/v1"

def test_flow():
    print("--- Starting Backend Flow Test ---")

    # 1. Register
    reg_data = {
        "username": "testcitizen",
        "email": "test@example.com",
        "password": "password123",
        "role": "citizen"
    }
    print(f"\n1. Registering user: {reg_data['username']}")
    try:
        resp = requests.post(f"{BASE_URL}/auth/register", json=reg_data)
        print(f"Status: {resp.status_code}")
        user = resp.json()
        print(f"Response: {user}")
        citizen_id = user.get("id")
    except Exception as e:
        print(f"Registration failed (might already exist): {e}")
        # Try login instead
        citizen_id = None

    # 2. Login
    login_data = {
        "username": "testcitizen",
        "password": "password123"
    }
    print(f"\n2. Logging in user: {login_data['username']}")
    resp = requests.post(f"{BASE_URL}/auth/login", json=login_data)
    print(f"Status: {resp.status_code}")
    login_resp = resp.json()
    print(f"Response: {login_resp}")
    if not citizen_id:
        citizen_id = login_resp.get("user_id")

    # 3. Create Complaint
    complaint_data = {
        "title": "Large Garbage Pile",
        "description": "There is a huge pile of plastic waste near the park entrance.",
        "location_name": "Central Park East Gate",
        "latitude": 12.9716,
        "longitude": 77.5946,
        "citizen_id": citizen_id,
        "image_url": "http://example.com/image.jpg",
        "audio_url": "http://example.com/audio.mp3"
    }
    print(f"\n3. Creating complaint for citizen_id: {citizen_id}")
    resp = requests.post(f"{BASE_URL}/complaints/", json=complaint_data)
    print(f"Status: {resp.status_code}")
    print(f"Response: {json.dumps(resp.json(), indent=2)}")

    # 4. Get Citizen Dashboard
    print(f"\n4. Fetching dashboard for citizen_id: {citizen_id}")
    resp = requests.get(f"{BASE_URL}/complaints/citizen/{citizen_id}")
    print(f"Status: {resp.status_code}")
    complaints = resp.json()
    print(f"Found {len(complaints)} complaints for this user.")
    if len(complaints) > 0:
        print(f"First complaint status: {complaints[0]['status']}")

if __name__ == "__main__":
    test_flow()
