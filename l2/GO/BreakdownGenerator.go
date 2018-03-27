package main

import( 
	"math/rand"
	"time"
)

type BreakdownGenerator struct{
	breakdown bool
}




func ( bg * BreakdownGenerator ) start( data * Data ){
	generator := rand.New(rand.NewSource(99))
	for{
		for i, x := range data.trains {
			if i != 0 {
				p := generator.Float32()
				if p < data.breakdownProbability && data.isBreakdownPossible {
					data.isBreakdownPossible = false
					x.isBroken = true
					data.constCrewChan <- Pair{ i, TRAIN }
				}
			}
		}
		for i, x := range data.switches {
			if i != 0 {
				p := generator.Float32()
				if p < data.breakdownProbability && data.isBreakdownPossible {
					data.isBreakdownPossible = false
					x.isBroken = true
					data.constCrewChan <- Pair{ i, SWITCH }

				}
			}
		}
		for i, x := range data.lines {
			if i != 0 {
				p := generator.Float32()
				if p < data.breakdownProbability && data.isBreakdownPossible {
					data.isBreakdownPossible = false
					x.isBroken = true
					data.constCrewChan <- Pair{ i, LINE }
				}
			}
		}
		if data.isBreakdownPossible == false{
			<-data.readyChan
			data.isBreakdownPossible = true
		}
		time.Sleep( time.Millisecond * 500 )
	}
}




