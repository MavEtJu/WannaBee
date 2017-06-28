create table config(
    id integer primary key,
    key text,
    value text
);

create table items(
    id integer primary key,
    item_type_id integer,
    name text,
    set_id integer	-- points to set(id)
);

create table items_in_pouch(
    id integer primary key,
    item_id integer,	-- points to items(id)
    number integer
);

create table sets(
    id integer primary key,
    set_name text,
    set_id integer,
    items_in_set integer
);

create table items_in_sets(
    id integer primary key,
    item_id integer,	-- points to items(id)
    number integer
);

create table places(
    id integer primary key,
    name text,
    place_id integer
);

create table items_in_places(
    id integer primary key,
    item_id integer,
    place_id integer,
    number integer
);

-- Items in places, not in sets
select * from items i join sets s on s.id = i.set_id where i.id in (select item_id from items_in_places where place_id != 2 and item_id not in (select item_id from items_in_sets));

-- Newer items in places:
select * from items i join items_in_places iip on i.id = iip.item_id join places p on iip.place_id = p.id join items_in_sets iis on iip.item_id = iis.item_id where iip.number < iis.number and iip.place_id != 2;

-- Newer items in pouch:
select * from sets s join items i on s.id = i.set_id join items_in_sets iis on i.id = iis.item_id join items_in_pouch iip on iis.item_id = iip.item_id where iip.number < iis.number;


