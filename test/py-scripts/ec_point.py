from py_ecc.bn128 import G1, multiply
import sys

def main():
    G = G1

    # take input number as arg
    num = int(sys.argv[1])

    # multiply the number by generator point
    point = multiply(G, num)

    # print the x and y coordinates
    x, y = point[0], point[1]
    print(f"{x},{y}")

if __name__ == "__main__":
    main()
