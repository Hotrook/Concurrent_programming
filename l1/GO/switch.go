

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