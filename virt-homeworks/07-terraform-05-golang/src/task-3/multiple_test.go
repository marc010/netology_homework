package main

import "testing"

func TestMultiple_of_3(t *testing.T) {
  var v []int
  arr := []int{3,5,9}
  v = multiple_of_3(arr)
  if v[0] != 3 || v[1] != 9 {
    t.Error("Expected 3, 9 got:", v[0], "and", v[1])
  }
  }
