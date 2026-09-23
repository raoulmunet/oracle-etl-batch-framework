create or replace package body pkg_customer_load as

    procedure run
    is
        l_batch_id      number;
        l_job_run_id    number;
        l_read          number := 0;
        l_inserted      number := 0;
        l_updated       number := 0;
        l_rejected      number := 0;
        l_exists        number;
        l_final_status  varchar2(20);
    begin
        l_batch_id := pkg_etl_batch.start_batch('CUSTOMER_DAILY_LOAD');
        l_job_run_id := pkg_etl_batch.start_job(l_batch_id, 'CUSTOMER_LOAD');

        for r in (
            select customer_id,
                   customer_name,
                   email_address,
                   source_system
              from stg_customer
        )
        loop
            l_read := l_read + 1;

            if r.customer_id is null then
                l_rejected := l_rejected + 1;
                pkg_etl_batch.reject_row(
                    l_batch_id, l_job_run_id, null,
                    'CUSTOMER_ID is mandatory',
                    'CUSTOMER_NAME=' || r.customer_name
                );
                continue;
            end if;

            if r.customer_name is null then
                l_rejected := l_rejected + 1;
                pkg_etl_batch.reject_row(
                    l_batch_id, l_job_run_id, to_char(r.customer_id),
                    'CUSTOMER_NAME is mandatory'
                );
                continue;
            end if;

            if r.email_address is not null and instr(r.email_address, '@') = 0 then
                l_rejected := l_rejected + 1;
                pkg_etl_batch.reject_row(
                    l_batch_id, l_job_run_id, to_char(r.customer_id),
                    'Invalid e-mail address: ' || r.email_address
                );
                continue;
            end if;

            select count(*)
              into l_exists
              from dwh_customer
             where customer_id = r.customer_id;

            merge into dwh_customer d
            using (
                select r.customer_id customer_id,
                       r.customer_name customer_name,
                       r.email_address email_address,
                       r.source_system source_system
                  from dual
            ) s
            on (d.customer_id = s.customer_id)
            when matched then update set
                d.customer_name = s.customer_name,
                d.email_address = s.email_address,
                d.source_system = s.source_system,
                d.updated_at = systimestamp
            when not matched then insert (
                customer_id, customer_name, email_address, source_system
            )
            values (
                s.customer_id, s.customer_name, s.email_address, s.source_system
            );

            if l_exists = 0 then
                l_inserted := l_inserted + 1;
            else
                l_updated := l_updated + 1;
            end if;
        end loop;

        commit;

        l_final_status := case when l_rejected > 0 then 'PARTIAL' else 'SUCCESS' end;

        pkg_etl_batch.finish_job(
            p_job_run_id    => l_job_run_id,
            p_status        => l_final_status,
            p_rows_read     => l_read,
            p_rows_inserted => l_inserted,
            p_rows_updated  => l_updated,
            p_rows_rejected => l_rejected
        );

        pkg_etl_batch.finish_batch(
            p_batch_id => l_batch_id,
            p_status   => l_final_status
        );

    exception
        when others then
            rollback;

            if l_batch_id is not null then
                pkg_etl_batch.log_error(
                    p_batch_id   => l_batch_id,
                    p_job_run_id => l_job_run_id,
                    p_module     => 'PKG_CUSTOMER_LOAD.RUN',
                    p_error_code => sqlcode,
                    p_error_msg  => sqlerrm,
                    p_backtrace  => dbms_utility.format_error_backtrace
                );
            end if;

            if l_job_run_id is not null then
                pkg_etl_batch.finish_job(
                    p_job_run_id => l_job_run_id,
                    p_status     => 'FAILED'
                );
            end if;

            if l_batch_id is not null then
                pkg_etl_batch.finish_batch(
                    p_batch_id => l_batch_id,
                    p_status   => 'FAILED'
                );
            end if;

            raise;
    end;

end pkg_customer_load;
/
