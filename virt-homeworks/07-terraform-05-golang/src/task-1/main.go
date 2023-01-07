package main

import "fmt"

func main() {
	fmt.Print("Enter the length in meters: ")
	var input float32
	fmt.Scanf("%f", &input)
	fmt.Println(input, "meters is", MtoF(input), "feet")
}

func MtoF(meters float32) float32 {
	return meters / 0.3048
}