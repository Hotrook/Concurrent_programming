package main

import(
	"sync"
	"fmt"
	"time"
    "strconv"
	"os"
)

type Train struct{
	numberTrain, numberPassengers, speed, currentLine, currentState int
	isStop bool
	stations []int
}

func NewTrain( numberPassengers, speed int) *Train{
	
	t := new( Train )
	t.numberPassengers = numberPassengers
	t.speed = speed;
	t.currentState = 0;
	return t

}

func (t *Train) start(data * Data){
	nextState := 2
	nextLine := data.edges[ t.stations[ 0 ] ][ t.stations[ 1 ] ]
	t.currentLine = nextLine
	data.linesMutex[ t.currentLine ].Lock()
	t.goCurrentLine( data )
	t.currentState = 1
	
	for{
		if nextState == len( t.stations ){
			nextState = 0
		}
		if t.currentState == len( t.stations ){
			t.currentState = 0
		}

		nextLine = data.edges[ t.stations[ t.currentState ] ][ t.stations[ nextState ] ]
		t.changeLine( t.stations[ t.currentState ], nextLine, data );

		t.currentState = t.currentState + 1
		nextState = nextState + 1 
	}

}

func (t *Train) addList(list []int){
	
	t.stations = list;

}

func (t *Train) changeLine( nrSwitch, nrLine int, data *Data ){

	data.linesMutex[ nrLine ].Lock()
	data.switchesMutex[ nrSwitch ].Lock()
		
		FrostPrint( data, "Zwrotnica " + strconv.Itoa(nrSwitch) + 
			" zaczyna obracać pociąg "+ strconv.Itoa(t.numberTrain)+
			" na tor" +strconv.Itoa(nrLine) + "\n",)
		data.switches[ nrSwitch ].switchLine(t.numberTrain, data);
		FrostPrint( data, 
			"Zwrotnica " + strconv.Itoa(nrSwitch) + " obróciła pociąg "+ 
			strconv.Itoa(t.numberTrain) +" na tor" +strconv.Itoa(nrLine) + "\n",)

		data.linesMutex[ t.currentLine ].Unlock()

		data.lines[ nrLine ].takeTrain( t.numberTrain )
		t.currentLine = nrLine

		t.goCurrentLine( data )
	data.switchesMutex[ nrSwitch ].Unlock()

}

func (t * Train) goCurrentLine(data *Data ){
	
	speed := 0 
	if t.speed <= data.lines[ t.currentLine ].maxSpeed{
		speed = t.speed
	} else {
		speed = data.lines[ t.currentLine ].maxSpeed
	}
	var waitTime int = data.lines[ t.currentLine ].length / speed;


	FrostPrint(data, "Pociąg "+ strconv.Itoa(t.numberTrain)+" wjeżdza na tor "+ 
		strconv.Itoa(t.currentLine)+"\n")

	time.Sleep( time.Second * time.Duration(waitTime*data.mult) )

	FrostPrint(data, "Pociąg "+ strconv.Itoa(t.numberTrain)+
		" dojechał na koniec toru "+ strconv.Itoa(t.currentLine)+"\n")

	if data.lines[ t.currentLine ].isStop {
		t.isStop = true;
		FrostPrint(data, "Pociąg "+ strconv.Itoa(t.numberTrain)+
			" stoi na torze postojowym nr "+ strconv.Itoa(t.currentLine)+"\n")
		time.Sleep( time.Second * time.Duration( data.lines[ t.currentLine ].minStop * data.mult ))
		t.isStop = false;
	} 


}

func FrostPrint( d *Data, s string ){
	if d.t == 1 {
		fmt.Print( s )
	}
}



type Line struct{
	length, maxSpeed, minStop, train int
	isStop, isOccupied bool 
}

func NewLine( length, maxSpeed int ) *Line{
	
	l := new( Line )
	l.length = length 
	l.minStop = 0
	l.maxSpeed = maxSpeed
	l.isStop = false
	l.isOccupied = false
	l.train = -1
	return l 

}

