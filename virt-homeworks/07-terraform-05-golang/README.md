# Домашнее задание к занятию "7.5. Основы golang"

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:
    ```
    package main
    
    import "fmt"
    
    func main() {
        fmt.Print("Enter a number: ")
        var input float64
        fmt.Scanf("%f", &input)
    
        output := input * 2
    
        fmt.Println(output)    
    }
    ```

[Ответ](./src/task-1/main.go)
```go
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
```

2. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
    ```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    ```
[Ответ](./src/task-2/main.go)
```go
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
```   

3. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

[Ответ](./src/task-3/main.go)
```go
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
```   

## Задача 4. Протестировать код (не обязательно).

Создайте тесты для функций из предыдущего задания. 

Перед запуском `go test` необходимо выполнить инициализацию модулей:
```bash
$ go mod init main.go
```

1. [Тест](./src/task-1/MtoF_test.go) для программы по переводу метров в футы:

```go 
package main

import "testing"

func TestMtoF(t *testing.T) {
  var v float32
  v = MtoF(1)
  if v != 3.28084 {
  	t.Error("Expected 3.28084 got:", v)
  }
 }
```

2. [Тест](./src/task-2/min_el_test.go) для программы по поиску миинимального значения:

```go 
package main

import "testing"

func TestMin_el(t *testing.T) {
  var v int
  v = min_el([]int{12,23,34,89,45,1,-7,100})
  if v != -7 {
    t.Error("Expected -7 got:", v)
  }
 }
```

3. [Тест](./src/task-3/multiple_test.go) для программы по поиску чисел кратных 3:

```go 
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
```
