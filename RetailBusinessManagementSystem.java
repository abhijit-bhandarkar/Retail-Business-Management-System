import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.HashMap;
import java.util.Map;
import oracle.jdbc.OracleTypes;

public class RetailBusinessManagementSystem {
	
	private Map<String, String> tableToQueryMappings;
	private Map<String, String> tableNameToColumnMappings;
	
	//Variable declared for each table which stores the column names of that table 
	private String customersHeading = "CID\tNAME\tTELEPHONE#\tVISITS_MADE\tLAST_VISIT_DATE";
	private String discountsHeading = "DISCNT_CATEGORY\tDISCNT_RATE";
	private String employeesHeading = "EID\tNAME\tTELEPHONE#\tEMAIL";
	private String logsHeading = "LOG#\tUSER_NAME\tOPERATION\tOP_TIME\tTABLE_NAME\tTUPLE_PKEY";
	private String productsHeading = "PID\tNAME\t\tQOH\tQOH_THRESHOLD\tORIGINAL_PRICE\tDISCNT_CATEGORY";
	private String purchasesHeading = "PUR#\tEID\tPID\tCID\tQTY\tPTIME\t\t\tTOTAL_PRICE";
	private String suppliersHeading = "SI\tNAME\tCITY\tTELEPHONE#\tEMAIL";
	private String suppliesHeading = "SUP#\tPID\tSI\tSDATE\t\t\tQUANTITY";
	
	//Variables which store the table names present in this system 
	private final String customers = "Customers";
	private final String discounts = "Discounts";
	private final String employees = "Employees";
	private final String logs = "Logs";
	private final String products = "Products";
	private final String purchases = "Purchases";
	private final String suppliers = "Suppliers";
	private final String supplies = "Supplies";
	private Connection connection;
	
	public RetailBusinessManagementSystem(Connection connection) {
		tableToQueryMappings = new HashMap<String, String>();
		tableNameToColumnMappings = new HashMap<String, String>();
		
		//Maps the table name to the query used to retrieve tuples of that table
		tableToQueryMappings.put(customers, "begin ? := rbms.show_customers(); end;");
		tableToQueryMappings.put(discounts, "begin ? := rbms.show_discounts(); end;");
		tableToQueryMappings.put(employees, "begin ? := rbms.show_employees(); end;");
		tableToQueryMappings.put(logs, "begin ? := rbms.show_logs(); end;");
		tableToQueryMappings.put(products, "begin ? := rbms.show_products(); end;");
		tableToQueryMappings.put(purchases, "begin ? := rbms.show_purchases(); end;");
		tableToQueryMappings.put(supplies, "begin ? := rbms.show_supplies(); end;");
		tableToQueryMappings.put(suppliers, "begin ? := rbms.show_suppliers(); end;");
		
		//Maps the table name to its column names
		tableNameToColumnMappings.put(customers, customersHeading);
		tableNameToColumnMappings.put(discounts, discountsHeading);
		tableNameToColumnMappings.put(employees, employeesHeading);
		tableNameToColumnMappings.put(logs, logsHeading);
		tableNameToColumnMappings.put(products, productsHeading);
		tableNameToColumnMappings.put(purchases, purchasesHeading);
		tableNameToColumnMappings.put(supplies, suppliesHeading);
		tableNameToColumnMappings.put(suppliers, suppliersHeading);
		this.connection = connection;
	}
	
