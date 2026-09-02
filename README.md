# Oracle Database 19c Data Guard --- Production DR Exercise

Hands-on Oracle Database 19c Data Guard engineering project built around
an eight-part Data Guard implementation and implemented on AWS.

The project follows the implementation in sequence while turning each engineering step
into a practical DBA engineering task. The end goal is not simply to
create a standby database, but to demonstrate the complete
disaster-recovery lifecycle: build, replicate, validate, fail over,
recover, reinstate, and perform a planned switchover.

> **A standby database that has never been tested does not prove
> disaster-recovery readiness.**

## Project Goal

Demonstrate that an Oracle Database 19c environment can:

1.  Run as a primary database.
2.  Continuously transport redo to a physical standby.
3.  Apply redo and maintain synchronization.
4.  Detect and troubleshoot replication issues.
5.  Survive a controlled primary failure through Data Guard failover.
6.  Promote the standby to the new primary.
7.  Recover and reinstate/rebuild the former primary.
8.  Perform a planned switchover.
9.  Return to a healthy Data Guard configuration.

This project is designed as a **production-grade DR exercise performed
in a controlled lab environment**.

------------------------------------------------------------------------

# Production DR Implementation Phases

The repository is organized as a sequence of production-grade engineering phases. Each phase has explicit implementation objectives, validation criteria, and operational evidence.

```text
Phase 0 — AWS Infrastructure
       ↓
Phase 1 — Oracle Platform Build & Baseline
       ↓
Phase 2 — RMAN Backup & Recovery Configuration
       ↓
Phase 3 — Oracle 19c July 2026 Release Update Patching
       ↓
Phase 4 — Data Guard Architecture & DR Design
       ↓
Phase 5 — Primary Database Preparation
       ↓
Phase 6 — Oracle Net & Data Guard Connectivity
       ↓
Phase 7 — Physical Standby Construction
       ↓
Phase 8 — Redo Transport & Apply Validation
       ↓
Phase 9 — Client Connectivity & Service Validation
       ↓
Phase 10 — Data Guard Broker
       ↓
Phase 11 — Planned Switchover & Snapshot Standby
       ↓
Phase 12 — Disaster Failover & Active Data Guard
       ↓
Phase 13 — Reinstate / Rebuild Former Primary
       ↓
Phase 14 — Final DR Validation & Recovery Evidence
```

Each phase is completed and validated before proceeding to the next.

# Phase 0 — AWS Infrastructure

Before beginning the Oracle implementation implementation, the AWS foundation is
provisioned with Terraform.

## Current AWS Environment
```
Region: `us-east-1`

The database servers are intentionally deployed across separate
Availability Zones.

  ----------------------------------------------------------------------------
  Component      Role             Instance Type  AZ             Private IP
  -------------- ---------------- -------------- -------------- --------------
  DB01           Oracle 19c       t3.large       us-east-1a     10.20.2.4
                 Primary                                        

  DB02           Oracle 19c       t3.large       us-east-1b     10.20.3.143
                 Standby                                        

  Bastion        Administrative   t3.micro       us-east-1a     Public IP
                 Access                                        
  ----------------------------------------------------------------------------
```
## Storage
```
  Database   Volume            Size AZ           Status
  ---------- ------------- -------- ------------ --------
  DB01       Oracle Data     150 GB us-east-1a   In-use
  DB02       Oracle Data     150 GB us-east-1b   In-use
  DB01       Root            120 GB us-east-1a   In-use
  DB02       Root            120 GB us-east-1b   In-use
```
## Infrastructure Validation

``` text
[x] VPC created
[x] Primary private subnet created
[x] Secondary private subnet created
[x] DB01 deployed in us-east-1a
[x] DB02 deployed in us-east-1b
[x] Bastion deployed
[x] DB01 Oracle data volume attached
[x] DB02 Oracle data volume attached
[x] DB01 and DB02 use separate Availability Zones
[x] EC2 status checks passing
[x] Terraform apply completed successfully
```

