import sys
import time

print("Hello, World!")
print("Hello, World!", file=sys.stderr)
print("This is test_python_print.py")
print("This is test_python_print.py", file=sys.stderr)
print()

print("Counting from 0 in every second...") 
i = 0   
while True:
    print(i)
    i += 1
    time.sleep(1)
    








