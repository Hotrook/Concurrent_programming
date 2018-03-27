

package body SwitchTaskClass is


    task body SwitchTask is
        id : Integer := N;
        trainId : Integer;
        lineId : Integer;
        c : Integer;
        response : Integer;
    begin
        loop
            select
                when True => accept SWITCH_LINE_WITH_WAIT( TID, LID, priority : in Integer) do
                    trainId := TID;
                    S.releaseLine( D.trains(trainId).currentLine );
                    S.switchLine( TID, LID );
                end SWITCH_LINE_WITH_WAIT;
            or
                when True => accept SWITCH_LINE( TID, LID, priority : in Integer) do
                    trainId := TID;
                    lineId := LID;
                end SWITCH_LINE;
                if S.D.lines( lineId ).checkIfOccupied = False and
                   S.D.lines( lineId ).isBroken = False and
                   S.isBroken = False then
                       S.releaseLine( S.D.trains(trainId).currentLine );
                       S.switchLine( trainId, lineId );
                       S.D.trainTasks( trainId ).GO;
                else
                    D.r(trainId).RETRY( trainId );
                end if;
            or
                when True => accept SWITCH_CCT( NEXT, CURR : Integer ) do
                    lineId := NEXT;
                    c := CURR;
                end SWITCH_CCT;
                response := D.switches( id ).handleSpecOrder(lineId, c);
                if response = 1 then
                    D.CCT.GO;
                else if response = 2 then
                    D.CCT.RETRY;
                end if; end if;
            end select;
        end loop;
    end SwitchTask;






    procedure switchLine( S : access Switch ; TID, LID : in Integer ) is
    begin
        S.isOccupied := true;
        S.trainId := TID;
        S.D.lines( LID ).reserveLine;
        S.printStartInfo( TID, LID );
        delay Standard.Duration(S.changeTime * 1);
        S.printFinishInfo( TID, LID );
        S.isOccupied := False;


        --FROST -- dwie jedynki do poprawki
        S.isOccupied := false;
    end;



    function handleSpecOrder( S: access Switch; lineId, help : Integer )
        return Integer is
        result : Integer := 1;
    begin
        if lineId = -1 then
            S.D.lines( help ).releaseLine;
            S.switchConstCrew( lineId );
            result := 1;
        else
            if S.D.lines( lineId ).checkIfOccupied = False then
                S.D.lines( lineId ).reserveLine;
                if help /= 0 then
                    S.D.lines( help ).releaseLine;
                end if;
                S.switchConstCrew( lineId );
                result := 1;
            else
                result := 2;
            end if;
        end if;

        return result;
    end handleSpecOrder;



    procedure switchConstCrew( S : access Switch; lineId : Integer ) is
    begin
        if lineId = -1 then
            printFrost("Zwrotnica " & Integer'Image( S.id ) &
                " obraca ekipę remontową do miejsca docelowego", S.D.t);
        else
            printFrost("Zwrotnica " & Integer'Image( S.id ) &
                " obraca ekipę remontową na tor" &
                Integer'Image( lineId ), S.D.t);
        end if;
        delay Standard.Duration( S.changeTime );
    end switchConstCrew;



    procedure printStartInfo( S : access Switch; TID, LID : Integer ) is
    begin
        printFrost( "Zwrotnica "& Integer'Image(S.id) & " przekreca pociag "
                    & Integer'Image(TID) &" na tor " &
                    Integer'Image(LID), S.D.t );
    end printStartInfo;


    procedure printFinishInfo( S : access Switch; TID, LID : Integer ) is
    begin
        printFrost( "Zwrotnica "& Integer'Image(S.id) & " przekrecila pociag "
                & Integer'Image(TID) &" na tor " &
                Integer'Image(LID), S.D.t );
    end printFinishInfo;



    procedure releaseLine( S : access Switch ; LID : Integer ) is
    begin
        S.D.lines( LID ).releaseLine;
    end releaseLine;











        task body TrainTask is
            nextState : Integer := 3;
        begin
            accept Start do
                null;
            end Start;

            T.nextLine := T.D.edges( T.stations( 1 ) , T.stations( 2 ) );
            T.currentState := 1;
            T.D.r(t.numberTrain).GO(t.numberTrain);

            loop
                select
                    when True => accept stopChan do
                        Put_line("Pociąg " & Integer'Image(T.numberTrain) & " odebrał info o awarii. ");
                        T.isWait := True;
                    end stopChan;
                or
                    when True => accept GO do
                        null;
                    end GO;
                        if T.isWait then
                            T.stopAndWaitIfBreakdown( 1 );
                        else
                            T.calculateNextLine;
        					T.goCurrentLine;
        				    T.changeLine;
                        end if;
                or
                    when True => accept RETRY do
                        null;
                    end RETRY;
                    if T.isWait then
                        T.stopAndWaitIfBreakdown(2);
                    else
                        delay Standard.Duration(5);
                        T.changeLine;
                    end if;
                end select;

            end loop;
        end TrainTask;




        procedure addList( V : access Train; stationsList : in Int_array ) is
        begin
            V.stations := stationsList;
        end;



        procedure goCurrentLine( T : access Train ) is
            speed : Integer;
            waitTime : Integer;
        begin
            T.checkIfBroken;
            --Put_line("Pociag "&Integer'Image(T.numberTrain)&" linia "& Integer'Image(T.currentLine) );
            if T.D.lines( T.currentLine ).isStopLine then
                T.isStop := true;
                T.printStopInfo;
                delay Standard.Duration( T.D.lines( T.currentLine ).minStop * T.D.mult );
                T.isStop := false;
            else
                speed := Integer'Min( T.D.lines( T.currentLine ).maxSpeed, T.speed );
                waitTime := T.D.lines( T.currentLine ).length / speed;

        		T.printStartGoingInfo;
                delay Standard.Duration( waitTime * T.D.mult );
        		T.printStopGoingInfo;
            end if;
        end goCurrentLine;




        procedure calculateNextLine( T : access Train  ) is
            firstSwitch : Integer;
            secondSwitch : Integer;
        begin
            T.currentState := T.currentState + 1;
            T.currentLine := T.nextLine;
            firstSwitch := T.stations( (T.currentState-1) mod (T.stations'Length) + 1);
            secondSwitch := T.stations( (T.currentState ) mod (T.stations'Length) + 1);
            T.nextLine := T.D.edges( firstSwitch, secondSwitch );
            --printFrost("POCIĄG " & Integer'Image( t.numberTrain ) & ", NASTĘPNA TOR: " & Integer'Image(t.nextLine ), T.D.t);
        end calculateNextLine;




        procedure changeLine( T : access Train ) is
            firstSwitch : Integer;
            p : Integer;
        begin
            T.checkIfBroken;
            firstSwitch := T.stations( (T.currentState-1) mod (T.stations'Length) + 1);

            p := 0;
            T.D.switchTasks(firstSwitch).SWITCH_LINE( T.numberTrain, T.nextLine, p );
        end changeLine;


        procedure changeLineWithWait( T : access Train ) is
            firstSwitch : Integer;
            p : Integer;
        begin
            T.checkIfBroken;
            firstSwitch := T.stations( (T.currentState-1) mod (T.stations'Length) + 1);
            p := 0;
            T.D.switchTasks(firstSwitch).SWITCH_LINE_WITH_WAIT( T.numberTrain, T.nextLine, p );
        end changeLineWithWait;



        procedure checkIfBroken( T : access Train ) is
        begin
            while T.isBroken loop
                delay 0.1;
            end loop;
        end checkIfBroken;




        procedure stopAndWaitIfBreakdown( T : access Train; msg : Integer ) is
            switchId : Integer;
            nextLine : Integer;
        begin
            if msg = 1 then
                T.calculateNextLine;
                T.goCurrentLine;
            end if;

            if T.D.lines( T.currentLine ).isStopLine = False and
               T.D.lines( T.currentLine ).isBroken = False and
               T.D.lines( T.nextLine ).isBroken = False then
                   switchId := T.stations((T.currentState-1) mod (T.stations'Length) + 1);
                   nextLine := T.nextLine;
                --mutexstart
                   if T.D.lines( t.nextLine ).checkIfOccupied = False and
                      T.D.switches( switchId ).isBroken = false then
                          T.changeLineWithWait;
                          T.calculateNextLine;
                      else
                         Put_Line(Integer'Image(T.numberTrain )& " cond1");
                   end if;
                   --mutexStop
               else
                   Put_Line(Integer'Image(T.numberTrain )& " cond2");

            end if;

            Put_Line("  POCIĄG! " & Integer'Image( T.numberTrain ) & " jest na torze " & Integer'Image( T.currentLine ) );
            T.D.CCT.CONFIRMATION( T.numberTrain );
            T.isWait := False;
        end stopAndWaitIfBreakdown;


        procedure printStopInfo( T : access Train ) is
        begin
            printFrost( "Pociąg "& Integer'Image(T.numberTrain) &
            " stoi na torze postojowym nr " & Integer'Image(T.currentLine), 1);
        end printStopInfo;




        procedure printStartGoingInfo( T : access Train  ) is
        begin
            printFrost( "Pociąg "& Integer'Image(T.numberTrain) & " wjeżdża na tor "
            & Integer'Image(T.currentLine), 1 );
        end printStartGoingInfo;





        procedure printStopGoingInfo( T : access Train  ) is
        begin
            printFrost( "Pociąg "& Integer'Image(T.numberTrain) & " dojechał na koniec toru "
            & Integer'Image(T.currentLine), 1 );
        end printStopGoingInfo;




        task body Retrier is
            TrainId : Integer;
        begin
            accept START do
                null;
            end START;

            loop
                select
                    when True => accept RETRY( TID : in Integer ) do
                        TrainId := TID;
                    end;
                    D.trainTasks(TrainId).RETRY;
                or
                    when True => accept GO( TID : in Integer ) do
                        TrainId := TID;
                    end GO;
                    D.trainTasks(TrainId).GO;
                    --delay Standard.Duration(5);
                else
                    null;
                end select;
            end loop;

        end Retrier;








    task body BG is
        G : Generator;
        breakdownPossible : Boolean := True;
        p : Float := 0.01;
    begin
        reset( G, 1286739 );

        loop
            for I in Integer range 1..trains loop
                if Random( G ) < p and breakdownPossible then
                    D.CCT.BREAKDOWN( types.TRAIN, I );
                    breakdownPossible := False;
                end if ;
            end loop;
            for I in Integer range 1..switches loop
                if Random( G ) < p and breakdownPossible then
                    D.CCT.BREAKDOWN( types.SWITCH, I );
                    breakdownPossible := False;
                end if ;
            end loop;
            for I in Integer range 1..lines loop
                if Random( G ) < p and breakdownPossible then
                    D.CCT.BREAKDOWN( types.LINE, I );
                    breakdownPossible := False;
                end if ;
            end loop;

            if breakdownPossible = False then
                accept CONTINUE do
                    breakdownPossible := True;
                end CONTINUE;
            end if;
        end loop;
    end BG;



    task body CCTask is
        confirmations : Integer;
        counter : Integer := 0;
        currentLine : Integer := 0;
        nextLine : Integer := 0;
        cond : Boolean;
    begin
        accept START do
            null;
        end START;

        loop
            select
                when true => accept BREAKDOWN( t : BREAK_TYPE; id : in Integer ) do
                    CC.typeOfBroken := t;
                    CC.id := id;
                    if t = types.TRAIN then
                        confirmations := D.trains'Length - 1;
                    else
                        confirmations := D.trains'Length;
                    end if;
                end BREAKDOWN;
                    CC.printBreakdownInfo;
                    CC.sendBreak;
                    CC.sendStopQueries;
                    counter := 0;
                    while counter < confirmations loop
                        accept CONFIRMATION( id : in Integer ) do
                            Put_Line("      Odebrano potwierdzenie od pociągu " & Integer'Image( id ) );
                        end CONFIRMATION;
                        counter := counter + 1;
                    end loop;
                    CC.createGraph;
                    CC.createPath( cc.origin, -1 );
                    CC.blockAllSwitchesOnThePath;
                    --CC.stats;
                    CC.restoreTraffic;
                    CC.goByPath;
                    CC.repair;
                    CC.unblockAllSwitchesOnThePath;
                    CC.createPath( CC.path( CC.path'Length ), CC.origin);
                    currentLine := 0;
                    for I in Integer range 1..CC.path'Length loop
                        if I /= 1 then
                            currentLine := D.edges( CC.path( I - 1 ), CC.path( I ) );
                        end if;
                        if i = CC.path'Length then
                            D.switchTasks( CC.path( I ) ).SWITCH_CCT( -1, currentLine);
                            nextLine := -1;
                        else
                            nextLine := D.edges( CC.path( I ), CC.path( I + 1 ) );
                            D.switchTasks( CC.path( I ) ).SWITCH_CCT( nextLine,
                                                                   currentLine);
                        end if;

                        cond := true;
                        while cond loop
                            select
                                when true => accept GO do
                                    null;
                                end GO;
                                    if I /= CC.path'Length then
                                        CC.useLine( nextLine );
                                    end if;
                                    cond := False;
                            or
                                when true => accept RETRY do
                                    null;
                                end RETRY;
                                D.switchTasks( CC.path( I ) ).SWITCH_CCT( nextLine, currentLine );
                            end select;
                        end loop;
                    end loop;
                    CC.printHomeInfo;
                    D.breakdownGenerator.CONTINUE;
            else
                delay Standard.Duration(1);
            end select;
        end loop;
    end CCTask;






    procedure sendBreak( C : access ConstructionCrew ) is
    begin
        if C.typeOfBroken = Types.SWITCH then
            C.D.switches( C.id ).isBroken := true;
        else if C.typeOfBroken = Types.LINE then
            C.D.lines( C.id ).isBroken := true;
        else if C.typeOfBroken = Types.TRAIN then
                C.D.switches( C.id ).isBroken := true;
                end if;
            end if;
        end if;
    end sendBreak;



    procedure sendStopQueries( C : access ConstructionCrew ) is
    begin
        for I in Integer range 1..(C.D.trains'Length) loop
            if ( C.typeOfBroken = Types.TRAIN and C.id = I ) = False then
                C.D.trainTasks( I ).stopChan;
            end if;
        end loop;
    end;



    procedure createGraph( C : access ConstructionCrew ) is
        n : Integer;
    begin
        n := C.D.edges'Length;
        C.graph := new Int_Array2( 1..n, 1..n );

        for I in Integer range 1..n loop
            for J in Integer range 1..n loop
                C.graph( I, J ) := C.D.edges( I, J );
            end loop;
        end loop;

        for I in Integer range 1..(C.D.lines'Length) loop
            if C.D.lines( I ).checkIfOccupied then
                C.graph( C.D.lines(I).first, C.D.lines(I).second ) := 0;
            end if;
        end loop;

    end;


    procedure createPath( C : access ConstructionCrew;
                          start, stop : Integer ) is
        result : Boolean;
        lineId : Integer;
        first, second : Integer;
    begin
        if stop = -1 then
            if C.typeOfBroken = Types.SWITCH then
                result := C.BFS( start, C.id );
                if result = False then
                    Put_Line("Nie udało się znaleźć trasy");
                end if;
            else if C.typeOfBroken = Types.LINE or C.typeOfBroken = Types.TRAIN then

                lineId := C.id;
                if C.typeOfBroken = Types.TRAIN then
                    lineId := C.D.trains( C.id ).currentLine;
                end if;

                first := C.D.lines( lineId ).first;
                second := C.D.lines( lineId ).second;
                result := C.BFS( start, first );
                if result = False then
                    result := C.BFS( start, second );
                end if;
                if result = False then
                    Put_Line("Nie udało się znaleźć trasy");
                end if;
            else
                null;
            end if;
            end if;
        else
            for I in Integer range 1..C.D.switches'Length loop
                for J in Integer range  1..C.D.Switches'length loop
                    C.graph( I, J) := C.D.edges( I, J );
                end loop;
            end loop;
            result := C.BFS( start, C.origin );
        end if;
    end createPath;



    function BFS( C : access ConstructionCrew; start, stop : Integer )
        return Boolean is
        parents : Int_Array(1..C.D.switches'Length);
        visited : Int_Array(1..C.D.switches'Length);
        distances : Int_Array(1..C.D.switches'Length);
        n : Integer := C.D.switches'Length;
        q : access Queue := new Queue( C.D.switches'Length);
        temp : Integer;
    begin

        for I in Integer range 1..n loop
            parents( i ) := 0;
            visited( i ) := 0;
        end loop;

        parents( start ) := -1;
        visited( start ) := 1;
        distances( start ):= 1;
        q.push( start );

        while q.isEmpty = False loop
            temp := q.pop;
            for I in Integer range 1..n loop
                if C.graph( temp, I ) /= 0 and visited( i ) = 0 then
                    parents( I ) := temp;
                    q.push( I );
                    visited( I ) := 1;
                    distances( I ) := distances( temp ) + 1;
                end if;
            end loop;

        end loop;

        if visited( stop ) /= 0 then
            C.path := new Int_Array( 1..distances( stop ) );
            temp := stop;

            for I in reverse 1..distances( stop ) loop
                C.path( I ) := temp;
                temp := parents( temp );
            end loop;
            Put_Line("Trasa: ");
            for I in 1..C.path'Length loop
                Put( C.Path(I) );
            end loop;
            Put_Line(" ");
            return True;
        else
            return False;
        end if;


    end BFS;



    procedure blockAllSwitchesOnThePath(C : access ConstructionCrew) is
    begin
        for I in Integer range 1..C.path'Length loop
            C.D.switches( I ).isBroken := True;
        end loop;
    end blockAllSwitchesOnThePath;



    procedure unblockAllSwitchesOnThePath(C : access ConstructionCrew) is
    begin
        for I in Integer range 1..C.path'Length loop
            C.D.switches( I ).isBroken := False;
        end loop;
    end unblockAllSwitchesOnThePath;





    procedure restoreTraffic( C : access ConstructionCrew ) is
    begin
        for I in Integer range 1..C.D.trainTasks'Length loop
            if ( C.typeOfBroken = Types.TRAIN and C.id = I ) = false then
                C.D.trainTasks( I ).RETRY;
            end if;
        end loop;
    end restoreTraffic;




    procedure stats( C : access ConstructionCrew ) is
    begin
        for I in Integer range 1..C.D.Lines'Length loop
            Put_Line( Integer'Image( I ) & " " & Boolean'Image( C.D.lines(I).checkIfOccupied ));
        end loop;
        for I in Integer range 1..C.D.trains'Length loop
            Put_Line(" "& Integer'Image(C.D.trains( I ).currentLine ));
        end loop;
    end stats;




    procedure goByPath( C : access ConstructionCrew ) is
        lineId : Integer;
    begin
        for I in Integer range 1..(C.path'Length-1) loop
            C.changeLine( I );
            C.goCurrentLine( I );
        end loop;
        if C.typeOfBroken = Types.SWITCH then
            C.printPointReachInfo;
        else
            lineId := C.id;
            if C.typeOfBroken = types.TRAIN then
                lineId := C.D.trains( C.id ).currentLine;
            end if;
            C.useSwitch( C.path( C.path'Length ), lineId );
            C.printPointReachInfo;
        end if;
    end goByPath;



    procedure changeLine( C : access ConstructionCrew ; pos : Integer  ) is
        first : Integer := C.path(pos);
        second : Integer := C.path( pos+1 );
        lineId : Integer;
    begin
        lineId := C.graph( first, second );
        C.useSwitch( first, lineId );
    end changeLine;



    procedure useSwitch( C : access ConstructionCrew; switchId, lineId : Integer ) is
    begin
        C.printStartSwitchInfo(switchId);
        delay Standard.Duration( C.D.switches( switchId ).changeTime);
        C.printStopSwitchInfo( lineId );
    end useSwitch;



    procedure printStartSwitchInfo( C : access ConstructionCrew ; switchId : Integer )
    is begin
        printFrost( "   Ekipa remontowa wjeżdza na zwrotnice " &
        Integer'Image( switchId ), C.D.t );
    end printStartSwitchInfo;



    procedure printStopSwitchInfo( C : access ConstructionCrew ; lineId : Integer )
    is begin
        printFrost( "   Ekipa remontowa wjeżdza na tor " &
            Integer'Image( lineId ), C.D.t );
    end printStopSwitchInfo;



    procedure goCurrentLine( C : access ConstructionCrew ; pos : Integer )is
        first : Integer := C.path( pos );
        second : Integer := C.path( pos + 1 );
        lineId : Integer := C.graph( first, second );
    begin
        C.useLine( lineId );
    end goCurrentLine;



    procedure useLine( C : access ConstructionCrew ; lineId : Integer ) is
        t : Integer := C.D.lines( lineId ).minStop ;
        speed : Integer := C.D.lines( lineId ).maxSpeed;
    begin
        if C.D.lines( lineId ).isStopLine = false then
            t := C.D.lines( lineId ).length / speed;
        end if;
        C.printStartLineInfo(lineId );
        delay Standard.Duration( t );
        C.printStopLineInfo( lineId );
    end useLine;



    procedure printStartLineInfo( C : access ConstructionCrew ; lineId : Integer )is
    begin
        printFrost( "   Ekipa remontowa zaczyna jechac torem " &
            Integer'Image( lineId ), C.D.t);
    end printStartLineInfo;



    procedure printStopLineInfo( C : access ConstructionCrew ; lineId : Integer )
    is begin
        printFrost( "   Ekipa remontowa dojechala na koniec toru " &
            Integer'Image( lineId ), C.D.t);
    end printStopLineInfo;



    procedure printPointReachInfo( C : access ConstructionCrew ) is
    begin
        printFrost( "   Ekipa remontowa dojechała na miejsce awarii ", C.D.t );
    end printPointReachInfo;



    procedure printHomeInfo( C : access ConstructionCrew ) is
    begin
        printFrost( "   Ekipa remontowa wróciła do domu", C.D.t);
    end printHomeInfo;



    procedure repair( C : access ConstructionCrew ) is
    begin
        delay Standard.Duration( C.repairTime );
        case C.typeOfBroken is
            when Types.SWITCH =>
                C.D.switches( C.id ).isBroken := False;
            when Types.LINE =>
                C.D.lines( C.id ).isBroken := False;
            when Types.TRAIN =>
                C.D.trains( C.id ).isBroken := False;
        end case;
        C.printFinishBreakdownInfo;
    end repair;



    procedure printFinishBreakdownInfo( C : access ConstructionCrew ) is
    begin
        printFrost( "   Ekipa remontowa zakończyła prace remontowe", C.D.t);
    end printFinishBreakdownInfo;



    procedure goBack( C : access ConstructionCrew )is
    begin
        null;
    end goBack;



    procedure printBreakdownInfo( C : access ConstructionCrew ) is
    begin
        if C.typeOfBroken = types.SWITCH then
            printFrost("    NASTAPILA AWARIA: ZWROTNICA " &
                Integer'Image( c.id ), C.D.t );
        else if C.typeOfBroken = types.LINE then
            printFrost("    NASTAPILA AWARIA: TOR " &
            Integer'Image( c.id ), C.D.t );
        else
            printFrost("    NASTAPILA AWARIA: POCIAG " &
            Integer'Image( c.id ), C.D.t );
        end if; end if;
    end printBreakdownInfo;

end SwitchTaskClass;
