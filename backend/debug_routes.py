from app.main import app

def print_routes():
    print("\n========== FASTAPI ROUTES ==========\n")

    for route in app.routes:
        if hasattr(route, "path"):
            print(route.path, route.methods)
        else:
            print(route)

    print("\n====================================\n")


if __name__ == "__main__":
    print_routes()