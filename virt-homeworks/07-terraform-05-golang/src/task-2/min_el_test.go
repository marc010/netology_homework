package main

import "testing"

func TestMin_el(t *testing.T) {
  var v int
  v = min_el([]int{12,23,34,89,45,1,-7,100})
  if v != -7 {
    t.Error("Expected -7 got:", v)
  }
 }