package main

import "fmt"

func main() {
	x := []int{}

	for i := 1; i < 101; i++ {
		x = append(x, i)
	}
	fmt.Println(multiple_of_3(x))
}

func multiple_of_3(arr []int) []int {
	mult_arr := []int{}
	for i := range arr {
		if arr[i] % 3 == 0 {
			mult_arr = append(mult_arr, arr[i])
		}
	}
	return mult_arr
}