func ( l * Line ) takeTrain( numberTrain int ){
	l.isOccupied = true
	l.train = numberTrain
}




type Switch struct{

	changeTime int
	trainId int
	isOccupied bool
}

func ( s * Switch ) switchLine( trainId int, data * Data ){

	s.isOccupied = true
	s.trainId = trainId
	time.Sleep( time.Second * time.Duration( s.changeTime * data.mult ) )
	s.isOccupied = false
} 



type Data struct{ 
	lines 		[]Line
	switches 	[]Switch
	edges		[][]int
	t 			int
	mult		int

	linesMutex 		[]sync.Mutex
	switchesMutex 	[]sync.Mutex

}




func main(){

	var n int // number of switches( cities, stations )
	var m int // number of stop lines( tory postojowe )
	var k int // number of transient lines ( tory przejazdowe )
	var p int // number of trains( pociągi - p )
	var t int // tryb: 0 - tryb gadatliwy, 1 - tryb niegadatliwy
	var mult, timeLength int 

	var x, y, z, l int

	var data = new( Data )

	var trains []Train

	fmt.Scanf( "%d %d %d %d %d\n", &n, &m, &k, &p, &t )

	data.t = t
	trains = make( []Train, p + 1 )
	data.lines = make( []Line, m+1 )
	data.linesMutex = make( []sync.Mutex, m+1 )
	data.switches = make( []Switch, n+1 )
	data.switchesMutex = make( []sync.Mutex, n+1 )
	data.edges = make( [][]int, n+1 )



	fd, _ := os.Open( "../config.txt" )
	fmt.Fscanf(fd, "%d %d\n", &timeLength, &mult)
	data.mult = mult;

	for i := 0 ; i <= n ; i++ {
		data.edges[ i ] = make( []int, n + 1 )

	}

	for i := 1 ; i <= n ; i++ {
		fmt.Scanf("%d\n", &x );
		data.switches[ i ].changeTime = x;
	}

	for i := 1 ; i <= m ; i++ {

		fmt.Scanf( "%d %d %d %d\n", &x, &y, &l, &z );
		data.edges[ x ][ y ] = i;
		data.lines[ i ] = Line{ 
							length: l, 
							maxSpeed: z,
							minStop: 0,
							train: 0,
							isStop: false,
							isOccupied: false }
		data.linesMutex[ i ] = sync.Mutex{}

	}

	for i := 1 ; i <= k ; i++ {

		fmt.Scanf("%d %d %d\n", &x, &y, &z )
		line := data.edges[ x ][ y ] 
		data.lines[ line ].isStop = true
		data.lines[ line ].minStop = z 

	}
	for i := 1 ; i <= p ; i++ {

		fmt.Scanf( "%d %d %d\n", &x, &y, &z )
		trains[ i ] = Train{
			numberTrain: i, 
			numberPassengers: x,
			speed: y,
			currentState: 0,
			isStop: false,
		}

		x = z
		list := make( []int, x )
		for j := 0 ; j < x ; j++ {
			fmt.Scanf("%d", &z )
			list[ j ] = z
		}

		trains[ i ].addList( list )



	}


	for i := 1 ; i <= p ; i++ {
		go trains[ i ].start( data )
	}

	if data.t == 0 {
		go func(){
			for{
				fmt.Scanf( "%d %d\n", &x, &y );
				if x == 0 {
					if trains[ y ].isStop {
						fmt.Println( "Pociąg "+ strconv.Itoa( y ) + 
							" stoi na torze " + 
							strconv.Itoa( trains[ y ].currentLine ) )
					} else{
						fmt.Println( "Pociąg " + strconv.Itoa( y ) + 
							" jedzie na torze " + 
							strconv.Itoa( trains[ y ].currentLine ))
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