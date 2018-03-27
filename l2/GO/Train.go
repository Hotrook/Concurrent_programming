package main

import(
	"time"
    "strconv"
    "fmt"
)


type Train struct{
	numberTrain 				int
	numberPassengers 			int
	speed 						int
	currentLine 				int
	nextLine	 				int
	currentState 				int
	isStop 						bool
	isWait						bool
	isBroken					bool
	confSent					bool
	stopChan 	 				chan int
	goChan						chan int
	stations 					[]int
}





func NewTrain( numberPassengers, speed int) *Train{
	
	t := new( Train )
	t.numberPassengers = numberPassengers
	t.speed = speed;
	t.currentState = 0;
	return t

}





func (t *Train) start(data * Data){
	
	t.nextLine = data.edges[ t.stations[ 0 ] ][ t.stations[ 1 ] ]
	t.goChan <- GO
	t.currentState = 0

	for{
		select{ 
		case <-t.stopChan:
			fmt.Println("\tPOCIĄG "+strconv.Itoa( t.numberTrain ) + " ODEBRAŁ INFO O AWARII")
			t.isWait = neg( t.isWait )
		default:
		}
		select{
		case  msg := <-t.goChan:
			if t.isWait{
				t.stopAndWaitIfBreakdown(data, msg)
			} else {
			switch msg{
				case GO:
					t.calculateNextLine(data)
					t.goCurrentLine( data )
					t.changeLine( data )		
				case RETRY:
					time.Sleep( time.Second * 5)
					t.changeLine( data )
				case RECOVERY:
					t.changeLine( data ) 
				default:
				}
			}	
		default:

		}
		time.Sleep( time.Millisecond * 500 )	
	}

}





func (t *Train) addList(list []int){
	
	t.stations = list;

}





func (t *Train) changeLine( data * Data ){

	t.checkIfBroken(data);
	firstSwitch := t.stations[ t.currentState % len(t.stations)]
	data.switches[ firstSwitch ].buffor <- Order{ t.numberTrain, t.nextLine, 0 }
	
}





func (t * Train) goCurrentLine(data *Data ){
	
	t.checkIfBroken(data);

	if data.lines[ t.currentLine ].isStopLine {
		t.isStop = true
		t.printStopInfo(data)
		time.Sleep( time.Second * time.Duration( data.lines[ t.currentLine ].minStop * data.mult ))
		t.isStop = false
	} else{
		speed := 0 
		speed = Min( data.lines[ t.currentLine ].maxSpeed, t.speed )

		var waitTime int = data.lines[ t.currentLine ].length / speed;

		t.printStartGoingInfo(data)
		time.Sleep( time.Second * time.Duration(waitTime*data.mult) )
		t.printStopGoingInfo(data)
	}



}









func (t * Train ) printStartGoingInfo( data * Data ){
		FrostPrint(data, "Pociąg "+ strconv.Itoa(t.numberTrain)+" wjeżdza na tor "+ 
			strconv.Itoa(t.currentLine))
}





func (t * Train ) printStopGoingInfo( data * Data ){
	FrostPrint(data, "Pociąg "+ strconv.Itoa(t.numberTrain)+
		" dojechał na koniec toru "+ strconv.Itoa(t.currentLine))
}






func (t * Train ) printStopInfo( data * Data ){
	FrostPrint(data, "Pociąg "+ strconv.Itoa(t.numberTrain)+
		" stoi na torze postojowym nr "+ strconv.Itoa(t.currentLine))
}




func (t * Train) stopAndWaitIfBreakdown( data * Data, msg int){
		if msg == GO {                 
			t.calculateNextLine(data)
			t.goCurrentLine(data)
		}
		
		if !data.lines[ t.currentLine ].isStopLine &&
		   !data.lines[ t.currentLine ].isBroken {
			
			switchId := t.stations[ t.currentState % len(t.stations) ]
			next := t.nextLine
			data.lines[ next ].mutex.Lock();
			if !data.lines[ t.nextLine ].checkIfOccupied() &&
			   !data.switches[ switchId].isBroken {			   	 
			   	t.changeLine( data )
			   	<-t.goChan
			   	t.calculateNextLine( data )
			}
			data.lines[ next ].mutex.Unlock();
		}

		data.readyTrains <- t.numberTrain
		<-t.stopChan
		t.isWait = false
		t.goChan <- RECOVERY
}





func (t * Train ) checkIfBroken(data * Data){
	for t.isBroken { time.Sleep(time.Millisecond)}
	// for data.lines[ t.currentLine ].isBroken { time.Sleep(time.Millisecond)}
}




func (t * Train ) calculateNextLine( data * Data ){
	t.currentState++
	t.currentLine = t.nextLine
	firstSwitch := t.stations[ t.currentState % len(t.stations)]
	secondSwitch := t.stations[ (t.currentState + 1) % len(t.stations)]
	t.nextLine = data.edges[ firstSwitch ][ secondSwitch ] 
}
