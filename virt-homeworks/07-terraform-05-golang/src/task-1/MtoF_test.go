package main

import "testing"

func TestMtoF(t *testing.T) {
  var v float32
  v = MtoF(1)
  if v != 3.28084 {
  	t.Error("Expected 3.28084 got:", v)
  }
 }
