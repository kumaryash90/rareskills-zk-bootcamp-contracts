from ecpy.curves import Curve
import sys

def main():
    # Initialize the curve
    cv = Curve.get_curve('secp256k1')
    G = cv.generator

    # take input number as arg
    num = int(sys.argv[1])

    # multiply the number by generator point
    point = num * G

    # print the x and y coordinates
    x, y = point.x, point.y
    print(f"{x},{y}")

if __name__ == "__main__":
    main()
