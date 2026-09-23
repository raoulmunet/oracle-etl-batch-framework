# Design notes

The framework separates generic orchestration metadata from business-specific ETL logic.

`PKG_ETL_BATCH` does not know anything about customers, accounts, or transactions.

Business packages call the framework through a small API and are therefore easy to standardize.

In larger platforms, this pattern can be extended with:

- dependency graphs;
- job parameters;
- scheduler integration;
- retry policies;
- watermarks;
- SLA metadata;
- process ownership;
- alerting;
- centralized dashboards.
