package main

import (
	"fmt"
	"time"
	"strconv"
	)




type ConstructionCrew struct{
	id					int
	typeOfBroken 		int
	origin				int
	repairTime 			int
	startSwitch			int
	pathChan 			chan int
	graph				[][]int
	path				[]int
}




func ( cc * ConstructionCrew ) start( data * Data ){
	for{
		select{
		case breakdown := <-data.constCrewChan:
			fmt.Println("NASTĄPIŁA AWARIA! " + strconv.Itoa( breakdown.id ) + " " + strconv.Itoa( breakdown.typeOfBroken))
			cc.typeOfBroken = breakdown.typeOfBroken
			cc.id = breakdown.id
			cc.sendBreak(data, breakdown);
			cc.sendStopQueries(data, &breakdown)
			cc.waitForTrains(data)
			cc.createGraph(data)
			cc.createPath( data, cc.origin, -1 )
			// cc.showPath(data)
			cc.blockAllSwitchesOnThePath( data )
			cc.stats(data)
			cc.restoreTraffic( data )
			cc.goByPath( data )
			cc.repair(data)
			cc.unblockAllSwitchesOnThePath( data )
			cc.goBack( data )
			data.readyChan <- 1
		default:
		}
	}
}




func( cc * ConstructionCrew ) sendStopQueries( data * Data, p * Pair ){
	for i, x := range data.trains {
		if !( i == p.id && p.typeOfBroken == TRAIN ) && i != 0{
		// if i != 0 {
			x.stopChan <- 1	
		}
	}
}




func ( cc * ConstructionCrew ) waitForTrains( data * Data ){
	number := len( data.trains ) - 1
	if cc.typeOfBroken == TRAIN {
		number-- 
	}
	i := 0

	for i < number {
		select{
		case <-data.readyTrains:
			i++;
		default:
		}
	}
}




func ( cc * ConstructionCrew ) createGraph( data * Data ){

	cc.graph = data.edges
	
	for i, x := range data.lines {
		if i > 0 && x.checkIfOccupied() {
			cc.graph[ data.lines[ cc.id ].first ][ data.lines[ cc.id ].second ] = 0
		}
	}

}





func ( cc * ConstructionCrew ) sendBreak( data * Data, breakdown Pair ){
	if breakdown.typeOfBroken == SWITCH{
		data.switches[ breakdown.id ].isBroken = true
	} else if breakdown.typeOfBroken == LINE {
		data.lines[ breakdown.id ].isBroken = true
	}else{
		data.trains[ breakdown.id ].isBroken = true
	}
} 




func ( cc * ConstructionCrew ) createPath( data * Data, start, stop int){
	if cc.typeOfBroken == SWITCH {
		result := cc.BFS( data, start, cc.id )
		if !result{
			fmt.Println("Nie udało się znaleźć ścieżki ")
		}
	} else if( cc.typeOfBroken == LINE || cc.typeOfBroken == TRAIN){
		lineId := cc.id
		if cc.typeOfBroken == TRAIN{
			lineId = data.trains[ cc.id ].currentLine
		}
		first := data.lines[ lineId ].first
		second := data.lines[ lineId ].second
		result := cc.BFS( data, start, first )
		if !result {
			result = cc.BFS( data, start, second )
		}
		if !result {
			fmt.Println("Nie udało się znaleźć ścieżki ")
		}
	} else{
		cc.graph = data.edges
		cc.BFS( data, start, cc.origin )
	}
}




func ( cc * ConstructionCrew ) BFS( data * Data, start, stop int ) bool{
	parents := make( []int, len( data.switches ) )
	visited := make( []int, len( data.switches ) )
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
		for i, x := range cc.graph[ temp ]{
			if x != 0 && visited[ i ] == 0{
				parents[ i ] = temp
				queue = append( queue, i )
				visited[ i ] = 1
			}
		}
	}

	temp := make( []int, 0 )
	cc.path = make( []int, 0 )

	if visited[ stop ] == 1 {
		i := stop
		temp = append( temp, stop )
		for parents[ i ] != -1 {
			temp = append( temp, parents[ i ]  )
			i = parents[ i ]
		}

		for i := len( temp ) - 1 ; i >= 0 ; i-- {
			cc.path = append( cc.path, temp[ i ] ) 
		}
		return true
	} else {
		return false
	}
}





func ( cc * ConstructionCrew) goByPath( data * Data ){ 
	i := 0
	for i < len( cc.path ) -1 {
		cc.changeLine( data, i )
		cc.goCurrentLine( data, i )
		i++
	}
	if cc.typeOfBroken == SWITCH{
		cc.printPointReachInfo(data)
	} else{
		lineId := cc.id
		if cc.typeOfBroken == TRAIN {
			lineId = data.trains[ cc.id ].currentLine 
		}
		// use switch
		cc.useSwitch( data, cc.path[ i ], lineId )
		cc.printPointReachInfo(data)
	}
}




func ( cc * ConstructionCrew ) changeLine( data * Data, pos int ){

	first := cc.path[ pos ]
	second := cc.path[ pos + 1 ]
	lineId := cc.graph[ first ][ second ]
	cc.useSwitch( data, first, lineId )
}




