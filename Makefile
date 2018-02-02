LIB_PATH=.:/opt/local/oracle/product/11.1.0/jdbc/lib/ojdbc5.jar:/opt/local/oracle/product/11.1.0/jlib/orai18n.jar:/opt/local/oracle/product/11.1.0/bin/sqlldr
all: clean
	mkdir bin
	javac -classpath $(LIB_PATH) *.java


clean:
	rm -rf bin/