------------------------------------------------------------------------

# Phase 1 — Oracle Platform Build & Baseline

## Objective

Build and validate the Oracle 19c platform on both database servers before configuring Data Guard.

## Baseline

Validate:

- Oracle software installation
- Oracle environment variables
- Oracle inventory and Oracle Home
- Database instance status
- CDB/PDB status
- Listener and registered services
- Filesystems and available storage
- CPU, memory, swap, and system load
- Tablespace capacity
- Session and process utilization

A reusable Oracle health-check script performs top-to-bottom OS and Oracle checks, including database role and ARCHIVELOG status, listener/services, tablespaces, and session/process utilization. 

## Validation

```bash
./oracle_health_check.sh
```

The baseline should be captured before patching and again after patching to provide documented pre-change and post-change evidence.

---

# Phase 2 — RMAN Backup & Recovery Configuration

## Objective

Establish a working RMAN backup and recovery foundation before Data Guard role-transition testing.

## Backup Strategy

The environment will use RMAN backups for:

- Database backups
- Archived redo logs
- Current control file
- Control file autobackup
- Backup metadata maintenance
- Restore validation

The project includes a Level 0 full-backup script and a Level 1 incremental-backup script. The Level 0 script backs up the database, archived redo logs, and current control file using compressed backupsets. fileciteturn6file0L6-L16 The Level 1 script provides the daily incremental equivalent and also includes archived redo logs and the current control file. 

## Recovery Validation

```text
[ ] RMAN control file autobackup enabled
[ ] Existing backups cross-checked
[ ] Expired backup metadata removed
[ ] Database backup completed
[ ] Archived redo logs backed up
[ ] Current control file backed up
[ ] Backup summary reviewed
[ ] RESTORE DATABASE VALIDATE completed successfully
```

The RMAN validation workflow performs `RESTORE DATABASE VALIDATE` after the backup and records timestamped backup and validation logs. 

## Operational Backup Evidence

Document:

- Backup location
- Backup schedule
- Backup types
- Backup logs
- Validation results
- Retention requirements
- Recovery objectives

> Backup retention, storage, encryption, monitoring, and recovery objectives will be finalized as part of the production-grade design rather than assumed from the scripts alone.

---

# Phase 3 — Oracle 19c July 2026 Release Update Patching

## Objective

Patch DB01 and DB02 to the same Oracle Database 19c July 2026 Release Update level before establishing the final Data Guard configuration.

## Patch Strategy

The patching procedure will follow the established Oracle 19c database patching workflow used for DB01 and will be applied consistently to both database servers.

```text
Pre-Patch Baseline
        ↓
RMAN / Recovery Verification
        ↓
Oracle Home & Database Validation
        ↓
July 2026 RU Installation
        ↓
Post-Patch SQL / Database Actions
        ↓
Listener / Service Validation
        ↓
Database Version Validation
        ↓
Post-Patch Health Check
```

## Validation

```text
[ ] DB01 pre-patch health captured
[ ] DB02 pre-patch health captured
[ ] RMAN recovery backup verified
[ ] DB01 patched
[ ] DB02 patched
[ ] Database patch level verified on both servers
[ ] Oracle Home versions consistent
[ ] Listener/services healthy
[ ] Database opens successfully
[ ] Post-patch health checks pass
[ ] Final patch evidence captured
```

Both databases must be on compatible Oracle software and patch levels before proceeding to Data Guard configuration.

---

# Phase 4 — Data Guard Architecture & DR Design

## Objective

Understand the architecture and purpose of Oracle Data Guard before
configuring the environment.

## Concepts

-   Primary database
-   Physical standby database
-   Redo transport
-   Redo apply
-   Data Guard roles
-   Switchover
-   Failover
-   Disaster recovery
-   RPO
-   RTO

## Architecture Implementation