func ( cc * ConstructionCrew ) useSwitch( data * Data, switchId, lineId int ){
	cc.printStartSwitchInfo( data, switchId)
	time.Sleep( time.Second * time.Duration(data.switches[ switchId ].changeTime))
	cc.printStopSwitchInfo( data, lineId)
}




func ( cc * ConstructionCrew ) goCurrentLine( data * Data, pos int ){
	first := cc.path[ pos ]
	second := cc.path[ pos + 1 ]
	lineId := cc.graph[ first ][ second ]
	cc.useLine( data, lineId )
}




func ( cc * ConstructionCrew )  useLine( data * Data, lineId int ){
	//@FROST
	t := data.lines[ lineId ].minStop
	if !data.lines[ lineId ].isStopLine {
		speed := data.lines[ lineId ].maxSpeed 
		t = data.lines[ lineId ].length / speed
	}
	cc.printStartLineInfo( data, lineId )
	time.Sleep( time.Second * time.Duration( t ) )
	cc.printStopLineInfo( data, lineId )
}



func ( cc * ConstructionCrew ) printStartSwitchInfo(data * Data, swtichId int){
	FrostPrint(data, "Ekipa remontowa wjeżdza na zwrotnice " + strconv.Itoa(swtichId) )
}



func ( cc * ConstructionCrew ) printStopSwitchInfo(data * Data,lineId int){
	FrostPrint(data, "Ekipa remontowa wjeżdza na tor " + strconv.Itoa(lineId) )
}



func ( cc * ConstructionCrew ) printPointReachInfo(data * Data){
	FrostPrint(data, "Ekipa remontowa dojechała na miejsce awarii." )
}



func ( cc * ConstructionCrew ) printStartLineInfo(data * Data, lineId int ){
	FrostPrint(data, "	Ekipa remontowa zaczyna jechac torem  " + strconv.Itoa(lineId) )
}



func ( cc * ConstructionCrew ) printStopLineInfo(data * Data, lineId int ){
	FrostPrint(data, "Ekipa remontowa dojechala na koniec toru " + strconv.Itoa(lineId) )
}



func ( cc * ConstructionCrew ) printFinishBreakDown(data * Data ){
	FrostPrint(data, "Ekipa remontowa zakończyła prace remontowe")
}



func ( cc * ConstructionCrew ) 	printHomeInfo( data * Data){
	FrostPrint(data, "Ekipa remontowa wróciła do domu")
}



func ( cc ConstructionCrew ) showPath( data * Data ){
	fmt.Print("Oto ona: ")
	for _, x := range cc.path {
		fmt.Print(  x )
		fmt.Print( " " )
	}
	fmt.Println()
}




func ( cc * ConstructionCrew) repair( data * Data ){
	cc.printPointReachInfo(data)
	time.Sleep( time.Second * time.Duration( cc.repairTime ) )
	switch cc.typeOfBroken{
	case SWITCH:
		data.switches[ cc.id ].isBroken = false
	case LINE:
		data.lines[ cc.id ].isBroken = false
	case TRAIN:
		data.trains[ cc.id ].isBroken = false 
	default:
	}
	cc.printFinishBreakDown(data)
}




func ( cc * ConstructionCrew ) blockAllSwitchesOnThePath( data * Data ){
	for _, x := range cc.path{
		data.switches[ x ].isBroken = true
	}
}





func ( cc * ConstructionCrew ) unblockAllSwitchesOnThePath( data * Data ){
	for _, x := range cc.path{
		data.switches[ x ].isBroken = false
	}
}





func ( cc * ConstructionCrew ) restoreTraffic( data * Data ){
	for i, x := range data.trains {
		if !(cc.typeOfBroken == TRAIN && i == cc.id) && i != 0 {
			x.stopChan <- 1
		}
	}
}



func ( cc * ConstructionCrew ) goBack( data * Data ){
	var order 			Order
	var nextLine 		int
	var currentLine 	int
	cc.typeOfBroken = ORIGIN 
	cc.createPath( data, cc.path[ len( cc.path ) - 1 ], cc.origin )
	cc.showPath(data)

	currentLine = 0
	for i, x := range cc.path {
		if i != 0{
			currentLine = data.edges[ cc.path[ i - 1] ][ x ]
		}
		if i == len( cc.path ) - 1 {
			order = Order{ 0, -1, currentLine }
		} else{
			nextLine = data.edges[ x ][ cc.path[ i + 1 ] ]
			order = Order{ 0, nextLine, currentLine }
		}

		data.switches[ x ].specBuffor <- order 
		cond := true 
		for cond {
			select{ 
			case msg := <-cc.pathChan:
				switch msg{
				case RETRY:
					data.switches[ x ].specBuffor <- order 
				case GO:
					if i != len( cc.path ) - 1{
						cc.useLine( data, nextLine)
					}
					cond = false
				}
			default:
			}
		}
	}
	cc.printHomeInfo(data )
}




func ( cc * ConstructionCrew ) stats( data * Data ){
	for _, x := range data.lines{
		// fmt.Print( i )
		// fmt.Print( " " )
		// fmt.Println( x.checkIfOccupied() )
		x.reset()
	}
	for _, x := range data.trains{
		// fmt.Println( x.currentLine )
		data.lines[ x.currentLine ].reserveLine()
	}
}