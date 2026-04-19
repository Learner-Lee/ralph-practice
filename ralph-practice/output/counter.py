import sys
import json
import os

DATA_FILE = os.path.join(os.path.dirname(__file__), "counter_data.json")


def load_data():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE) as f:
            return json.load(f)
    return {"total": 0, "history": []}


def save_data(data):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f)


def main():
    if len(sys.argv) < 2:
        print("Usage: counter.py <add|total|reset|history> [number]")
        sys.exit(1)

    command = sys.argv[1]
    data = load_data()

    if command == "add":
        if len(sys.argv) < 3:
            print("Usage: counter.py add <number>")
            sys.exit(1)
        number = float(sys.argv[2])
        data["total"] += number
        data["history"].append(f"add {number}")
        save_data(data)
        print(f"Added {number}. Total is now {data['total']}")

    elif command == "total":
        print(f"Total: {data['total']}")

    elif command == "reset":
        data["history"].append("reset")
        data["total"] = 0
        save_data(data)
        print("Counter reset to 0")

    elif command == "history":
        if not data["history"]:
            print("No history yet")
        else:
            for i, entry in enumerate(data["history"], 1):
                print(f"{i}. {entry}")

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