``` text
                 AWS us-east-1
                       │
          ┌────────────┴────────────┐
          │                         │
     us-east-1a                us-east-1b
          │                         │
      ┌───────┐                 ┌───────┐
      │ DB01  │ ─── Redo ─────> │ DB02  │
      │PRIMARY│                 │STANDBY│
      └───────┘                 └───────┘
```

DB01 will become the primary database. DB02 will become the physical
standby.

------------------------------------------------------------------------

# Phase 5 — Primary Database Preparation

## Objective

Prepare DB01 to operate as the Data Guard primary.

## Configuration

-   ARCHIVELOG mode
-   FORCE LOGGING
-   Standby redo logs
-   Data Guard initialization parameters
-   Archive destinations
-   FAL configuration
-   Automatic standby file management

## Validation

``` sql
SELECT name,
       log_mode,
       force_logging
FROM v$database;
```

Expected:

``` text
LOG_MODE       ARCHIVELOG
FORCE_LOGGING  YES
```

------------------------------------------------------------------------

# Phase 6 — Oracle Net & Data Guard Connectivity

## Objective

Use the Q&A material as a troubleshooting checkpoint before building the
standby.

## Troubleshooting Focus

-   Oracle Net connectivity
-   Listener configuration
-   TNS resolution
-   SYSDBA connectivity
-   ARCHIVELOG configuration
-   FORCE LOGGING
-   Standby redo logs
-   Data Guard parameters
-   RMAN connectivity
-   File paths
-   Permissions
-   Oracle environment variables

## Connectivity Checks

``` bash
tnsping ORCLPRI
tnsping ORCLSTBY
```

Then:

``` bash
sqlplus sys/<password>@ORCLPRI as sysdba
```

Passwords and secrets are never stored in this repository.

------------------------------------------------------------------------

# Phase 7 — Physical Standby Construction

## Objective

Build DB02 as a physical standby using RMAN Active Database Duplication.

## RMAN

``` text
DUPLICATE TARGET DATABASE
FOR STANDBY
FROM ACTIVE DATABASE
DORECOVER
```

## Start Redo Apply

On DB02:

``` sql
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE
DISCONNECT FROM SESSION;
```

## Validation

``` sql
SELECT name,
       db_unique_name,
       database_role,
       open_mode
FROM v$database;
```

Expected on DB02:

``` text
DATABASE_ROLE
-------------
PHYSICAL STANDBY
```

------------------------------------------------------------------------

# Phase 8 — Redo Transport & Apply Validation

## Objective

Prove that redo generated on DB01 is successfully transported to DB02 and applied by the physical standby.

## Validation

```text
[ ] Primary generates redo
[ ] Standby receives redo
[ ] Standby redo logs functioning
[ ] Managed recovery active
[ ] Redo apply progressing
[ ] Archive gap is empty
[ ] Transport errors reviewed
[ ] Apply lag reviewed
[ ] Primary/standby sequence numbers compared
```

Key checks include:

```sql
SELECT dest_id,
       status,
       target,
       destination,
       error
FROM v$archive_dest
WHERE target = 'STANDBY';
```

```sql
SELECT *
FROM v$archive_gap;
```

```sql
SELECT process,
       status,
       thread#,
       sequence#
FROM v$managed_standby;
```

---

# Phase 9 — Client Connectivity & Service Validation

## Objective

Configure and validate client connectivity in a Data Guard environment.

## Topics

-   Oracle Net Services
-   TNS aliases
-   Database services
-   Primary/standby connectivity
-   Role-aware client connections
-   Connection testing

Example aliases:

``` text
ORCLPRI
ORCLSTBY
```

Connectivity:

``` bash
tnsping ORCLPRI
tnsping ORCLSTBY
```

The final project will document how client connectivity behaves before
and after role transitions.

------------------------------------------------------------------------

# Phase 11 — Planned Switchover & Snapshot Standby

## Objective

Practice planned role transitions and understand Snapshot Standby
behavior.

### Planned Switchover

