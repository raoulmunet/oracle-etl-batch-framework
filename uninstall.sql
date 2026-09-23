begin execute immediate 'drop package pkg_customer_load'; exception when others then null; end;
/
begin execute immediate 'drop package pkg_etl_batch'; exception when others then null; end;
/
begin execute immediate 'drop table dwh_customer purge'; exception when others then null; end;
/
begin execute immediate 'drop table stg_customer purge'; exception when others then null; end;
/
begin execute immediate 'drop table etl_rejected_row purge'; exception when others then null; end;
/
begin execute immediate 'drop table etl_error_log purge'; exception when others then null; end;
/
begin execute immediate 'drop table etl_job_run purge'; exception when others then null; end;
/
begin execute immediate 'drop table etl_job purge'; exception when others then null; end;
/
begin execute immediate 'drop table etl_batch purge'; exception when others then null; end;
/
