import requests
import json

BASE_URL = "http://127.0.0.1:8000/api/v1"

def test_auth_flow():
    # 1. Register
    email = "test_user@example.com"
    password = "password123"
    new_password = "newpassword456"

    print(f"--- Testing Auth Flow for {email} ---")

    # Registration
    reg_data = {
        "fullName": "Test User",
        "email": email,
        "password": password,
        "phone": "1234567890",
        "role": "citizen"
    }
    resp = requests.post(f"{BASE_URL}/auth/register", json=reg_data)
    print(f"Register: {resp.status_code} - {resp.json().get('message')}")

    # 2. Login
    login_data = {"email": email, "password": password}
    resp = requests.post(f"{BASE_URL}/auth/login", json=login_data)
    print(f"Login: {resp.status_code} - {resp.json().get('message')}")

    if resp.status_code != 200:
        print("Login failed, stopping test.")
        return

    token = resp.json()['data']['access_token']
    headers = {"Authorization": f"Bearer {token}"}

    # 3. Change Password
    change_data = {
        "currentPassword": password,
        "newPassword": new_password
    }
    resp = requests.put(f"{BASE_URL}/auth/change-password", json=change_data, headers=headers)
    print(f"Change Password: {resp.status_code} - {resp.json().get('message')}")

    # 4. Logout (Login again with new password)
    login_data = {"email": email, "password": new_password}
    resp = requests.post(f"{BASE_URL}/auth/login", json=login_data)
    print(f"Login with New Password: {resp.status_code} - {resp.json().get('message')}")

    # 5. Forgot Password
    forgot_data = {"email": email}
    resp = requests.post(f"{BASE_URL}/auth/forgot-password", json=forgot_data)
    print(f"Forgot Password: {resp.status_code} - {resp.json().get('message')}")
    print("NOTE: Check backend logs for the Reset Token printed in console.")

if __name__ == "__main__":
    try:
        test_auth_flow()
    except Exception as e:
        print(f"Error during test: {e}")
        print("Make sure the FastAPI server is running at http://127.0.0.1:8000")
