set serveroutput on;
--Trigger creation
create or replace trigger tri_update_customers
after update of last_visit_date on customers
for each row
begin
        insert into logs values(log_seq.nextval, user, 'UPDATE', sysdate,'CUSTOMERS', :old.cid); --add tuple into LOGS
end;
/
-- End of the trigger
show errors

