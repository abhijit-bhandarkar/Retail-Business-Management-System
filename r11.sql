set serveroutput on;
create or replace package rbms as


                function purchase_saving(f_pur# in purchases.pur#%type) return number;  /* --3rd function [given a pur# returns total saving on the that purchases] */
                
                procedure monthly_sale_activities(employee_id in Employees.eid%type); /* --4th procedure [given an eid returns monthly activities of employees] */ 
                
                procedure add_customer(c_id in customers.cid%TYPE, c_name in customers.name%TYPE, c_telephone# in customers.telephone#%TYPE); /* --5th procedure [given cid, name and number | customer 
                -- details will -- be added in customers table] */
                
                procedure add_purchase(e_id in Employees.eid%type,p_id in Products.pid%type, c_id in Customers.cid%type, pur_qty in Purchases.qty%type); /* 7th procedure [given eid, pid, cid and qty | 
                -- purchases  -- record will be added in purchases table] */

                procedure delete_purchase(temp_pur# in purchases.pur#%TYPE); /* --8th procedure [ given pur# | it delete's the specific purchase] */

   
                type ref_cursor is ref cursor; /* -- [defining a type ref_cursor to use in below 8 functions to return ref cursor ] */

               /*  --below 8 function defination returns ref_cursor which include complete table info. */
                function show_customers return ref_cursor;
                function show_employees return ref_cursor;
                function show_discounts return ref_cursor;
                function show_logs return ref_cursor;
                function show_products return ref_cursor;
                function show_purchases return ref_cursor;
                function show_suppliers return ref_cursor;
                function show_supplies return ref_cursor;
                           

end;
/

create or replace package body rbms as
 
        function purchase_saving(f_pur# in purchases.pur#%type) return number is f_total_savings number;
                

                begin

                        /*the query used to calculate total saving of the purchase */
                        select original_price*qty - total_price into f_total_savings from products, purchases where pur# = f_pur# and products.pid = purchases.pid;
                        DBMS_OUTPUT.PUT_LINE('Savings calculated successfully');   
                return (f_total_savings);

                
               EXCEPTION
                /*this exception is use to capture invalid pur#*/
                WHEN    NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(sqlerrm || ': The purchase you are looking for is not available, please enter a valid purchase number');
                return -1;
                /* this exception is for all other exceptions other than above */
                WHEN    OTHERS THEN DBMS_OUTPUT.PUT_LINE(sqlerrm || ': Oops, something is wrong, please try again');
                return -1;

        end purchase_saving;


        procedure monthly_sale_activities(employee_id in Employees.eid%type)

        is
        employee_eid employees.eid%type;
        employee_name employees.name%type;
        begin
                /* this query stores eid and name of employee  */
        Select eid, name into employee_eid, employee_name  from employees where eid = employee_id;
        if(sql%rowcount>0) then DBMS_OUTPUT.PUT_LINE ('EID, Name, Month_Year, Monthly_Sales, Total_Quantities, Total_Amount');
        end if;

                /*the below query will pull monthly data of emplyee sales and for loop will print record by record data */
        for rec in      (select to_char(p.ptime,'MON YYYY') as Month_Year, count(*) as Monthly_Sales, sum (p.qty) as Total_Quantities, sum(p.total_price) as Total_Amount 
                        from employees e, purchases p
                        where e.eid = p.eid and e.eid = employee_id 
                        group by to_char(p.ptime, 'MON YYYY'))
        loop
                        DBMS_OUTPUT.PUT_LINE (employee_eid || ', ' || employee_name || ', ' || rec.Month_Year ||', '|| rec.Monthly_Sales ||', ' || rec.Total_Quantities || ', ' || rec.Total_Amount);
                        
        end loop;

        EXCEPTION
                        WHEN    NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(sqlerrm || ': The employee you are looking for does not exist');
                        WHEN    OTHERS THEN DBMS_OUTPUT.PUT_LINE(sqlerrm);

        end monthly_sale_activities;
        
        procedure add_customer( c_id in customers.cid%TYPE, c_name in customers.name%TYPE, c_telephone# in customers.telephone#%TYPE)
                is
                begin
                        /* The query is use to register new customer into our record */
                        insert into customers (cid, name, telephone#, visits_made, last_visit_date) values (c_id, c_name, c_telephone#, 1, SYSDATE);
                        
                        /* the below conditionis to give success message  */
                        if SQL%ROWCOUNT = 1 then DBMS_OUTPUT.PUT_LINE('Customer added successfully');
                        end if;
                        
                        EXCEPTION
                                /* the below exception will raise if cid is already available in our records */ 
                        WHEN    DUP_VAL_ON_INDEX THEN DBMS_OUTPUT.PUT_LINE(sqlerrm || ' : our records indicate that he/she is already our customer');
                        WHEN    OTHERS THEN DBMS_OUTPUT.PUT_LINE(sqlerrm);
                end add_customer;

        procedure add_purchase(e_id in Employees.eid%type,p_id in Products.pid%type, c_id in Customers.cid%type, pur_qty in Purchases.qty%type)
                is
                        quantity_on_hand Products.qoh%type;
                        total_price Purchases.total_price%type;
                        e1_eid Employees.eid%type;
                        c1_cid Customers.cid%type;
			dis products.discnt_category%type;
                begin

                        /* Below 3 queries are to check input values if they are invalid then exception will not be raise */
                        select qoh into quantity_on_hand from Products where pid = p_id;
                        select cid into c1_cid from customers where cid = c_id;
                        select eid into e1_eid from employees where eid = e_id;

			select discnt_category into dis from products where pid=p_id;
			/*checks if the discount category is null for this product and calculates the total price accordingly*/
			if (dis IS NULL OR trim(dis) IS NULL) then select original_price*pur_qty into total_price from Products where pid = p_id; 
			else select original_price*pur_qty*(1-discnt_rate) into total_price from Products,Discounts where pid = p_id and products.discnt_category = discounts.discnt_category;
                	end if;
                        /* if qoh is less than qty then respective message will be shown else new record will be added to purchases */
                        if (pur_qty > quantity_on_hand) then dbms_output.put_line('Insufficient quantity in stock');
                                        /* the seq.nextval will be use to define new pur#  */
                                else insert into Purchases values (purchase_seq.nextval, e_id, p_id, c_id, pur_qty, SYSDATE, total_price);
			DBMS_OUTPUT.PUT_LINE('Customer ' || c_id || ' purchased ' || pur_qty || ' quantities of product ' || p_id || ' from employee ' || e_id);
                        end if;

                        EXCEPTION
                        WHEN    OTHERS THEN DBMS_OUTPUT.PUT_LINE(sqlerrm || '- Invalid pid or cid or eid provided in input');

        end add_purchase;

                
        procedure delete_purchase(temp_pur# in purchases.pur#%TYPE) is
                begin
                        /* The below query is use to delete purchases */
                        delete from purchases where pur# = temp_pur#;
                        
                        /* below query will check if there are any changes happened in purchases or not if not then pur# is invalid  */
                         if SQL%ROWCOUNT = 0 then raise NO_DATA_FOUND;
                         end if;
                                                
                        EXCEPTION
                        WHEN    NO_DATA_FOUND THEN
                        DBMS_OUTPUT.PUT_LINE(sqlerrm || ': The purchase you are looking for does not exist, please take a look at your pur# again');
                        WHEN    OTHERS THEN
                        DBMS_OUTPUT.PUT_LINE(sqlerrm);

        end delete_purchase;    


/* below function will be use to get all data of customers */
function show_customers
return ref_cursor is
rc ref_cursor;
begin
open rc for
select * from customers;
return rc;
end show_customers;

/* below function will be use to get all data of discounts  */
function show_discounts
return ref_cursor is
rc ref_cursor;
begin
open rc for
select * from discounts;
return rc;
end show_discounts;

/*below function will be use to get all data of employees */
function show_employees
return ref_cursor is
rc ref_cursor;
begin
open rc for
select * from employees;
return rc;
end show_employees;



/*below function will be use to get all data of logs*/
function show_logs
return ref_cursor is
rc ref_cursor;
begin
open rc for
select * from logs;
return rc;
end show_logs;


/*below function will be use to get all data of products*/
function show_products
return ref_cursor is
rc ref_cursor;
begin
open rc for
select * from products;
return rc;
end show_products;


/*below function will be use to get all data of purchases*/
function show_purchases
return ref_cursor is
rc ref_cursor;
begin
open rc for
select * from purchases;
return rc;
end show_purchases;


/*below function will be use to get all data of suppliers*/
function show_suppliers
return ref_cursor is
rc ref_cursor;
begin
open rc for
select * from suppliers;
return rc;
end show_suppliers;


/*below function will be use to get all data of supplies*/
function show_supplies
return ref_cursor is
rc ref_cursor;
begin
open rc for
select * from supplies;
return rc;
end show_supplies;


end rbms;
/
show errors
