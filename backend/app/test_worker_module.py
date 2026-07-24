# Manual Verification Script for Worker Module
# To run this:
# 1. Start the server: set PYTHONPATH=. && uvicorn app.main:app
# 2. Run this script: python app/test_worker_module.py
# Note: You must first ensure a worker and a complaint assigned to them exist in the database.

import requests
import os

BASE_URL = "http://127.0.0.1:8000/api/v1"

def run_test():
    print("--- Worker Module Verification ---")

    # Placeholder for credentials
    worker_id = input("Enter worker_id to test (e.g. W001): ")
    password = input("Enter password: ")

    # 1. Login
    print(f"\n1. Testing Login for {worker_id}...")
    try:
        resp = requests.post(f"{BASE_URL}/workers/login", json={"worker_id": worker_id, "password": password})
        if resp.status_code != 200:
            print(f"FAILED: {resp.text}")
            return

        token = resp.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        print("SUCCESS: Logged in.")

        # 2. Profile
        print("\n2. Testing /workers/me...")
        resp = requests.get(f"{BASE_URL}/workers/me", headers=headers)
        print(f"RESULT: {resp.json()}")

        # 3. Assigned Tasks
        print("\n3. Testing /workers/assigned...")
        resp = requests.get(f"{BASE_URL}/workers/assigned", headers=headers)
        tasks = resp.json().get("data", [])
        print(f"RESULT: Found {len(tasks)} tasks.")

        if len(tasks) > 0:
            complaint_id = tasks[0]["id"]
            print(f"\nTesting flow for Complaint ID: {complaint_id}")

            # 4. Start Task
            print("\n4. Testing /start...")
            resp = requests.put(f"{BASE_URL}/workers/complaints/{complaint_id}/start", headers=headers)
            print(f"RESULT: {resp.json().get('message')}")

            # 5. After Image
            print("\n5. Testing /after-image upload...")
            with open("test_after.jpg", "wb") as f: f.write(b"dummy image data")
            with open("test_after.jpg", "rb") as f:
                files = {"file": ("test_after.jpg", f, "image/jpeg")}
                resp = requests.post(f"{BASE_URL}/workers/complaints/{complaint_id}/after-image", headers=headers, files=files)
            print(f"RESULT: {resp.json().get('message')}")
            os.remove("test_after.jpg")

            # 6. Complete Task
            print("\n6. Testing /complete...")
            resp = requests.put(f"{BASE_URL}/workers/complaints/{complaint_id}/complete", headers=headers)
            print(f"RESULT: {resp.json().get('message')}")

    except Exception as e:
        print(f"ERROR: {e}")

if __name__ == "__main__":
    run_test()