``` text
Before:

DB01 PRIMARY
     │
     │ Redo
     ▼
DB02 STANDBY


After:

DB01 STANDBY
     ▲
     │ Redo
     │
DB02 PRIMARY
```

Before switchover:

``` text
[ ] Broker/configuration healthy
[ ] Redo transport healthy
[ ] Redo apply healthy
[ ] No archive gap
[ ] Standby synchronized
[ ] Client connectivity validated
```

After switchover:

``` text
[ ] Former standby is PRIMARY
[ ] Former primary is STANDBY
[ ] Redo transport reversed
[ ] Redo apply working
[ ] Client connections validated
```

Snapshot Standby testing, if supported by the environment, will be
documented separately from the destructive failover exercise.

------------------------------------------------------------------------

# Phase 12 — Disaster Failover & Active Data Guard

## Objective

Perform the project's primary disaster-recovery test.

### Replication Test

``` sql
CREATE TABLE DG_FAILOVER_TEST (
    id         NUMBER PRIMARY KEY,
    created_at TIMESTAMP,
    note       VARCHAR2(200)
);
```

``` sql
INSERT INTO DG_FAILOVER_TEST
VALUES (
    1,
    SYSTIMESTAMP,
    'Created on original primary'
);

COMMIT;
```

Generate redo:

``` sql
ALTER SYSTEM SWITCH LOGFILE;
```

Verify the transaction on the standby.

### Primary Failure Simulation

For the controlled lab exercise:

``` sql
SHUTDOWN ABORT;

### Failover

``` text
dgmgrl sys/<SYS_PASSWORD>@ORCLSTBY
```

Then:

``` text
SHOW CONFIGURATION;

FAILOVER TO ORCLSTBY;
```

The physical standby becomes the new primary.

### Verify New Primary

``` sql
SELECT name,
       db_unique_name,
       database_role,
       open_mode
FROM v$database;
```

Expected:

``` text
DATABASE_ROLE
-------------
PRIMARY
```

Verify:

``` sql
SELECT *
FROM DG_FAILOVER_TEST;
```

------------------------------------------------------------------------

# Phase 11 — Planned Switchover & Snapshot Standby

## Objective

Practice planned role transitions and understand Snapshot Standby
behavior.

### Planned Switchover

``` text
Before:

DB01 PRIMARY
     │
     │ Redo
     ▼
DB02 STANDBY


After:

DB01 STANDBY
     ▲
     │ Redo
     │
DB02 PRIMARY
```

Before switchover:

``` text
[ ] Broker/configuration healthy
[ ] Redo transport healthy
[ ] Redo apply healthy
[ ] No archive gap
[ ] Standby synchronized
[ ] Client connectivity validated
```

After switchover:

``` text
[ ] Former standby is PRIMARY
[ ] Former primary is STANDBY
[ ] Redo transport reversed
[ ] Redo apply working
[ ] Client connections validated
```

Snapshot Standby testing, if supported by the environment, will be
documented separately from the destructive failover exercise.

------------------------------------------------------------------------

# Phase 12 — Disaster Failover & Active Data Guard

## Objective

Perform the project's primary disaster-recovery test.

### Replication Test

``` sql
CREATE TABLE DG_FAILOVER_TEST (
    id         NUMBER PRIMARY KEY,
    created_at TIMESTAMP,
    note       VARCHAR2(200)
);
```

``` sql
INSERT INTO DG_FAILOVER_TEST
VALUES (
    1,
    SYSTIMESTAMP,
    'Created on original primary'
);

COMMIT;
```

Generate redo:

``` sql
ALTER SYSTEM SWITCH LOGFILE;
```

Verify the transaction on the standby.

### Primary Failure Simulation

For the controlled lab exercise:

``` sql
SHUTDOWN ABORT;

### Failover

``` text
dgmgrl sys/<SYS_PASSWORD>@ORCLSTBY
```

Then:

