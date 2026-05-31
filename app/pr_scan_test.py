import os

def hello():
    name = os.getenv("USER", "dev")
    return f"Hello {name}"

if __name__ == "__main__":
    print(hello())
