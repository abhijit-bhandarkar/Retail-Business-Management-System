set serveroutput on;

--Trigger to update qoh after delete on purchases
create or replace trigger update_qoh
after delete on purchases
for each row
begin
        update products set qoh = qoh + (:old.qty) where pid = :old.pid;
end update_qoh;
/

--Trigger to update last_visit_made after delete on purchases
create or replace trigger update_last_visit_made
after delete on purchases
for each row
begin
        update customers set last_visit_date = sysdate where cid = :old.cid;
end update_last_visit_made ;
/

--Trigger to update visits_made after delete on purchases
create or replace trigger update_visits_made
after delete on purchases
for each row
begin
        update customers set visits_made = visits_made + 1 where cid = :old.cid;
end update_visits_made;

/
show errors

