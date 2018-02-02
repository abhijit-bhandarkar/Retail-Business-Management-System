set serveroutput on;

-- Trigger to update qoh after a new purchase
create or replace trigger update_on_qoh
after insert on purchases
for each row
declare last_visit_dt Customers.last_visit_date%type;
quantity_oh Products.qoh%type;
q_threshold Products.qoh_threshold%type;
s_id Supplies.sid%type;
qoh_adder Products.qoh%type;
begin
select qoh into quantity_oh from Products where pid = :new.pid;
select qoh_threshold into q_threshold from Products where pid = :new.pid;
if((quantity_oh - :new.qty) < q_threshold) then  -- condition to check if the qoh has fallen below the qoh threshold
select sid into s_id from supplies where pid = :new.pid and rownum <= 1 order by sid asc;
dbms_output.put_line('the current qoh of the product ' || to_char(:new.pid) || ' is below the required threshold and new supply is required');
qoh_adder := 20 + q_threshold;
insert into supplies           -- a new supply is ordered if qoh falls below qoh_threshold
values
(supplies_seq.nextval, :new.pid, s_id, to_date(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'), qoh_adder);
update products set qoh = qoh - :new.qty + qoh_adder where pid = :new.pid;          -- qoh of the product updated
dbms_output.put_line('the new value of qoh of the product ' || ' is ' || to_char(quantity_oh - :new.qty + qoh_adder));
else
update products set qoh = qoh - :new.qty 
where pid = :new.pid;
dbms_output.put_line('the new value of qoh of the product ' || ' is ' || to_char(quantity_oh - :new.qty));
end if;
select last_visit_date into last_visit_dt from Customers where cid = :new.cid;   
if(to_char(:new.ptime, 'DD-MM-YYYY') != to_char(last_visit_dt, 'DD-MM-YYYY')) then   -- condition to check if the last visit date of the customer should be updated or not
update Customers
set visits_made = visits_made + 1, last_visit_date = :new.ptime
where cid = :new.cid;
end if;
end;
/
show errors
