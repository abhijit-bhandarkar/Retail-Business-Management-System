set serveroutput on;
--Trigger creation
create or replace trigger tri_insert_customers		
after insert on customers
for each row
begin
        insert into logs values(log_seq.nextval, user, 'INSERT', sysdate, 'CUSTOMERS', --add tuple into LOGS
:new.cid);
end;		
/
-- End of the trigger
show errors
