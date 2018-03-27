with Types; use Types;

package QueueClass is

    type Queue( n : Integer ) is tagged record
        q : Int_Array( 1..n );
        capacity : Integer := n;
        start : Integer := 1;
        stop : Integer := 1;
        size : Integer := 0;
    end record;

    function isEmpty( Q : access Queue ) return Boolean;
    procedure push( Q : access Queue; E : Integer );
    function pop( Q : access Queue ) return Integer;

end QueueClass;
