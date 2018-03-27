#
# Nazwy plikow *.adb, ktore wchodza do projektu
#
SRCS = z1ada.adb types.adb

#
# Nazwy plikow posrednich *.o
#
OBJS = z1ada.o types.o
#
# Nazwa pliku wynikowego
#
PROGRAM =	z1ada

$(PROGRAM):     $(OBJS)
		gnatbind  $(PROGRAM).ali
		gnatlink  $(PROGRAM).ali
		@echo napisz: $(PROGRAM) aby uruchomic.


z1ada.o:       z1ada.adb types.ads
	gnatmake -c z1ada.adb

types.o:       types.adb types.ads
	gnatmake -c types.adb


clean:
	rm  -f *.ali *.o $(PROGRAM) *~
