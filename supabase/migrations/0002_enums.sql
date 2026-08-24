create type org_type as enum ('PERSONAL', 'BUSINESS', 'CONTRACTOR', 'DEVELOPER');

create type org_status as enum ('ACTIVE', 'SUSPENDED', 'ARCHIVED');

create type member_role as enum ('OWNER', 'ADMIN', 'MEMBER', 'VIEWER');

create type member_status as enum ('ACTIVE', 'INVITED', 'REMOVED');

create type profile_status as enum ('ACTIVE', 'SUSPENDED');

create type project_type as enum ('NEW_BUILD', 'RENOVATION', 'OTHER');

create type project_status as enum ('PLANNING', 'ACTIVE', 'COMPLETED', 'ARCHIVED');

create type payment_method as enum (
  'CASH',
  'BANK_TRANSFER',
  'EWALLET',
  'DEBIT_CARD',
  'CREDIT_CARD',
  'OTHER'
);

create type progress_category as enum (
  'PERSIAPAN',
  'PONDASI',
  'STRUKTUR',
  'DINDING',
  'ATAP',
  'LANTAI',
  'PLAFON',
  'MEP',
  'FINISHING'
);

create type worker_payment_type as enum ('DAILY', 'WEEKLY', 'MONTHLY', 'PROJECT');

create type document_type as enum ('RECEIPT', 'INVOICE', 'CONTRACT', 'PHOTO', 'OTHER');

create type subscription_status as enum (
  'TRIALING',
  'ACTIVE',
  'PAST_DUE',
  'CANCELLED',
  'EXPIRED'
);

create type payment_status as enum ('PENDING', 'PAID', 'FAILED', 'REFUNDED');

create type notification_target_type as enum (
  'ALL',
  'FREE',
  'PRO',
  'BUSINESS',
  'SPECIFIC_ORGANIZATION',
  'SPECIFIC_USER'
);