``` text
SHOW CONFIGURATION;

FAILOVER TO ORCLSTBY;
```

The physical standby becomes the new primary.

### Verify New Primary

``` sql
SELECT name,
       db_unique_name,
       database_role,
       open_mode
FROM v$database;
```

Expected:

``` text
DATABASE_ROLE
-------------
PRIMARY
```

Verify:

``` sql
SELECT *
FROM DG_FAILOVER_TEST;
```

------------------------------------------------------------------------

# Phase 10 — Data Guard Broker & DR Operations

## Objective

Use Data Guard Broker to centrally manage and validate the Data Guard
environment and complete the final DR exercise.

## Enable Broker

On both databases:

``` sql
ALTER SYSTEM SET DG_BROKER_START=TRUE SCOPE=BOTH;
```

## Create Broker Configuration

``` text
CREATE CONFIGURATION ORCL_DG AS
PRIMARY DATABASE IS ORCLPRI
CONNECT IDENTIFIER IS ORCLPRI;
```

Add standby:

``` text
ADD DATABASE ORCLSTBY AS
CONNECT IDENTIFIER IS ORCLSTBY
MAINTAINED AS PHYSICAL;
```

Enable:

``` text
ENABLE CONFIGURATION;
```

## Broker Validation

``` text
SHOW CONFIGURATION;

VALIDATE DATABASE ORCLPRI;

VALIDATE DATABASE ORCLSTBY;

VALIDATE NETWORK CONFIGURATION FOR ALL;
```

------------------------------------------------------------------------

# Final DR Exercise

``` text
1. PRIMARY HEALTHY
        ↓
2. REDO TRANSPORT
        ↓
3. STANDBY SYNCHRONIZED
        ↓
4. TEST TRANSACTION
        ↓
5. VALIDATE REPLICATION
        ↓
6. SIMULATE PRIMARY FAILURE
        ↓
7. FAILOVER
        ↓
8. STANDBY BECOMES PRIMARY
        ↓
9. VERIFY DATA
        ↓
10. REINSTATE OR REBUILD FORMER PRIMARY
        ↓
11. SYNCHRONIZE
        ↓
12. PLANNED SWITCHOVER
        ↓
13. FINAL VALIDATION
```

------------------------------------------------------------------------

# Phase 13 — Reinstate / Rebuild Former Primary

The former primary should not simply be restarted and returned to
service after failover.

Where possible:

``` text
REINSTATE DATABASE ORCLPRI;
```

Then:

``` text
SHOW CONFIGURATION;

VALIDATE DATABASE ORCLPRI;
```

If reinstate is not possible, rebuild the former primary as a physical
standby using RMAN.

------------------------------------------------------------------------

# Phase 14 — Final DR Validation & Recovery Evidence

## Final Switchover

Once the original primary has been restored as a synchronized standby:

``` text
SWITCHOVER TO ORCLPRI;
```

Final architecture:

``` text
DB01
PRIMARY
   │
   │ Redo Transport
   ▼
DB02
PHYSICAL STANDBY
```

------------------------------------------------------------------------

# RPO / RTO Evidence

The final DR exercise will record measurable recovery information.

## RPO

Record:

-   Last generated redo sequence
-   Last received redo sequence
-   Last applied redo sequence
-   Archive gap status
-   Replication lag

## RTO

Measure:

``` text
Primary Failure
      ↓
Failure Detection
      ↓
Failover
      ↓
New Primary Available
      ↓
Validation Complete
```

The final project should record actual measured values rather than
theoretical targets.

------------------------------------------------------------------------

# Repository Structure

