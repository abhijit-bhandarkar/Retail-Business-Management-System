import java.sql.Connection;
import java.sql.SQLException;

import oracle.jdbc.pool.OracleDataSource;

public class RetailBusiness {
	

   public static void main (String args []) throws SQLException {

        //Connection to Oracle server. Need to replace username and
      	//password by your username and your password. For security
      	//consideration, it's better to read them in from keyboard.
        OracleDataSource ds = new oracle.jdbc.pool.OracleDataSource();
        ds.setURL("jdbc:oracle:thin:@castor.cc.binghamton.edu:1521:acad111");
        Connection conn = ds.getConnection("adeshmu3", "Wolverine12");
        RetailBusinessManagementSystem retailBusiness = new RetailBusinessManagementSystem(conn);
        retailBusiness.startTheRetailBusiness();
        conn.close();
   }
}
