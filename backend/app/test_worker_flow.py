import requests
import os

BASE_URL = "http://127.0.0.1:8000/api/v1"

def show_response(step, resp):
    print(f"\n===== {step} =====")
    print("Status Code:", resp.status_code)
    try:
        print("Response:", resp.json())
    except Exception:
        print("Response Text:", resp.text)

def test_worker_flow():
    # 1. Register Worker
    email = "worker_test@swachhai.gov.in"
    password = "password123"

    print(f"--- Testing Worker Flow for {email} ---")

    reg_data = {
        "fullName": "Test Worker",
        "email": email,
        "password": password,
        "phone": "9876543210",
        "role": "worker",
        "area": "Anna Nagar"
    }

    resp = requests.post(f"{BASE_URL}/auth/register", json=reg_data)
    show_response("Worker Register", resp)

    # 2. Worker Login
    login_data = {"email": email, "password": password}
    resp = requests.post(f"{BASE_URL}/auth/login", json=login_data)
    show_response("Worker Login", resp)

    login_json = resp.json()

    token = login_json["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    worker_id = login_json["data"]["user"]["id"]
    print("Worker ID:", worker_id)

    # 3. Register Citizen
    cit_email = "citizen_test@example.com"

    citizen_reg = {
        "fullName": "Test Citizen",
        "email": cit_email,
        "password": password,
        "phone": "9999999999",
        "role": "citizen",
        "area": "Anna Nagar"
    }

    resp = requests.post(f"{BASE_URL}/auth/register", json=citizen_reg)
    show_response("Citizen Register", resp)

    # 4. Citizen Login
    cit_login = requests.post(
        f"{BASE_URL}/auth/login",
        json={
            "email": cit_email,
            "password": password
        }
    )

    show_response("Citizen Login", cit_login)

    cit_json = cit_login.json()

    cit_token = cit_json["data"]["access_token"]
    cit_headers = {"Authorization": f"Bearer {cit_token}"}

    # 5. Create Complaint
    complaint_data = {
        "title": "Waste accumulation",
        "description": "Large pile of waste at the corner",
        "area": "Anna Nagar",
        "priority": "High",
        "wasteType": "Organic"
    }

    comp_resp = requests.post(
        f"{BASE_URL}/complaints/create",
        json=complaint_data,
        headers=cit_headers
    )

    show_response("Complaint Creation", comp_resp)

    complaint_json = comp_resp.json()

    complaint_id = complaint_json["data"]["id"]

    print("Complaint ID:", complaint_id)

    # 6. Accept Task
    acc_resp = requests.put(
        f"{BASE_URL}/complaints/accept/{complaint_id}",
        headers=headers
    )

    show_response("Accept Task", acc_resp)

    # 7. Start Task
    start_resp = requests.put(
        f"{BASE_URL}/complaints/start/{complaint_id}",
        headers=headers
    )

    show_response("Start Task", start_resp)

    # 8. Complete Task
    with open("test_image.jpg", "wb") as f:
        f.write(b"dummy image data")

    with open("test_image.jpg", "rb") as f:
        files = {
            "file": ("test_image.jpg", f, "image/jpeg")
        }

        complete_resp = requests.post(
            f"{BASE_URL}/complaints/complete/{complaint_id}",
            headers=headers,
            files=files
        )

    show_response("Complete Task", complete_resp)

    os.remove("test_image.jpg")

if __name__ == "__main__":
    try:
        test_worker_flow()
    except Exception as e:
        print("\nERROR:", e)