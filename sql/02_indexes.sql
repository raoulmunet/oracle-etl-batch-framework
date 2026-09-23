create index ix_etl_batch_status on etl_batch(status, started_at);
create index ix_etl_job_run_batch on etl_job_run(batch_id, status);
create index ix_etl_error_job on etl_error_log(job_run_id, created_at);
create index ix_etl_reject_job on etl_rejected_row(job_run_id, created_at);
