set serveroutput on;
--Trigger creation
create or replace trigger tri_insert_purchases
after insert on purchases
for each row
begin
        insert into logs values(log_seq.nextval, user, 'INSERT', sysdate, 'PURCHASES',:new.pur#); --add tuple into LOGS
end;
/
-- End of the trigger
show errors