	/**
	 * Method which displays all the menu options to the user and executes various procedures
	 * and functions based on the choice of the user
	 */
	public void startTheRetailBusiness() {
		System.out.println("\nWelcome to Retail Business Management System\n");
		CallableStatement enableStatement;
		try {
			enableStatement = connection.prepareCall("begin dbms_output.enable(?); end;");
			enableStatement.setInt(1, 20000);
			enableStatement.execute();
		} catch (SQLException e) {
			System.out.println ("\n*** SQLException caught ***\n" + e.getMessage() + "\n Please try again");
		}
	        while(true) {
	        	try {
	        		System.out.println("Choose one of the options from below");
		        	System.out.println("1. Display table");
		        	System.out.println("2. Get the total savings for a purchase");
		        	System.out.println("3. Get the monthly sale activity of an employee");
		        	System.out.println("4. Add a new customer to the retail business");
		        	System.out.println("5. Purchase a product from the retail business");
		        	System.out.println("6. Return a product purchased");
		        	CallableStatement cs;
		        	BufferedReader readKeyBoard;
		            String option;
		            readKeyBoard = new BufferedReader(new InputStreamReader(System.in));
		            option = readKeyBoard.readLine();
		            int choice = Integer.parseInt(option);
		            switch(choice) {
		            case 1: 
		            	System.out.println("Enter the name of the table to be displayed");
		            	readKeyBoard = new BufferedReader(new InputStreamReader(System.in));
		            	option = readKeyBoard.readLine();
		            	showTable(option);
		            	break;
		            case 2:
		            	System.out.println("Enter the purchase id");
		            	String purchaseId = readKeyBoard.readLine();
		            	cs = connection.prepareCall("{? = call rbms.purchase_saving(?)}");
		                //set the in parameter (the second parameter)
		                cs.setString(2, purchaseId);

		                //register the out parameter (the first parameter)
		                cs.registerOutParameter(1, Types.FLOAT);

		                ResultSet rs = cs.executeQuery();
		                printDbmsOutput(false);
		                //get the out parameter result.
		                if(rs != null) {
		                    float savings = cs.getFloat(1);
		                    if(savings >= 0)
		                    System.out.println("The total savings for the purchase id " + purchaseId + " are " + savings);
		                }
		                break;
		            case 3:
		            	System.out.println("Enter the employee id");
		            	String employeeId = readKeyBoard.readLine();
		            	cs = connection.prepareCall("begin rbms.monthly_sale_activities(:1); end;");
		            	cs.setString(1, employeeId);
		            	cs.executeQuery();
		            	printDbmsOutput(true);
		            	break;
		            case 4:
		            	System.out.println("Enter the customer id of the customer");
		            	String customerId = readKeyBoard.readLine();
		            	System.out.println("Enter the name of the customer");
		            	String customerName = readKeyBoard.readLine();
		            	System.out.println("Enter the telephone number of the customer");
		            	String telephoneNo = readKeyBoard.readLine();
		            	cs = connection.prepareCall("begin rbms.add_customer(:1, :2, :3); end;");
		            	cs.setString(1, customerId);
		            	cs.setString(2, customerName);
		            	cs.setString(3, telephoneNo);
		            	cs.executeQuery();
		            	printDbmsOutput(false);
		            	break;
		            case 5:
		            	System.out.println("Enter the id of the employee from whom you want to purchase the product");
		            	String idOfEmployee = readKeyBoard.readLine();
		            	System.out.println("Enter the product id");
		            	String idOfProduct = readKeyBoard.readLine();
		            	System.out.println("Enter the customer id");
		            	String idOfCustomer = readKeyBoard.readLine();
		            	System.out.println("Enter the quantity to be purchased of this product");
		            	String productQuantity = readKeyBoard.readLine();
		            	cs = connection.prepareCall("begin rbms.add_purchase(:1, :2, :3, :4); end;");
		            	cs.setString(1, idOfEmployee);
		            	cs.setString(2, idOfProduct);
		            	cs.setString(3, idOfCustomer);
		            	cs.setString(4, productQuantity);
		            	cs.executeQuery();
		            	printDbmsOutput(false);
		            	break;
		            case 6:
		            	System.out.println("Enter the purchase id of the purchase");
		            	String purId = readKeyBoard.readLine();
		            	cs = connection.prepareCall("begin rbms.delete_purchase(:1); end;");
		            	cs.setInt(1, Integer.parseInt(purId));
		            	cs.executeQuery();
		            	printDbmsOutput(false);
		            	break;
		            default: 
		            	System.out.println("Please enter a valid option");
		            	break;
		        }
		            System.out.println("Press y to continue and any other key to exit");
		            option = readKeyBoard.readLine();
		            if(option.equalsIgnoreCase("y")) {
		            	continue;
		            } else {
		            	System.out.println("Thanks for visiting retail business management system");
		            	CallableStatement disableStatement = connection.prepareCall("begin dbms_output.disable; end;");
		        		disableStatement.execute();
		            	break;
		            }
	        	} catch (SQLException e) {
	    			System.out.println ("\n*** SQLException caught ***\n" + e.getMessage() + "\n Please try again");
	    		} catch (NumberFormatException e) {
	    			System.out.println ("Please enter a valid option");
	    		} catch (Exception e) {
	    			System.out.println("Exception occurred during the application. Please try again");
	    		}   	
		}
}
	