``` text
oracle-19c-data-guard-failover-lab/
│
├── README.md
├── docs/
│   └── Oracle_19c_Data_Guard_Failover_Lab_Runbook.docx
├── sql/
│   ├── primary-validation.sql
│   ├── standby-validation.sql
│   ├── redo-validation.sql
│   └── failover-validation.sql
├── rman/
│   ├── duplicate-standby.rman
│   ├── backup_full.sh
│   ├── backup_incremental.sh
│   └── rman_backup_validate.sh
├── broker/
│   └── data-guard-broker-commands.txt
│
├── scripts/
│   ├── oracle_health_check.sh
│   └── oracle_sessions_check
├── network/
│   ├── listener.ora
│   └── tnsnames.ora
├── terraform/
│   └── ...
└── screenshots/
    └── ...
```

------------------------------------------------------------------------

# Engineering Validation Checklist

## AWS Infrastructure

``` text
[x] VPC created
[x] DB01 deployed
[x] DB02 deployed
[x] DB01 and DB02 in separate AZs
[x] EBS storage attached
[x] Bastion deployed
[x] EC2 status checks passing
[x] Terraform deployment successful
```

## Oracle Foundation

``` text
[ ] Oracle 19c installed on DB01
[ ] Oracle 19c installed on DB02
[ ] Oracle versions/patch levels compatible
[ ] Oracle listener configured
[ ] Oracle Net connectivity verified
```

## Primary

``` text
[ ] ARCHIVELOG enabled
[ ] FORCE LOGGING enabled
[ ] Standby redo logs created
[ ] Data Guard parameters configured
[ ] Redo destination configured
```

## Physical Standby

``` text
[ ] RMAN Active Duplicate completed
[ ] DB02 recognized as physical standby
[ ] Managed recovery enabled
[ ] Redo transport working
[ ] Redo apply working
[ ] Archive gap empty
```

## Broker

``` text
[ ] DG_BROKER_START enabled
[ ] Broker configuration created
[ ] Primary added
[ ] Standby added
[ ] Configuration enabled
[ ] Broker validation successful
```

## DR Test

``` text
[ ] Test transaction created
[ ] Test transaction replicated
[ ] Primary failure simulated
[ ] Failover completed
[ ] Standby promoted to PRIMARY
[ ] Test data verified
[ ] Former primary repaired
[ ] Former primary reinstated/rebuilt
[ ] Data Guard synchronized again
[ ] Planned switchover completed
[ ] Final configuration healthy
```

------------------------------------------------------------------------

# What This Project Demonstrates

-   Oracle Database 19c
-   Oracle Data Guard
-   Physical standby databases
-   Redo transport and apply
-   Standby redo logs
-   ARCHIVELOG and FORCE LOGGING
-   Oracle Net Services
-   RMAN Active Database Duplication
-   Data Guard Broker and DGMGRL
-   Switchover and failover
-   Reinstate/rebuild
-   Disaster recovery testing
-   RPO/RTO measurement
-   AWS multi-AZ infrastructure
-   Terraform infrastructure as code
-   DBA operational validation

------------------------------------------------------------------------

# Key Operational Principle

**Data Guard is more than creating a standby database.**

A production-ready DR strategy requires:

``` text
PROVISION
  ↓
BASELINE
  ↓
BACK UP
  ↓
PATCH
  ↓
CONFIGURE
  ↓
REPLICATE
  ↓
VALIDATE
  ↓
TEST
  ↓
FAIL
  ↓
FAILOVER
  ↓
RECOVER
  ↓
REINSTATE
  ↓
SWITCHOVER
  ↓
VALIDATE AGAIN
```

The purpose of this project is to demonstrate that the DBA understands
not only **how to configure Data Guard**, but also **how to operate it
when something goes wrong**.

------------------------------------------------------------------------

# Documentation

Detailed command-by-command procedures are maintained in:

``` text
docs/Oracle_19c_Data_Guard_Failover_Lab_Runbook.docx
```

The README provides the production-grade project roadmap. The runbook
provides the detailed execution procedures.

------------------------------------------------------------------------

# Disclaimer

Do not execute destructive failover commands against a production
database without an approved disaster-recovery procedure, appropriate
backups, change approval, defined RPO/RTO objectives, and a tested
recovery plan.
