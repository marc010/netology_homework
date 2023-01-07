package main

import "fmt"

func main() {
  x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
  fmt.Println(min_el(x))
}

func min_el(x []int) int {
  min := x[0]
  for _, el := range x {
  	if el < min {
  	  min = el
  	}
  }
  return min
}