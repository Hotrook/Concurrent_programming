package main

import (
	"fmt"
	"sync"
)




func neg(sth bool ) bool {
	if sth { 
		return false 
	} else { 
		return true  
	}
}




func Min(x, y int) int {
    if x < y {
        return x
    }
    return y
}




func Max(x, y int) int {
    if x > y {
        return x
    }
    return y
}




func readSwitches( data * Data, n int ){
	var x int
	for i := 1 ; i <= n ; i++ {
		fmt.Scanf("%d\n", &x );
		data.switches[ i ].id = i;
		data.switches[ i ].isBroken = false
		data.switches[ i ].changeTime = x;
		data.switches[ i ].buffor = make( chan Order, 10 )
		data.switches[ i ].specBuffor = make( chan Order, 2 )
	}
}




func readGoLines( data * Data, m int ){
	var x int
	var y int 
	var l int 
	var z int 

	for i := 1 ; i <= m ; i++ {

		fmt.Scanf( "%d %d %d %d\n", &x, &y, &l, &z );
		data.edges[ x ][ y ] = i;
		data.lines[ i ] = Line{ 
							id: i,
							first: x,
							second: y,
							length: l, 
							maxSpeed: z,
							minStop: 0,
							train: 0,
							isStopLine: false,
							isOccupied: false,
							isBroken: false }

		data.lines[ i ].mutex = sync.Mutex{}

	}
}




func readStopLines( data * Data, k, m int){
	var x int
	var y int 
	var l int 
	var z int 

	for i := m+1 ; i <= m+k ; i++ {

		fmt.Scanf( "%d %d %d %d\n", &x, &y, &l, &z );
		data.edges[ x ][ y ] = i;
		data.lines[ i ] = Line{ 
							id: i,
							first: x,
							second: y,
							length: 0, 
							maxSpeed: 0,
							minStop: l,
							train: 0,
							capacity: z,
							occupied: 0,
							isStopLine: true,
							isOccupied: false,
							isBroken: false }

		data.lines[ i ].mutex = sync.Mutex{}

	}
}




func readTrains( data * Data, p int ){
	var x int
	var y int 
	var z int 	

	for i := 1 ; i <= p ; i++ {
		fmt.Scanf( "%d %d %d\n", &x, &y, &z )
		data.trains[ i ] = Train{
			numberTrain: i, 
			numberPassengers: x,
			isWait: false,
			speed: y,
			currentState: 0,
			isStop: false,
		}
		data.trains[ i ].goChan = make( chan int, 2 )
		data.trains[ i ].stopChan = make( chan int )

		x = z
		list := make( []int, x )
		for j := 0 ; j < x ; j++ {
			fmt.Scanf("%d", &z )
			list[ j ] = z
		}

		data.trains[ i ].addList( list )
	}	
}




func readConstructionCrew( data * Data ){
	var x int
	var y int 

	fmt.Scanf( "%d %d %d\n", &x, &y)
	data.constCrew = ConstructionCrew{
		origin: x,
		repairTime: y }
	data.constCrew.pathChan = make( chan int, 1 )


}




func FrostPrint( d *Data, s string ){
	if d.t == 1 {
		fmt.Println( s )
	}
}
