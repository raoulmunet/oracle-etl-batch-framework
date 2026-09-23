set serveroutput on

truncate table stg_customer;

insert into stg_customer values (3001, 'Frank Lee', 'frank@example.com', 'CRM', systimestamp);
insert into stg_customer values (3002, 'Grace Hall', 'invalid-email', 'CRM', systimestamp);
insert into stg_customer values (null, 'Missing ID', 'missing@example.com', 'CRM', systimestamp);
commit;

begin
    pkg_customer_load.run;
end;
/

select *
from etl_batch
order by batch_id desc
fetch first 1 row only;

select *
from etl_rejected_row
order by reject_id desc;
