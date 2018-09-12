PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE Chill (
    version integer
);
CREATE TABLE Query (
    id integer primary key,
    name varchar(255) not null
);
INSERT INTO "Query" VALUES(1,'select_events.sql');
INSERT INTO "Query" VALUES(2,'insert_event.sql');
CREATE TABLE Template (
    id integer primary key,
    name varchar(255) unique not null
);
CREATE TABLE Node (
    id integer primary key,
    name varchar(255),
    value text,
    template integer,
    query integer,
    foreign key ( template ) references Template ( id ) on delete set null,
    foreign key ( query ) references Query ( id ) on delete set null
    );
INSERT INTO "Node" VALUES(2,'GET_api_events',NULL,NULL,1);
INSERT INTO "Node" VALUES(3,'POST_api_events',NULL,NULL,2);
CREATE TABLE Node_Node (
    node_id integer,
    target_node_id integer,
    foreign key ( node_id ) references Node ( id ) on delete cascade,
    foreign key ( target_node_id ) references Node ( id ) on delete cascade
);
CREATE TABLE Route (
    id integer primary key,
    path text not null,
    node_id integer,
    weight integer default 0,
    method varchar(10) default 'GET',
    foreign key ( node_id ) references Node ( id ) on delete set null
);
INSERT INTO "Route" VALUES(2,'/api/events/',2,NULL,'GET');
INSERT INTO "Route" VALUES(3,'/api/events/',3,NULL,'POST');
CREATE TABLE Event (timestamp DATE DEFAULT 'now', title text);
INSERT INTO "Event" VALUES('2018-07-21 12:48:13','I can haz cheezburger?');
COMMIT;
