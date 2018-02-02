set serveroutput on;
--Trigger creation
create or replace trigger tri_update_products
after update of qoh on products
for each row
begin
        insert into logs values(log_seq.nextval, user, 'UPDATE', sysdate, 'PRODUCTS',:new.pid); --add tuple into LOGS
end;
/
-- End of the trigger
show errors



