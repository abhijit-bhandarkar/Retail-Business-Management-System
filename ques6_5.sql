set serveroutput on;
--Trigger creation
create or replace trigger tri_insert_supplies
after insert on supplies
for each row
begin
        insert into logs values(log_seq.nextval, user, 'INSERT', sysdate, 'SUPPLIES',:new.sup#);	--add tuple into LOGS
end;
/
-- End of the trigger
show errors