	/**
	 * Displays the data of the table requested by the user
	 * @param option
	 */
	private void showTable(String option) {
		if(tableToQueryMappings.get(option) == null || tableToQueryMappings.get(option).isEmpty()) {
			System.out.println("Please enter correct table name");
			return;
		}
		//Prepare to call stored procedure:
		CallableStatement cs;
		try {
			cs = connection.prepareCall(tableToQueryMappings.get(option));
			//register the out parameter (the first parameter)
			cs.registerOutParameter(1, OracleTypes.CURSOR);
			
	        // execute and retrieve the result set
	        cs.execute();
	        ResultSet rs = (ResultSet)cs.getObject(1);
	        System.out.println(tableNameToColumnMappings.get(option));
	    	switch(option) {
	    	case customers :
	            // print the results
	            while (rs.next()) {
	                System.out.println(rs.getString(1) + "\t" + 
	                rs.getString(2) + "\t" + rs.getString(3) + "\t" + rs.getString(4) + "\t" + rs.getString(5));
	            }
	            break;
	    	case discounts : 
	            while (rs.next()) {
	                System.out.println(rs.getString(1) + "\t" + rs.getString(2));
	            }
	            break;
	    	case employees :
	    		while(rs.next()) {
	    			System.out.println(rs.getString(1) + "\t" + rs.getString(2) + "\t" + 
	    		rs.getString(3) + "\t" + rs.getString(4));
	    		}
	    		break;
	    	case products :
	    		while(rs.next()) {
	    			System.out.println(rs.getString(1) + "\t" + rs.getString(2) + "\t\t" + 
	    		rs.getString(3) + "\t" + rs.getString(4) + "\t\t" + rs.getString(5) + "\t\t\t" + rs.getString(6));
	    		}
	    		break;
	    	case purchases :
	    		while(rs.next()) {
	    			System.out.println(rs.getString(1) + "\t" + rs.getString(2) + "\t" + 
	    		rs.getString(3) + "\t" + rs.getString(4) + "\t" + rs.getString(5) + "\t" + rs.getString(6) + 
	    		"\t" + rs.getString(7));
	    		}
	    		break;
	    	case supplies :
	    		while(rs.next()) {
	    			System.out.println(rs.getString(1) + "\t" + rs.getString(2) + "\t" + 
	    		rs.getString(3) + "\t" + rs.getString(4) + "\t" + rs.getString(5));
	    		}
	    		break;
	    	case suppliers :
	    		while(rs.next()) {
	    			System.out.println(rs.getString(1) + "\t" + rs.getString(2) + "\t" + 
	    		rs.getString(3) + "\t" + rs.getString(4) + "\t" + rs.getString(5));
	    		}
	    		break;
	    	case logs :
	    		while(rs.next()) {
	    			System.out.println(rs.getString(1) + "\t" + rs.getString(2) + "\t" + 
	    		rs.getString(3) + "\t" + rs.getString(4) + "\t" + rs.getString(5) + "\t" + rs.getString(6));
	    		}
	    		break;
	    	default :
	    		System.out.println("Please enter correct table name");
	    		break;
	    	}
		} catch (SQLException e) {
			System.out.println ("\n*** SQLException caught ***\n" + e.getMessage() + "\n Please try again");
		}
		
		
	}
	
	/**
	 * Fetches the lines put in the dbms_output package by the procedures and displays 
	 * them to the user
	 * @param monthlySales
	 * @throws SQLException
	 */
	private void printDbmsOutput(boolean monthlySales) throws SQLException {
		CallableStatement callableStatement = connection.prepareCall("begin dbms_output.get_line(?, ?); end;");
		callableStatement.registerOutParameter(1, OracleTypes.VARCHAR);
		callableStatement.registerOutParameter(2, OracleTypes.NUMERIC);
		for(;;) {
			callableStatement.execute();
			String dbmsOutput = callableStatement.getString(1);
			if(dbmsOutput == null || callableStatement.getInt(2) == 1) {
				break;
			}
			if(monthlySales) {
				StringBuilder builder = new StringBuilder();
				String[] tokens = dbmsOutput.split(", ");
				for(String token : tokens) {
					builder.append(token + "\t");
				}
				System.out.println(builder.toString());
			} else {
				System.out.println(dbmsOutput);
			}
		}
	}
		
	}
