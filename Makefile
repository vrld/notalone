love = ../love
zip = /usr/bin/zip
luac = /usr/bin/luac

game = yanaw
sources = *.lua */*.lua
res = images/* fonts/* sound/*

.PHONY : run
run : test $(game).love
	$(love) $(game).love

.PHONY : test
test :
	$(luac) -p $(sources)

.PHONY : love
love : $(game).love

$(game).love : $(sources) $(res)
	$(zip) $(game).love $(sources) $(res)

.PHONY : clean
clean :
	rm $(game).love
