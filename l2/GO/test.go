package main

import "fmt"

func main() {
        var a, b [4]int
        a[2] = 42
        b = a
        fmt.Println(a, b)

        // 2D array
        var c, d [3][5]int
        c[1][2] = 314
        d = c
        fmt.Println(c)
        fmt.Println(d)

        d[ 0 ][ 0 ] = 12213
        fmt.Println()
            fmt.Println(c)
        fmt.Println(d)

        c[ 2 ][ 2 ] = 53435454

        fmt.Println()
        fmt.Println(c)
        fmt.Println(d)
}