insert into etl_job(job_name, description)
values ('CUSTOMER_LOAD', 'Load customer staging data into DWH_CUSTOMER');

insert into stg_customer(customer_id, customer_name, email_address, source_system)
values (1001, 'Alice Morgan', 'alice@example.com', 'CRM');

insert into stg_customer(customer_id, customer_name, email_address, source_system)
values (1002, 'Bob Green', 'bob@example.com', 'CRM');

insert into stg_customer(customer_id, customer_name, email_address, source_system)
values (1003, 'Carla Stone', 'carla@example.com', 'CRM');

commit;
