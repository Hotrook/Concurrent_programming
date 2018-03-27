package main

import(
	"fmt"
	"time"
    "strconv"
	"os"
)


func main(){

	var n int // number of switches( cities, stations )
	var m int // number of stop lines( tory postojowe )
	var k int // number of transient lines ( tory przejazdowe )
	var p int // number of data.trains( pociągi - p )
	var w int // number of data.trains( pociągi - p )
	var breakdownsOff int
	var t int // tryb: 0 - tryb gadatliwy, 1 - tryb niegadatliwy
	
	var mult, timeLength int 

	var x, y int

	var data = new( Data )
	var bg = new( BreakdownGenerator )

	fmt.Scanf( "%d %d %d %d %d %d %d\n", &n, &m, &k, &p, &w, &t, &breakdownsOff );

	

	initialize( data, t, p, m, k, n, w )
	data.readyChan = make( chan int, 2 ) 


	fd, _ := os.Open( "../config.txt" )
	fmt.Fscanf(fd, "%d %d\n", &timeLength, &mult)
	data.mult = mult;


	readSwitches( data, n )
	readGoLines( data, m )
	readStopLines( data, k, m )
	readTrains( data, p )
	readWorkers( data, w )
	readConstructionCrew( data )
	createWorkersManager( data )


	for i := 1 ; i <= p ; i++ {
		go data.trains[ i ].start( data )
	}

	for i := 1 ; i <= n ; i++ {
		go data.switches[ i ].start( data )
	}

	for i := 1 ; i <= w ; i++ {
		go data.workers[ i ].start()
	}
	time.Sleep(time.Second)

	if breakdownsOff != 1 {
		go bg.start( data )
		go data.constCrew.start( data )
	}

	go data.workersManager.start()

	if data.t == 0 {
		go func(){
			for{
				fmt.Scanf( "%d %d\n", &x, &y );
				if x == 0 {
					if data.trains[ y ].isStop {
						fmt.Println( "Pociąg "+ strconv.Itoa( y ) + 
							" stoi na torze " + 
							strconv.Itoa( data.trains[ y ].currentLine ) )
					} else{
						fmt.Println( "Pociąg " + strconv.Itoa( y ) + 
							" jedzie na torze " + 
							strconv.Itoa( data.trains[ y ].currentLine ))
					}
				} else if x == 1 {
					if data.lines[ y ].isOccupied {
						fmt.Println( "Tor " + strconv.Itoa( y ) +
						 " jest zajęty przez pociąg "+ 
						 strconv.Itoa( data.lines[ y ].train ) )
					} else{
						fmt.Println( "Tor "+ strconv.Itoa( y ) + " jest wolny")
					}
				}else if x == 2 {
					if data.switches[ y ].isOccupied {
							fmt.Println( "Zwrotnica " + strconv.Itoa( y ) +
							" jest zajęta przez pociąg " +
							strconv.Itoa( data.switches[ y ].trainId ) )
					} else{
						fmt.Println( "Zwrotnica "+ strconv.Itoa( y ) + " jest wolna")
					}
				}
			}
		}()
	}

	time.Sleep( time.Second * time.Duration( timeLength ) )

}