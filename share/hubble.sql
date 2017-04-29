-- 1 up

create table users (
  id serial primary key,
  username text not null unique,
  fullname text,
  password text not null,
  joined timestamp with time zone not null default current_timestamp
);

-- 1 down

drop table if exists users cascade;

