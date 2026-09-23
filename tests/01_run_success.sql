set serveroutput on

truncate table stg_customer;

insert into stg_customer values (2001, 'Diana West', 'diana@example.com', 'CRM', systimestamp);
insert into stg_customer values (2002, 'Evan Cole', 'evan@example.com', 'CRM', systimestamp);
commit;

begin
    pkg_customer_load.run;
end;
/

select *
from etl_batch
order by batch_id desc
fetch first 1 row only;
