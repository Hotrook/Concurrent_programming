package main 

import(
	"math/rand"
	"time"
	"strconv"
)
type WorkerManager struct{
	probability 		float32
	data 				*Data
	confirmationChannel chan int
}





func ( wm * WorkerManager ) start(){
	wm.probability = 0.01
	generator := rand.New(rand.NewSource(9001))
	for {
		p := generator.Float32()
		if p < wm.probability {
			FrostPrint( wm.data, "ZADANIE DLA PRACOWNIKÓW")
			workersNumber := generator.Intn( len(wm.data.workers) - 3 )+1
			workersList := wm.createWorkersList( workersNumber )
			t := generator.Intn( 100 )
			goal := wm.generateGoal()

			wm.sendRequests( workersList, goal )
			FrostPrint( wm.data, "ZADANIE DLA PRACOWNIKÓW")
			wm.waitForConfirmation( workersNumber )
			
			wm.printStartMessage( goal )
			time.Sleep( time.Second * time.Duration( t ) )
			wm.printStopMessage( goal )

			wm.finish( workersList )
			wm.waitForConfirmation( workersNumber )
		}
	}

}





func ( wm * WorkerManager ) createWorkersList( workersNumber int ) []int{
	result := make( []int, 0 )
	generator := rand.New( rand.NewSource( 2103 ) )


	it := 0 
	for it < workersNumber {
		id := generator.Intn( len(wm.data.workers)-1 ) + 1
		for isInList( result, id ) {
			id = generator.Intn( len(wm.data.workers)-1 ) + 1
		}
		result = append( result, id )
		it++
	}
	return result
}





func isInList( list []int, element int ) bool{
	for _, x := range list {
		if x == element{
			 return true
		}
	}
	return false
}





func (wm * WorkerManager ) generateGoal() int{
	generator := rand.New( rand.NewSource( 2103 ) )
	goal := generator.Intn( len( wm.data.lines ) - 1 ) + 1
	for !wm.data.lines[ goal ].isStopLine {
		goal = generator.Intn( len( wm.data.lines ) - 1 ) + 1
	}
	return goal
}





func ( wm * WorkerManager ) sendRequests( list []int, goal int ){
	for _, x := range list {
		wm.data.workers[ x ].taskChannel <- goal 
	}
	wm.printWorkersInfo( list )
}





func ( wm * WorkerManager ) waitForConfirmation( workersNumber int ){
	it := 0

	for it < workersNumber {
		x := <-wm.confirmationChannel
		wm.printConfirmationFrom( x )
		it++
	}
}





func ( wm * WorkerManager ) printStartMessage( goal int ){
	FrostPrint( wm.data, "Pracownicy zaczynają prace na torze " + strconv.Itoa(goal) )
}






func ( wm * WorkerManager ) printStopMessage( goal int ){
	FrostPrint( wm.data, "Pracownicy kończą prace na torze " + strconv.Itoa(goal) )
}




func ( wm * WorkerManager ) finish( list []int ){
	for _, x := range list {
		wm.data.workers[ x ].finish <- true
	}
}





func (wm * WorkerManager) printConfirmationFrom( x int ){
	FrostPrint( wm.data, "Pracownik " + strconv.Itoa( x ) + " dojechał na miejsce. ")
}





func ( wm * WorkerManager ) printWorkersInfo( list []int){
	workers := strconv.Itoa( list[ 0 ] )
	it := 1

	for it < len( list ) {
		workers = workers + ", " + strconv.Itoa( list[ it ] ) 
		it++
	} 

	FrostPrint( wm.data, " Wezwano pracowników "+workers)
}