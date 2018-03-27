package main 

import(
"strconv"
"fmt"
"time"
)

type Worker struct{
	id 				int
	origin			int
	train 			int
	goal 			int
	path 			[]int
	data 			*Data
	taskChannel		chan int
	notify 			chan int
	finish 			chan bool
	inMove			bool
}





func (w * Worker) start(){
	for{
		if !w.inMove {
			select {
			case request := <-w.taskChannel:
				FrostPrint(w.data, " Pracownik " + strconv.Itoa(w.id) + " wezwany na stację " + strconv.Itoa(request) )
				w.goal = request
				w.inMove = true
			default:
				time.Sleep( time.Second )
			}
		} else {
			if w.goal != w.origin{
				w.goToTheGoal()
			}
			w.sentConfirmation()
			<-w.finish
			w.goHome()
			w.inMove = false
		}		
	}
}





func ( w * Worker ) goToTheGoal(){
	w.createPath()
	w.goByThePath()
}





func( w * Worker ) createPath(){
	w.BFS( w.data.lines[ w.origin ].second, w.data.lines[ w.goal ].first, w.origin, w.goal )
}





func( w * Worker ) goByThePath(){
	currentState := 0
	size := len(w.path)
	w.train = -1

	for currentState < size-1 {

		trainID := w.checkTrain( currentState )
		if trainID != w.train {
			w.data.trains[ trainID ].passengers <- Notification{ w.id, w.path[ currentState ] }
			w.train = trainID
			<-w.notify
		}

		w.printGoInMessage( trainID, currentState )
		currentState = currentState+1
		w.data.trains[ trainID ].passengers <- Notification{ w.id, w.path[ currentState ] }
		<-w.notify
		w.printGoOutMessage( trainID, currentState )
	}
}





func ( w * Worker ) checkTrain( state int ) int{
	first := w.path[ state ]
	second := w.path[ state+1 ] 
	firstFound := false
	secondFound := false
	found := false 
	trainID := -1
	it := 1
	line := 0

	for it < len( w.data.trains ) && !found {
		firstFound = false
		secondFound = false

		for i, x := range w.data.trains[ it ].stations{
			if i == len(  w.data.trains[ it ].stations ) - 1{
				line = w.data.edges[ x ][ w.data.trains[ it ].stations[ 0 ] ]
			} else {
				line = w.data.edges[ x ][ w.data.trains[ it ].stations[ i+1 ] ]
			}
			if line == first {
				firstFound = true
			}
			if line == second {
				secondFound = true
			}
		}

		if firstFound && secondFound {
			found = true
			trainID = it
		}
		it++
	}

	return trainID
}






func ( w * Worker ) BFS( start, stop, startTrack, stopTrack int ) bool{
	parents := make( []int, len( w.data.switches ) )
	visited := make( []int, len( w.data.switches ) )
	for i, _ := range parents {
		parents[ i ] = 0;
		visited[ i ] = 0;
	}


	queue := make([]int, 0)
	queue = append( queue, start )
	parents[ start ] = -1;
	visited[ start ] = 1;

	for len( queue ) > 0 {
		temp := queue[ 0 ]
		queue = queue[ 1: ]
		for i, x := range w.data.edges[ temp ]{
			if x != 0 && visited[ i ] == 0{
				parents[ i ] = temp
				queue = append( queue, i )
				visited[ i ] = 1
			}
		}
	}

	temp := make( []int, 0 )
	path := make( []int, 0 )

	if visited[ stop ] == 1 {
		i := stop
		temp = append( temp, stop )
		for parents[ i ] != -1 {
			temp = append( temp, parents[ i ]  )
			i = parents[ i ]
		}

		for i := len( temp ) - 1 ; i >= 0 ; i-- {
			path = append( path, temp[ i ] )
			fmt.Print( temp[ i ] ) 
			fmt.Print(" ")
		}
		fmt.Println()
		w.extractPath( path, startTrack, stopTrack )
		return true
	} else {
		return false
	}
}





func ( w * Worker ) extractPath(path []int, start, stop int ){
	it := 0
	w.path = make([]int, 0 )
	w.path = append( w.path, start )
	for it < len( path )-1 {
		next := w.data.edges[ path[it] ][ path[ it+1 ] ]
		if w.data.lines[ next ].isStopLine {
			w.path = append( w.path, next )
		}
		it = it + 1
	}
	w.path = append( w.path, stop )

	for _, x := range w.path{
		fmt.Print( strconv.Itoa(x) + " " )
	}
	fmt.Println( )
}





func ( w * Worker ) sentConfirmation(){
	w.data.workersManager.confirmationChannel <- w.id
}





func ( w * Worker ) printGoInMessage( trainID, currentState int){
	FrostPrint(w.data, " Pasazer " + strconv.Itoa( w.id ) + " wsiada na stacji " +
		strconv.Itoa( w.path[ currentState ] ) + " do pociagu " + strconv.Itoa( trainID ))
}





func ( w * Worker ) printGoOutMessage( trainID, currentState int ){
	FrostPrint(w.data, " Pasazer " + strconv.Itoa( w.id ) + " wysiada na stacji " +
		strconv.Itoa( w.path[ currentState ] ) + " z pociagu " + strconv.Itoa( trainID ))
}





func ( w * Worker ) goHome(){
	if w.goal != w.origin {
		w.BFS( w.data.lines[ w.goal ].second, w.data.lines[ w.origin ].first, w.goal, w.origin )
		w.goByThePath()
	}
	w.printHomeMessage()
	w.sentConfirmation()
}





func ( w * Worker ) printHomeMessage(){
	FrostPrint( w.data, " Pracownik " + strconv.Itoa( w.id ) + " wrócił do domu. ")
}