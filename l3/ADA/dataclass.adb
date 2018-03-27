


package body DataClass is



    procedure goTheLine( s1, LID, TID : in Integer; D : access Data) is
        speed : Integer;
        goTime : Integer;
    begin
        speed := Minimum( s1, D.lines( LID ).maxSpeed );
        goTime := D.lines( LID ).length / speed;
        printFrost( "Pociąg "& Integer'Image(TID) & " wjeżdża na tor "
                    & Integer'Image(Lid), D.t );
        delay Standard.Duration( (goTime + D.lines( LID ).minStop) *D.mult );
        printFrost( "Pociąg "& Integer'Image(TID) & " dojechał na koniec toru "
                    & Integer'Image(Lid), D.t );
    end goTheLine;





end DataClass;
