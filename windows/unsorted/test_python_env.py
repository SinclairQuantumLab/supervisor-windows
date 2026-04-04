import sys

print(f"This python is at {sys.executable}")

print("Let's see if this python can import pyvisa...")
try:
    import pyvisa
    print("pyvisa imported successfully!")
except ImportError:
    print("pyvisa import failed.")








