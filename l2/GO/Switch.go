package main

import(
	"time"
	"strconv"
	"fmt"
)

type Switch struct{

	id 					int
	changeTime 			int
	trainId 			int
	isOccupied 			bool
	isBroken			bool
	isStop				bool
	buffor 				chan Order
	specBuffor			chan Order
	stopChan 			chan int

}

func ( s * Switch ) switchLine( trainId, lineId int, data * Data ){

	s.isOccupied = true
	s.trainId = trainId
	data.lines[ lineId ].reserveLine()
	s.printStartInfo( data, lineId )
	time.Sleep( time.Second * time.Duration( s.changeTime * data.mult ) )
	s.printFinishInfo( data, lineId )
	s.isOccupied = false

} 

func ( s * Switch ) start( data * Data  ){

	for{
		select{
			case order := <-s.specBuffor:
				s.handleSpecOrder( data, order )
			default:
		}
		select{ 
		case order := <-s.buffor :
			if !data.lines[ order.lineNumber ].checkIfOccupied() && !s.isBroken  &&
				!data.lines[ order.lineNumber ].isBroken {
				s.releaseLine( data, order.trainNumber )
				s.switchLine( order.trainNumber, order.lineNumber, data )
				data.trains[ order.trainNumber ].goChan <- GO
			}else{
				data.trains[ order.trainNumber ].goChan <- RETRY
			}
		default:

		}
	}
}




func ( s * Switch ) printStartInfo( data * Data, lineId int ){
			FrostPrint( data, "Zwrotnica " + strconv.Itoa(s.id) + 
			" zaczyna obracać pociąg "+ strconv.Itoa(s.trainId)+
			" na tor " +strconv.Itoa(lineId))
}





func ( s * Switch ) printFinishInfo( data * Data, lineId int ){
	FrostPrint( data, "Zwrotnica " + strconv.Itoa(s.id) + " obróciła pociąg "+
		strconv.Itoa(s.trainId) +" na tor " + 
		strconv.Itoa(lineId) )
}





func (s * Switch ) checkIfBroken(data * Data){
	for s.isBroken { 
		time.Sleep(time.Millisecond)
		select{ 
		case order := <-s.buffor:
			data.trains[ order.trainNumber ].goChan <- RETRY
		default:
		}
	}
}





func (s * Switch )  releaseLine( data * Data, trainId int ){
		data.lines[ data.trains[ trainId ].currentLine ].releaseLine()
}



func ( s * Switch ) handleSpecOrder( data * Data, order Order ){
	if order.lineNumber == -1 {
		data.lines[ order.help ].releaseLine();
		s.switchConstCrew( data, order.lineNumber )
		data.constCrew.pathChan <- GO
	} else { 
		if !data.lines[ order.lineNumber ].checkIfOccupied() {
			data.lines[ order.lineNumber ].reserveLine()
			if order.help != 0 {
				data.lines[ order.help ].releaseLine();
			}
			s.switchConstCrew( data, order.lineNumber )
			data.constCrew.pathChan <- GO

		} else {
			data.constCrew.pathChan <- RETRY
		}
	}
}




func ( s * Switch ) switchConstCrew( data * Data, lId int ){
	if lId == -1 {
		fmt.Println( "Zwrotnica " + strconv.Itoa( s.id ) + " obraca ekipę remontową do miejsca docelowego")
	} else {
		fmt.Println( "Zwrotnica " + strconv.Itoa( s.id ) + " obraca ekipę remontową na tor " + strconv.Itoa( lId )) 
	}
	time.Sleep( time.Second * time.Duration( s.changeTime ) )
}






