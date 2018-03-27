package main

import "sync"



type Data struct{ 
	trains 					[]Train
	lines 					[]Line
	switches 				[]Switch
	constCrew 				ConstructionCrew
	edges					[][]int
	t 						int
	mult					int
	breakdownProbability  	float32
	isBreakdownPossible 	bool
	constCrewChan			chan Pair
	readyTrains				chan int
	breakdownMutex  		sync.Mutex
	readyChan				chan int

}


func initialize(data * Data, t, p, k, m, n int ){
	data.t = t
	data.lines = make( []Line, m+k+1 )
	data.switches = make( []Switch, n+1 )
	data.edges = make( [][]int, n+1 )
	data.trains = make( []Train, p + 1 )
	data.breakdownMutex = sync.Mutex{}
	data.constCrewChan = make( chan Pair, 1 )
	data.readyTrains = make( chan int, 10 )
	data.breakdownProbability = 0.01
	data.isBreakdownPossible = true;

	for i := 0 ; i <= n ; i++ {
		data.edges[ i ] = make( []int, n + 1 )
	}

}