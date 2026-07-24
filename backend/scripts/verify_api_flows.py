import requests
import os
import sys

BASE_URL = "http://127.0.0.1:8000/api/v1"

def test_flow():
    print("--- Starting End-to-End API Flow Verification ---")

    # 1. Citizen Login
    print("\n[Citizen] Logging in...")
    resp = requests.post(f"{BASE_URL}/auth/login", json={"email": "citizen@test.com", "password": "citizen123"})
    if resp.status_code != 200:
        print(f"FAILED: {resp.text}")
        return
    citizen_token = resp.json()["data"]["access_token"]
    citizen_headers = {"Authorization": f"Bearer {citizen_token}"}
    print("SUCCESS: Citizen logged in.")

    # 2. Citizen Create Complaint
    print("\n[Citizen] Creating a complaint...")
    complaint_data = {
        "title": "Overflowing bin",
        "description": "The bin at Main St is overflowing",
        "area": "Main St",
        "priority": "High"
    }
    resp = requests.post(f"{BASE_URL}/complaints/create", json=complaint_data, headers=citizen_headers)
    if resp.status_code != 200:
        print(f"FAILED: {resp.text}")
        return
    complaint_id = resp.json()["data"]["id"]
    print(f"SUCCESS: Complaint created (ID: {complaint_id}).")

    # 3. Admin Login
    print("\n[Admin] Logging in...")
    resp = requests.post(f"{BASE_URL}/auth/login", json={"email": "admin@test.com", "password": "admin123"})
    if resp.status_code != 200:
        print(f"FAILED: {resp.text}")
        return
    admin_token = resp.json()["data"]["access_token"]
    admin_headers = {"Authorization": f"Bearer {admin_token}"}
    print("SUCCESS: Admin logged in.")

    # 4. Admin Fetch Workers (to get a worker ID)
    print("\n[Admin] Fetching workers...")
    resp = requests.get(f"{BASE_URL}/admin/workers", headers=admin_headers)
    workers = resp.json()["data"]
    worker_db_id = workers[0]["id"]
    print(f"SUCCESS: Found worker (DB ID: {worker_db_id}).")

    # 5. Admin Assign Worker
    print(f"\n[Admin] Assigning worker {worker_db_id} to complaint {complaint_id}...")
    resp = requests.post(f"{BASE_URL}/admin/assign-worker", json={"complaintId": complaint_id, "workerId": worker_db_id}, headers=admin_headers)
    if resp.status_code != 200:
        print(f"FAILED: {resp.text}")
        return
    print("SUCCESS: Worker assigned.")

    # 6. Worker Login
    print("\n[Worker] Logging in...")
    resp = requests.post(f"{BASE_URL}/workers/login", json={"worker_id": "W001", "password": "password123"})
    if resp.status_code != 200:
        print(f"FAILED: {resp.text}")
        return
    worker_token = resp.json()["data"]["access_token"]
    worker_headers = {"Authorization": f"Bearer {worker_token}"}
    print("SUCCESS: Worker logged in.")

    # 7. Worker Fetch Assigned
    print("\n[Worker] Fetching assigned tasks...")
    resp = requests.get(f"{BASE_URL}/workers/assigned", headers=worker_headers)
    assigned_tasks = resp.json()["data"]
    if not any(t["id"] == complaint_id for t in assigned_tasks):
        print(f"FAILED: Complaint {complaint_id} not in assigned list.")
        return
    print("SUCCESS: Task confirmed in assigned list.")

    # 8. Worker Start Task
    print(f"\n[Worker] Starting task {complaint_id}...")
    resp = requests.put(f"{BASE_URL}/workers/complaints/{complaint_id}/start", headers=worker_headers)
    if resp.status_code != 200:
        print(f"FAILED: {resp.text}")
        return
    print("SUCCESS: Task started.")

    # 9. Worker Upload After Image
    print("\n[Worker] Uploading after-image...")
    with open("test_after_cleaning.jpg", "wb") as f: f.write(b"dummy image content")
    with open("test_after_cleaning.jpg", "rb") as f:
        files = {"file": ("test_after_cleaning.jpg", f, "image/jpeg")}
        resp = requests.post(f"{BASE_URL}/workers/complaints/{complaint_id}/after-image", headers=worker_headers, files=files)
    if resp.status_code != 200:
        print(f"FAILED: {resp.text}")
        return
    print("SUCCESS: After-image uploaded.")
    os.remove("test_after_cleaning.jpg")

    # 10. Worker Complete Task
    print(f"\n[Worker] Completing task {complaint_id}...")
    resp = requests.put(f"{BASE_URL}/workers/complaints/{complaint_id}/complete", headers=worker_headers)
    if resp.status_code != 200:
        print(f"FAILED: {resp.text}")
        return
    print("SUCCESS: Task completed.")

    print("\n--- End-to-End Flow Verification COMPLETED SUCCESSFULLY ---")

if __name__ == "__main__":
    run_test_server = len(sys.argv) > 1 and sys.argv[1] == "--serve"
    if run_test_server:
        print("Please start the server in another terminal first.")
    else:
        test_flow()
