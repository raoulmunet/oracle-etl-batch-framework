create table stg_customer (
    customer_id     number,
    customer_name   varchar2(200),
    email_address   varchar2(320),
    source_system   varchar2(30),
    loaded_at       timestamp default systimestamp
);

create table dwh_customer (
    customer_id     number primary key,
    customer_name   varchar2(200) not null,
    email_address   varchar2(320),
    source_system   varchar2(30),
    created_at      timestamp default systimestamp not null,
    updated_at      timestamp default systimestamp not null
);
