package main

import (
	"sync"
)

type Line struct{
	id 				int
	first 			int
	second 			int
	length 			int
	maxSpeed 		int
	minStop 		int 
	train 			int
	capacity 		int
	occupied 		int
	isStopLine 		bool
	isOccupied 		bool 
	isBroken 		bool 
	mutex			sync.Mutex
}


func ( l * Line ) takeTrain( numberTrain int ){
	l.isOccupied = true
	l.train = numberTrain
}



func ( l * Line) checkIfOccupied() bool {
	if l.isStopLine {
		if l.capacity == l.occupied {
			return true
		} else {
			return false
		}
	} else {
		return l.isOccupied 
	}
}




func ( l * Line) releaseLine(){
	if l.isStopLine {
		l.occupied = Max( 0, l.occupied-1 )
	}
	l.isOccupied = false
}




func ( l * Line ) reserveLine(){
	if l.isStopLine {
		l.occupied++
		if l.occupied == l.capacity{
			l.isOccupied = true
		}
	} else{
		l.isOccupied = true
	}
	if l.isOccupied {
	}
}




func ( l * Line ) reset(){
	if l.isStopLine{
		l.occupied = 0
	} 
	l.isOccupied = false 
}